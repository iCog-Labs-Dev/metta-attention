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
REPO_ROOT = ROOT.parents[2]
ANSI = re.compile(r"\x1b\[[0-9;]*m")
TOKEN = re.compile(r'\s*(\(|\)|"(?:[^"\\]|\\.)*"|[^\s()]+)')
RUN_FIELDS = [
    "run_id", "condition", "case_id", "goal_id", "max_steps", "repeat", "state_mode",
    "status", "error", "returncode", "stop_reason", "selected_task_count",
    "final_task_count", "final_belief_count", "pln_elapsed_ms", "ecan_elapsed_ms",
    "total_elapsed_ms", "rule_attempt_count", "unique_derived_sentence_count",
    "derived_sentence_count", "instrumentation", "final_state_sha256", "selected_trace_sha256", "ecan_update_count", "focus_size",
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
STEP_FIELDS = [
    "run_id", "step", "task_count_before", "belief_count_before",
    "binary_dispatch_count", "unary_dispatch_count", "rule_attempt_count",
    "derived_sentence_count", "new_unique_derived_sentence_count",
]
OBSERVER_ANCHOR = "(let $temp (trace! (SELECTED $steps (Sentence $x $Ev1)) 42)"
OBSERVER_REPLACEMENT = "(let $temp (trace! (SELECTED $steps (Sentence $x $Ev1)) (let ($tasks_snapshot $beliefs_snapshot $derived_snapshot) (Baseline.Canonical ($Tasks $Beliefs $derivations)) (trace! (PLN_BASELINE_STEP $steps $tasks_snapshot $beliefs_snapshot $derived_snapshot) 42)))"


def sexpr(text):
    tokens = []
    pos = 0
    while pos < len(text):
        match = TOKEN.match(text, pos)
        if not match:
            if not text[pos:].strip():
                break
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
        if isinstance(item, (list, tuple)):
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


def parse_output(text, questions, max_steps, require_snapshots=False):
    active, ended = False, False
    selected, answers, state, elapsed = [], {}, None, None
    snapshots = []
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
        elif active and line.startswith("(PLN_BASELINE_STEP "):
            _, step, tasks, beliefs, derivations = sexpr(line)
            if type(step) is not int or step != len(snapshots) + 1 or not selected or selected[-1][0] != step:
                raise ValueError("Invalid scheduler snapshot sequence")
            for entry in tasks + beliefs + derivations:
                sentence(entry)
            snapshots.append((step, tasks, beliefs, derivations))
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
    if require_snapshots and len(snapshots) != len(selected):
        raise ValueError("Missing scheduler snapshots")
    if not require_snapshots and snapshots:
        raise ValueError("Unexpected scheduler snapshots")
    return selected, answers, state, elapsed, snapshots


def instrument_library(source, expected_sha256):
    if digest(source) != expected_sha256:
        raise ValueError("Instrumentation requires the reviewed PeTTa library hash; use instrumentation=none for other versions")
    text = source.read_text()
    if text.count(OBSERVER_ANCHOR) != 1:
        raise ValueError("Unsupported PeTTa scheduler: observer anchor is not unique")
    return text.replace(OBSERVER_ANCHOR, OBSERVER_REPLACEMENT)


def answer_from_beliefs(beliefs, term):
    best, confidence = [], 0
    for entry in beliefs:
        candidate, tv = entry[1]
        if candidate == term and tv[2] > confidence:
            best, confidence = [tv, entry[2]], tv[2]
    return best


def detailed_metrics(snapshots, selected, state, questions, answers, run_id, initial_beliefs):
    first_steps = {}
    for q in questions:
        if answer_from_beliefs(initial_beliefs, sexpr(q["term"])):
            first_steps[q["id"]] = 0
    seen = {render(normalize(entry)) for entry in initial_beliefs}
    step_rows, total_dispatches, total_derived, total_unique = [], 0, 0, 0
    for index, (step, tasks, beliefs, derivations) in enumerate(snapshots):
        selected_evidence = set(selected[index][4])
        disjoint_pairs = sum(not selected_evidence.intersection(entry[2]) for entry in beliefs)
        new_keys = {render(normalize(entry)) for entry in derivations} - seen
        seen.update(new_keys)
        dispatches = 2 * disjoint_pairs + 1
        total_dispatches += dispatches
        total_derived += len(derivations)
        total_unique += len(new_keys)
        step_rows.append(dict(run_id=run_id, step=step, task_count_before=len(tasks), belief_count_before=len(beliefs), binary_dispatch_count=2 * disjoint_pairs, unary_dispatch_count=1, rule_attempt_count=dispatches, derived_sentence_count=len(derivations), new_unique_derived_sentence_count=len(new_keys)))
        after = snapshots[index + 1][2] if index + 1 < len(snapshots) else state[1]
        for q in questions:
            if q["id"] not in first_steps and answer_from_beliefs(after, sexpr(q["term"])):
                first_steps[q["id"]] = step
    for q in questions:
        if answer_from_beliefs(state[1], sexpr(q["term"])) != answers[q["id"]]:
            raise ValueError("Snapshot answer selection disagrees with MeTTa")
    return first_steps, step_rows, total_dispatches, total_derived, total_unique


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


def build_case(case_id, order_seed=None):
    definitions = json.loads((ROOT / "cases/distractors.json").read_text())
    if case_id not in definitions["facts_by_case"]:
        raise ValueError("Unknown Smokes case")
    if order_seed is not None and type(order_seed) is not int:
        raise ValueError("order_seed must be an integer or null")
    seed = (ROOT / "cases/smokes_seed.metta").read_text()
    start = seed.index("(= (kb)")
    priors, definition = seed[:start], sexpr(seed[start:])
    sentences = definition[2]
    count = definitions["facts_by_case"][case_id]
    rule_count = 0
    if case_id != "smokes_seed":
        sentences += [sexpr(rule) for rule in definitions["rules"]]
        rule_count = len(definitions["rules"])
        people = definitions["people"]
        for index in range(count):
            sentences.append(sexpr(definitions["fact_template"].format(person=people[index % len(people)], topic=index // len(people) + 1, evidence_id=10000 + index)))
    if order_seed is not None:
        sentences.sort(key=lambda entry: hashlib.sha256(f"{order_seed}:{entry[2][0]}".encode()).hexdigest())
    text = priors + "(= (kb) " + render(sentences) + ")\n"
    return text, {"original_sentences": 10, "distractor_facts": count, "distractor_rules": rule_count, "initial_sentence_count": len(sentences), "order_seed": order_seed}


def execute(petta, config, output_root, run_id=None):
    petta = Path(petta).resolve()
    if not (petta / "run.sh").is_file() or not (petta / "lib/lib_pln.metta").is_file():
        raise ValueError("PeTTa checkout must contain run.sh and lib/lib_pln.metta")
    config = dict(config)
    repeat = config.setdefault("repeat", 1)
    if type(repeat) is not int or repeat < 1:
        raise ValueError("repeat must be a positive integer")
    mode = config.setdefault("instrumentation", "none")
    if mode not in ("none", "scheduler_snapshots"):
        raise ValueError("instrumentation must be none or scheduler_snapshots")
    case_source, case_info = build_case(config.get("case_id"), config.get("order_seed"))
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
    case_path = output / "case.metta"
    case_path.write_text(case_source)
    library = petta / "lib/lib_pln.metta"
    if mode == "scheduler_snapshots":
        expected = json.loads((ROOT / "cases/provenance.json").read_text())["pln_library_sha256_at_import"]
        observed = instrument_library(library, expected)
        library = output / "observed_lib_pln.metta"
        library.write_text(observed)
    query_terms = "(" + " ".join(f"({q['id']} {q['term']})" for q in questions) + ")"
    command = [
        "bash", str(petta / "run.sh"), str(ROOT / "experiment.metta"),
        str(library), str(case_path), str(config["max_steps"]),
        str(config["task_queue_size"]), str(config["belief_queue_size"]),
        query_terms, str(ROOT / "state_snapshot.prolog"),
    ]
    source_files = [petta / "run.sh", petta / "lib/lib_pln.metta", *sorted((petta / "src").rglob("*.pl")), *sorted((petta / "lib").glob("*.pl"))]
    mork = petta / "mork_ffi/target/release/libmork_ffi.so"
    if mork.is_file():
        source_files.append(mork)
    local_files = [ROOT / "experiment.metta", ROOT / "baseline.metta", ROOT / "state_snapshot.prolog", ROOT / "run_baseline.py", ROOT / "cases/smokes_seed.metta", ROOT / "cases/questions.json", ROOT / "cases/distractors.json", ROOT / "cases/provenance.json", ROOT / "schemas/metrics.json"]
    settings = {
        "schema_version": 3, "run_id": run_id, "condition": "pln_only", "config": config,
        "created_utc": datetime.now(timezone.utc).isoformat(), "petta_path": str(petta),
        "python": sys.version, "platform": platform.platform(), "questions": questions,
        "source_sha256": {str(p.relative_to(petta)): digest(p) for p in source_files},
        "benchmark_sha256": {str(p.relative_to(ROOT)): digest(p) for p in local_files},
        "swipl": subprocess.run(["swipl", "--version"], capture_output=True, text=True, check=True).stdout.strip(),
        "trace_mode": mode, "observer_sha256": digest(library) if mode == "scheduler_snapshots" else None,
        "case": case_info, "case_sha256": digest(case_path),
        "entrypoint": "experiment.metta", "command": command,
    }
    (output / "settings.json").write_text(json.dumps(settings, indent=2) + "\n")
    row = dict(run_id=run_id, condition="pln_only", case_id=config["case_id"], max_steps=config["max_steps"], repeat=repeat, state_mode="fresh", ecan_elapsed_ms=0, status="error")
    row["instrumentation"] = mode
    queries, trace, step_rows = [], [], []
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
        selected, answers, state, elapsed, snapshots = parse_output((output / "stdout.txt").read_text(), questions, config["max_steps"], mode == "scheduler_snapshots")
        row.update(status="completed", pln_elapsed_ms=elapsed, selected_task_count=len(selected), final_task_count=len(state[0]), final_belief_count=len(state[1]), stop_reason="task_queue_empty" if not state[0] else "step_limit")
        row["final_state_sha256"] = hashlib.sha256(json.dumps(normalize(state)).encode()).hexdigest()
        row["selected_trace_sha256"] = hashlib.sha256(json.dumps(selected).encode()).hexdigest()
        first_steps = {}
        if mode == "scheduler_snapshots":
            if snapshots:
                initial = snapshots[0][2]
            else:
                initial = state[1]
            first_steps, step_rows, dispatches, derived, unique = detailed_metrics(snapshots, selected, state, questions, answers, run_id, initial)
            row.update(rule_attempt_count=dispatches, derived_sentence_count=derived, unique_derived_sentence_count=unique)
        selected_ids = {i for item in selected for i in item[4]}
        for q in questions:
            answer = answers[q["id"]]
            result = dict(run_id=run_id, query_id=q["id"], answer_found=bool(answer), verified_answer_status="unknown")
            if q["id"] in first_steps:
                result["first_answer_step"] = first_steps[q["id"]]
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
        queries, trace, step_rows = [], [], []
        row["error"] = str(error)
        if row["status"] != "timeout":
            row["status"] = "error"
        row["total_elapsed_ms"] = (time.perf_counter() - started) * 1000
    write_csv(output / "runs.csv", RUN_FIELDS, [row])
    write_csv(output / "query_results.csv", QUERY_FIELDS, queries)
    write_csv(output / "task_trace.csv", TRACE_FIELDS, trace)
    write_csv(output / "step_metrics.csv", STEP_FIELDS, step_rows)
    return output, row


def main():
    parser = argparse.ArgumentParser(description="Run the PeTTa-bundled PLN Smokes baseline")
    parser.add_argument("--petta", type=Path, default=REPO_ROOT.parent / "PeTTa")
    parser.add_argument("--config", type=Path, default=ROOT / "configs/smoke.json")
    parser.add_argument("--output-root", type=Path, default=REPO_ROOT / "experiments/output/pln/baseline")
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
