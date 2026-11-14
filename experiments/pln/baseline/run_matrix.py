import argparse
from datetime import datetime, timezone
import hashlib
from itertools import product
import json
from pathlib import Path
from statistics import median
import sys
from uuid import uuid4

from compact_output import CompactOutput
from run_baseline import REPO_ROOT, ROOT, digest, execute


def answers(records):
    return [{k: r[k] for k in ("query_id", "answer_found", "answer_strength", "answer_confidence", "answer_evidence_ids")} for r in records]


def run_matrix(petta, config, output_root, batch_id=None):
    if type(config.get("timed_repetitions")) is not int or config["timed_repetitions"] < 1:
        raise ValueError("timed_repetitions must be positive")
    if any(not config.get(key) for key in ("case_ids", "max_steps", "capacities", "order_seeds")):
        raise ValueError("Matrix dimensions must be nonempty")
    batch_id = batch_id or "matrix_" + datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S") + "_" + uuid4().hex[:8]
    if not batch_id.replace("_", "").replace("-", "").isalnum():
        raise ValueError("Invalid batch ID")
    directory = Path(output_root).resolve() / batch_id
    directory.parent.mkdir(parents=True, exist_ok=True)
    directory.mkdir()
    compact = CompactOutput(directory)

    def trial(trial_config, run_id):
        path, record = execute(petta, trial_config, directory / "_work", run_id)
        tables = compact.add_run(path, remove_source=True)
        path.parent.rmdir()
        return tables["query_results.csv"], record

    (directory / "matrix.json").write_text(json.dumps(config, indent=2) + "\n")
    summary = {"batch_id": batch_id, "config": config, "matrix_config_sha256": hashlib.sha256(json.dumps(config, sort_keys=True).encode()).hexdigest(), "matrix_runner_sha256": digest(Path(__file__)), "storage": {"format": "csv-v2", "collector_sha256": digest(Path(__file__).with_name("compact_output.py"))}, "cells": [], "failures": [], "status": "running"}
    cells = list(product(config["case_ids"], config["max_steps"], config["capacities"], config["order_seeds"]))
    for index, (case, budget, capacity, seed) in enumerate(cells):
        base = dict(case_id=case, max_steps=budget, task_queue_size=capacity["task_queue_size"], belief_queue_size=capacity["belief_queue_size"], order_seed=seed, timeout_seconds=config["timeout_seconds"])
        prefix = f"c{index:03d}"
        run_ids = []
        if config.get("warmup", True):
            _, warm = trial({**base, "instrumentation": "none", "phase": "warmup"}, prefix + "_warmup")
            if warm["status"] != "completed":
                summary["failures"].append({"run_id": warm["run_id"], "error": warm.get("error")})
        observed_queries, observed = trial({**base, "instrumentation": "scheduler_snapshots"}, prefix + "_observed")
        run_ids.append(observed["run_id"])
        if observed["status"] != "completed":
            summary["failures"].append({"run_id": observed["run_id"], "error": observed.get("error")})
        timed = []
        for repeat in range(1, config["timed_repetitions"] + 1):
            query_rows, record = trial({**base, "instrumentation": "none", "repeat": repeat}, prefix + f"_timed_{repeat}")
            run_ids.append(record["run_id"])
            if record["status"] != "completed":
                summary["failures"].append({"run_id": record["run_id"], "error": record.get("error")})
                continue
            timed.append(record)
            if observed["status"] == "completed":
                for key in ("final_state_sha256", "selected_trace_sha256"):
                    if record[key] != observed[key]:
                        summary["failures"].append({"run_id": record["run_id"], "error": f"Observer equivalence failed: {key}"})
                if answers(query_rows) != answers(observed_queries):
                    summary["failures"].append({"run_id": record["run_id"], "error": "Observer answer equivalence failed"})
        cell = {"case_id": case, "max_steps": budget, "capacity": capacity["id"], "order_seed": seed, "run_ids": run_ids, "timed_completed": len(timed), "timed_requested": config["timed_repetitions"], "observed_status": observed["status"]}
        if timed:
            cell.update(median_pln_elapsed_ms=median(r["pln_elapsed_ms"] for r in timed), median_total_elapsed_ms=median(r["total_elapsed_ms"] for r in timed), min_total_elapsed_ms=min(r["total_elapsed_ms"] for r in timed), max_total_elapsed_ms=max(r["total_elapsed_ms"] for r in timed))
        if observed["status"] == "completed":
            cell.update({k: observed[k] for k in ("selected_task_count", "rule_attempt_count", "derived_sentence_count", "unique_derived_sentence_count", "stop_reason", "final_task_count", "final_belief_count")})
            cell["queries"] = [{k: r[k] for k in ("query_id", "answer_found", "first_answer_step", "answer_strength", "answer_confidence", "answer_evidence_ids")} for r in observed_queries]
        summary["cells"].append(cell)
        (directory / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
        print(f"{index + 1}/{len(cells)} {case} steps={budget} {capacity['id']} order={seed}", flush=True)
    summary["aggregate_rows"] = compact.verify()
    summary["status"] = "completed" if not summary["failures"] else "failed"
    (directory / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
    return directory, summary


def main():
    parser = argparse.ArgumentParser(description="Run the frozen PLN-only baseline matrix")
    parser.add_argument("--petta", type=Path, default=REPO_ROOT.parent / "PeTTa")
    parser.add_argument("--config", type=Path, default=ROOT / "configs/matrix.json")
    parser.add_argument("--output-root", type=Path, default=REPO_ROOT / "experiments/output/pln/baseline")
    args = parser.parse_args()
    directory, summary = run_matrix(args.petta, json.loads(args.config.read_text()), args.output_root)
    print(f"{summary['status']}: {directory}")
    return 0 if summary["status"] == "completed" else 1


if __name__ == "__main__":
    sys.exit(main())
