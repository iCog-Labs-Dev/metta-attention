import argparse
import csv
import hashlib
import json
import math
import os
from pathlib import Path
import platform
import re
import signal
import subprocess
import sys
import time
from datetime import datetime, timezone
from uuid import uuid4


ROOT = Path(__file__).resolve().parent
ANSI = re.compile(r"\x1b\[[0-9;]*m")
TOKEN = re.compile(r'\s*(\(|\)|"(?:[^"\\]|\\.)*"|[^\s()]+)')
RUN_FIELDS = [
    "run_id", "condition", "case_id", "goal_id", "max_steps", "repeat", "state_mode",
    "status", "error", "returncode", "stop_reason", "selected_task_count",
    "final_task_count", "final_belief_count", "pln_elapsed_ms", "ecan_elapsed_ms",
    "total_elapsed_ms", "rule_attempt_count", "unique_derived_sentence_count",
    "ecan_update_count", "focus_size",
]
QUERY_FIELDS = [
    "run_id", "query_id", "answer_found", "first_answer_step", "answer_strength",
    "answer_confidence", "answer_evidence_ids", "verified_answer_status",
    "relevant_facts_available", "relevant_facts_selected", "relevant_facts_in_answer",
    "relevant_facts_in_focus",
]
TRACE_FIELDS = [
    "run_id", "step", "selected_term", "selected_strength", "selected_confidence",
    "selected_evidence_ids",
]


def sexpr(text):
    tokens = []
    pos = 0
    while text[pos:].strip():
        match = TOKEN.match(text, pos)
        if not match:
            raise ValueError("Invalid expression")
        tokens.append(match.group(1))
        pos = match.end()
    stack, values = [], []
    for token in tokens:
        if token == "(":
            stack.append(values)
            values = []
        elif token == ")":
            if not stack:
                raise ValueError("Unbalanced expression")
            child, values = values, stack.pop()
            values.append(child)
        else:
            if token.startswith('"'):
                value = json.loads(token)
            else:
                try:
                    value = int(token)
                except ValueError:
                    try:
                        value = float(token)
                    except ValueError:
                        value = token
            values.append(value)
    if stack or len(values) != 1:
        raise ValueError("Expected one balanced expression")
    return values[0]


def render(value):
    if isinstance(value, list):
        return "(" + " ".join(render(item) for item in value) + ")"
    return str(value)


def normalize(value):
    names = {}

    def visit(item):
        if isinstance(item, list):
            return [visit(child) for child in item]
        if isinstance(item, str) and item.startswith("$"):
            return names.setdefault(item, f"$v{len(names)}")
        return item

    return visit(value)


def sentence(value):
    if not isinstance(value, list) or len(value) != 3 or value[0] != "Sentence":
        raise ValueError("Invalid sentence in PLN trace")
    term, tv = value[1]
    evidence = value[2]
    if len(tv) != 3 or tv[0] != "stv":
        raise ValueError("Invalid truth value")
    if any(type(v) not in (int, float) or not math.isfinite(v) or not 0 <= v <= 1 for v in tv[1:]):
        raise ValueError("Invalid truth value numbers")
    if not isinstance(evidence, list) or any(type(v) is not int for v in evidence):
        raise ValueError("Invalid evidence IDs")
    return render(normalize(term)), tv[1], tv[2], evidence


def parse_output(text, questions, max_steps):
    active, ended = False, False
    selected, answers, state, elapsed = [], {}, None, None
    for raw in ANSI.sub("", text).splitlines():
        line = raw.strip()
        if line == "(PLN_BASELINE_BEGIN)":
            if active or ended:
                raise ValueError("Multiple inference runs detected")
            active = True
        elif line == "(PLN_BASELINE_END)":
            if not active:
                raise ValueError("Unexpected completion marker")
            active, ended = False, True
        elif active and line.startswith("(SELECTED "):
            _, step, entry = sexpr(line)
            if type(step) is not int or step != len(selected) + 1 or step > max_steps:
                raise ValueError("Invalid selected-task sequence")
            selected.append((step, *sentence(entry)))
        elif active and line.startswith("(PLN_BASELINE_STATE "):
            if state is not None:
                raise ValueError("Duplicate final state")
            _, tasks, beliefs = sexpr(line)
            for entry in tasks + beliefs:
                sentence(entry)
            state = (tasks, beliefs)
        elif active and line.startswith("(PLN_BASELINE_TIME "):
            if elapsed is not None:
                raise ValueError("Duplicate timing")
            _, elapsed = sexpr(line)
            if type(elapsed) not in (int, float) or not math.isfinite(elapsed) or elapsed < 0:
                raise ValueError("Invalid inference timing")
        elif active and line.startswith("(PLN_BASELINE_ANSWER "):
            _, query_id, answer = sexpr(line)
            if query_id in answers:
                raise ValueError("Duplicate answer")
            if answer:
                sentence(["Sentence", ["target", answer[0]], answer[1]])
            answers[query_id] = answer
    if active or not ended or state is None or elapsed is None:
        raise ValueError("Incomplete PLN output")
    if set(answers) != {q["id"] for q in questions}:
        raise ValueError("Missing or unexpected query results")
    if state[0] and len(selected) != max_steps:
        raise ValueError("Inference stopped before the requested budget")
    return selected, answers, state, elapsed


def write_csv(path, fields, rows):
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)


def digest(path):
    with path.open("rb") as handle:
        result = hashlib.sha256()
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            result.update(block)
        return result.hexdigest()


def execute(petta, config, output_root, run_id=None):
    petta = Path(petta).resolve()
    if not (petta / "run.sh").is_file() or not (petta / "lib/lib_pln.metta").is_file():
        raise ValueError("PeTTa checkout must contain run.sh and lib/lib_pln.metta")
    config = dict(config)
    if config.get("case_id") != "smokes_seed":
        raise ValueError("Only the smokes_seed case is supported in this increment")
    for field, minimum in (("max_steps", 0), ("task_queue_size", 2), ("belief_queue_size", 2)):
        if type(config.get(field)) is not int or config[field] < minimum:
            raise ValueError(f"{field} must be an integer >= {minimum}")
    timeout = config.get("timeout_seconds")
    if type(timeout) not in (int, float) or not math.isfinite(timeout) or timeout <= 0:
        raise ValueError("timeout_seconds must be positive and finite")
    questions = json.loads((ROOT / "cases/questions.json").read_text())
    if len({q["id"] for q in questions}) != len(questions):
        raise ValueError("Duplicate question IDs")
    for q in questions:
        if not re.fullmatch(r"[A-Za-z][A-Za-z0-9_]*", q["id"]) or not isinstance(sexpr(q["term"]), list):
            raise ValueError("Invalid question")
    run_id = run_id or datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S") + "_" + uuid4().hex[:12]
    if not re.fullmatch(r"[A-Za-z0-9_-]+", run_id):
        raise ValueError("Invalid run ID")
    output = Path(output_root).resolve() / run_id
    output.parent.mkdir(parents=True, exist_ok=True)
    output.mkdir()
    driver = output / "driver.metta"
    imports = "".join(f"!(import! &self {json.dumps(str(path.with_suffix('')))})\n" for path in (ROOT / "baseline.metta", ROOT / "cases/smokes_seed.metta"))
    query_terms = " ".join(f"({q['id']} {q['term']})" for q in questions)
    driver.write_text(imports + f"!(Baseline.Run (kb) {config['max_steps']} {config['task_queue_size']} {config['belief_queue_size']} ({query_terms}))\n")
    source_files = [petta / "run.sh", petta / "lib/lib_pln.metta", *sorted((petta / "src").rglob("*.pl")), *sorted((petta / "lib").glob("*.pl"))]
    mork = petta / "mork_ffi/target/release/libmork_ffi.so"
    if mork.is_file():
        source_files.append(mork)
    local_files = [ROOT / "baseline.metta", ROOT / "run_baseline.py", ROOT / "cases/smokes_seed.metta", ROOT / "cases/questions.json", ROOT / "cases/provenance.json", ROOT / "schemas/metrics.json"]
    settings = {
        "schema_version": 1, "run_id": run_id, "condition": "pln_only", "config": config,
        "created_utc": datetime.now(timezone.utc).isoformat(), "petta_path": str(petta),
        "python": sys.version, "platform": platform.platform(), "questions": questions,
        "source_sha256": {str(p.relative_to(petta)): digest(p) for p in source_files},
        "benchmark_sha256": {str(p.relative_to(ROOT)): digest(p) for p in local_files},
        "swipl": subprocess.run(["swipl", "--version"], capture_output=True, text=True, check=True).stdout.strip(),
        "trace_mode": "selected_tasks_and_final_state", "command": ["bash", str(petta / "run.sh"), str(driver)],
    }
    (output / "settings.json").write_text(json.dumps(settings, indent=2) + "\n")
    row = dict(run_id=run_id, condition="pln_only", case_id=config["case_id"], max_steps=config["max_steps"], repeat=1, state_mode="fresh", ecan_elapsed_ms=0, status="error")
    queries, trace = [], []
    started = time.perf_counter()
    try:
        with (output / "stdout.txt").open("w") as stdout, (output / "stderr.txt").open("w") as stderr:
            proc = subprocess.Popen(settings["command"], cwd=petta, stdout=stdout, stderr=stderr, start_new_session=True)
            try:
                row["returncode"] = proc.wait(timeout=timeout)
            except subprocess.TimeoutExpired:
                try:
                    os.killpg(proc.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
                proc.wait()
                row["returncode"] = proc.returncode
                row["status"] = "timeout"
                raise ValueError("PeTTa exceeded timeout_seconds")
        if row["returncode"] != 0:
            raise ValueError(f"PeTTa exited with code {row['returncode']}")
        if "ERROR:" in (output / "stderr.txt").read_text():
            raise ValueError("PeTTa reported an error; see stderr.txt")
        selected, answers, state, elapsed = parse_output((output / "stdout.txt").read_text(), questions, config["max_steps"])
        row.update(status="completed", pln_elapsed_ms=elapsed, selected_task_count=len(selected), final_task_count=len(state[0]), final_belief_count=len(state[1]), stop_reason="task_queue_empty" if not state[0] else "step_limit")
        selected_ids = {i for item in selected for i in item[4]}
        for q in questions:
            answer = answers[q["id"]]
            result = dict(run_id=run_id, query_id=q["id"], answer_found=bool(answer), verified_answer_status="unknown")
            if answer:
                tv, evidence = answer
                result.update(answer_strength=tv[1], answer_confidence=tv[2], answer_evidence_ids=json.dumps(evidence))
            relevant = q["relevant_evidence_ids"]
            if relevant is not None:
                result.update(relevant_facts_available=len(set(relevant)), relevant_facts_selected=len(set(relevant) & selected_ids), relevant_facts_in_answer=len(set(relevant) & set(answer[1] if answer else [])))
            queries.append(result)
        for step, term, strength, confidence, evidence in selected:
            trace.append(dict(run_id=run_id, step=step, selected_term=term, selected_strength=strength, selected_confidence=confidence, selected_evidence_ids=json.dumps(evidence)))
        row["total_elapsed_ms"] = (time.perf_counter() - started) * 1000
    except (ValueError, OSError, TypeError, IndexError) as error:
        queries, trace = [], []
        row["error"] = str(error)
        if row["status"] != "timeout":
            row["status"] = "error"
        row["total_elapsed_ms"] = (time.perf_counter() - started) * 1000
    write_csv(output / "runs.csv", RUN_FIELDS, [row])
    write_csv(output / "query_results.csv", QUERY_FIELDS, queries)
    write_csv(output / "task_trace.csv", TRACE_FIELDS, trace)
    return output, row


def main():
    parser = argparse.ArgumentParser(description="Run the PeTTa-bundled PLN Smokes baseline")
    parser.add_argument("--petta", type=Path, default=ROOT.parents[2] / "PeTTa")
    parser.add_argument("--config", type=Path, default=ROOT / "configs/smoke.json")
    parser.add_argument("--output-root", type=Path, default=ROOT.parent / "output/pln")
    parser.add_argument("--run-id")
    args = parser.parse_args()
    try:
        output, row = execute(args.petta, json.loads(args.config.read_text()), args.output_root, args.run_id)
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        parser.exit(2, f"{error}\n")
    print(f"{row['status']}: {output}")
    if row.get("error"):
        print(row["error"], file=sys.stderr)
    return 0 if row["status"] == "completed" else 1


if __name__ == "__main__":
    sys.exit(main())
