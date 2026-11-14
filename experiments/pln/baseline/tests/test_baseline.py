import csv
import json
import math
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from run_baseline import ANSI, OBSERVER_ANCHOR, OBSERVER_REPLACEMENT, REPO_ROOT, build_case, digest, execute, instrument_library, normalize, parse_output, sexpr
from run_matrix import run_matrix
from compact_output import CompactOutput, TABLES


PETTA = Path(os.environ.get("PETTA_PATH", REPO_ROOT.parent / "PeTTa")).resolve()
CONFIG = json.loads((ROOT / "configs/smoke.json").read_text())
QUESTIONS = json.loads((ROOT / "cases/questions.json").read_text())


def rows(path):
    with path.open(newline="") as handle:
        return list(csv.DictReader(handle))


@unittest.skipUnless((PETTA / "run.sh").is_file(), "Set PETTA_PATH to a PeTTa checkout")
class PeTTaIntegrationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tmp = tempfile.TemporaryDirectory(prefix="pln integration ")
        cls.output, cls.run_record = execute(PETTA, CONFIG, cls.tmp.name, "seed")
        cls.answers = {row["query_id"]: row for row in rows(cls.output / "query_results.csv")}

    @classmethod
    def tearDownClass(cls):
        cls.tmp.cleanup()

    def test_seed_matches_existing_example(self):
        self.assertEqual(self.run_record["status"], "completed", self.run_record)
        result = self.answers["edward_cancer"]
        self.assertTrue(math.isclose(float(result["answer_strength"]), 0.5199204545454544, abs_tol=1e-12))
        self.assertTrue(math.isclose(float(result["answer_confidence"]), 0.8290782204129108, abs_tol=1e-12))
        self.assertEqual(set(json.loads(result["answer_evidence_ids"])), {1, 2, 4, 9, 10})

    def test_permanent_entrypoint_receives_data_arguments(self):
        settings = json.loads((self.output / "settings.json").read_text())
        self.assertEqual(Path(settings["command"][2]), ROOT / "experiment.metta")
        self.assertEqual(settings["entrypoint"], "experiment.metta")
        self.assertIn("experiment.metta", settings["benchmark_sha256"])
        self.assertFalse((self.output / "driver.metta").exists())
        self.assertEqual(Path(settings["command"][4]), self.output / "case.metta")
        self.assertEqual(settings["command"][5:8], ["100", "10", "100"])

    def test_static_entrypoint_matches_legacy_generated_driver(self):
        variants = (
            ("smokes_seed", 0, 10, 100, None, "none"),
            ("smokes_seed", 5, 10, 100, None, "scheduler_snapshots"),
            ("smokes_seed", 100, 10, 100, None, "scheduler_snapshots"),
            ("smokes_noise_24", 100, 10, 100, 17, "scheduler_snapshots"),
            ("smokes_noise_96", 10, 512, 1024, 41, "scheduler_snapshots"),
            ("smokes_noise_96", 500, 512, 1024, 17, "none"),
        )
        for index, (case, budget, tasks, beliefs, seed, mode) in enumerate(variants):
            config = {**CONFIG, "case_id": case, "max_steps": budget, "task_queue_size": tasks, "belief_queue_size": beliefs, "order_seed": seed, "instrumentation": mode}
            output, run = execute(PETTA, config, self.tmp.name, f"static_{index}")
            self.assertEqual(run["status"], "completed", run)
            library = output / "observed_lib_pln.metta" if mode == "scheduler_snapshots" else PETTA / "lib/lib_pln.metta"
            driver = Path(self.tmp.name) / f"legacy_driver_{index}.metta"
            text = f'!(callPredicate (Predicate (use_module {json.dumps(str(ROOT / "state_snapshot.prolog"))})))\n'
            text += "!(import_prolog_function Baseline.Canonical)\n"
            for path in (library, ROOT / "baseline.metta", output / "case.metta"):
                text += f'!(import! &self {json.dumps(str(path.with_suffix("")))})\n'
            questions = " ".join(f'({q["id"]} {q["term"]})' for q in QUESTIONS)
            text += f'!(Baseline.Run (kb) {budget} {tasks} {beliefs} ({questions}))\n'
            driver.write_text(text)
            legacy = subprocess.run(["bash", str(PETTA / "run.sh"), str(driver)], cwd=PETTA, capture_output=True, text=True, timeout=60)
            self.assertEqual(legacy.returncode, 0, legacy.stderr)
            self.assertNotIn("ERROR:", legacy.stderr)
            measured = mode == "scheduler_snapshots"
            old = parse_output(legacy.stdout, QUESTIONS, budget, measured)
            new = parse_output((output / "stdout.txt").read_text(), QUESTIONS, budget, measured)
            self.assertEqual(normalize([old[0], old[1], old[2], old[4]]), normalize([new[0], new[1], new[2], new[4]]))

    def test_all_questions_match_unmodified_query(self):
        script = Path(self.tmp.name) / "oracle.metta"
        text = f'!(import! &self (library lib_pln))\n!(import! &self {json.dumps(str(ROOT / "cases/smokes_seed"))})\n'
        text += "\n".join(f'!(trace! (ORACLE {q["id"]} (PLN.Query (kb) {q["term"]} 100 10 100)) 0)' for q in QUESTIONS)
        script.write_text(text)
        oracle = subprocess.run(["bash", str(PETTA / "run.sh"), str(script)], cwd=PETTA, capture_output=True, text=True, timeout=60)
        self.assertEqual(oracle.returncode, 0, oracle.stderr)
        self.assertNotIn("ERROR:", oracle.stderr)
        found = {}
        for line in oracle.stdout.splitlines():
            if line.startswith("(ORACLE "):
                _, key, answer = sexpr(line)
                found[key] = answer
        self.assertEqual(set(found), set(self.answers))
        for key, answer in found.items():
            actual = self.answers[key]
            self.assertEqual(actual["answer_found"], str(bool(answer)))
            if answer:
                self.assertAlmostEqual(float(actual["answer_strength"]), answer[0][1], places=12)
                self.assertAlmostEqual(float(actual["answer_confidence"]), answer[0][2], places=12)
                self.assertEqual(set(json.loads(actual["answer_evidence_ids"])), set(answer[1]))

    def test_seed_preserves_source_knowledge(self):
        source = (PETTA / "examples/pln_tuffy.metta").read_text()
        expected = source.split("\n", 1)[1].split("!(test", 1)[0].strip()
        expected = "\n".join(line.rstrip() for line in expected.splitlines())
        self.assertEqual((ROOT / "cases/smokes_seed.metta").read_text().strip(), expected)

    def test_single_derivation_and_honest_missing_fields(self):
        text = ANSI.sub("", (self.output / "stdout.txt").read_text())
        self.assertEqual(text.splitlines().count("(PLN_BASELINE_BEGIN)"), 1)
        self.assertEqual(text.splitlines().count("(PLN_BASELINE_END)"), 1)
        trace = rows(self.output / "task_trace.csv")
        self.assertEqual(len(trace), self.run_record["selected_task_count"])
        self.assertEqual([int(row["step"]) for row in trace], list(range(1, len(trace) + 1)))
        self.assertEqual(self.answers["helen_cancer"]["answer_found"], "False")
        self.assertEqual(self.answers["helen_cancer"]["answer_strength"], "")
        self.assertGreater(int(self.answers["bob_cancer"]["first_answer_step"]), 0)
        self.assertGreater(int(rows(self.output / "runs.csv")[0]["rule_attempt_count"]), 0)
        self.assertEqual(self.answers["anna_smokes"]["first_answer_step"], "0")
        self.assertEqual(self.answers["helen_cancer"]["first_answer_step"], "")

    def test_repeatability_and_output_reuse(self):
        output, run = execute(PETTA, CONFIG, self.tmp.name, "repeat")
        self.assertEqual(run["status"], "completed")
        for name in ("query_results.csv", "task_trace.csv"):
            first, second = rows(self.output / name), rows(output / name)
            for record in first + second:
                record.pop("run_id")
            self.assertEqual(first, second)
        original = (output / "settings.json").read_bytes()
        with self.assertRaises(FileExistsError):
            execute(PETTA, CONFIG, self.tmp.name, "repeat")
        self.assertEqual((output / "settings.json").read_bytes(), original)

    def test_zero_budget_keeps_initial_facts(self):
        output, run = execute(PETTA, {**CONFIG, "max_steps": 0}, self.tmp.name, "zero")
        self.assertEqual(run["status"], "completed", run)
        self.assertEqual(run["selected_task_count"], 0)
        self.assertEqual(run["stop_reason"], "step_limit")
        answers = {r["query_id"]: r for r in rows(output / "query_results.csv")}
        self.assertEqual(answers["anna_smokes"]["answer_found"], "True")
        self.assertEqual(answers["edward_cancer"]["answer_found"], "False")

    def test_bounded_run_stops_at_budget(self):
        output, run = execute(PETTA, {**CONFIG, "max_steps": 5}, self.tmp.name, "bounded")
        self.assertEqual(run["status"], "completed", run)
        self.assertEqual(run["selected_task_count"], 5)
        self.assertEqual(run["stop_reason"], "step_limit")

    def test_observer_only_adds_the_trace_expression(self):
        original = (PETTA / "lib/lib_pln.metta").read_text()
        observed = (self.output / "observed_lib_pln.metta").read_text()
        self.assertEqual(observed.replace(OBSERVER_REPLACEMENT, OBSERVER_ANCHOR), original)
        self.assertEqual(observed.count(OBSERVER_REPLACEMENT), 1)

    def test_observed_and_original_states_and_task_order_match(self):
        for budget in (0, 5, 100):
            base = {**CONFIG, "max_steps": budget}
            measured, mrun = execute(PETTA, base, self.tmp.name, f"observed_{budget}")
            original, orun = execute(PETTA, {**base, "instrumentation": "none"}, self.tmp.name, f"original_{budget}")
            self.assertEqual(mrun["status"], "completed", mrun)
            self.assertEqual(orun["status"], "completed", orun)
            mparsed = parse_output((measured / "stdout.txt").read_text(), QUESTIONS, budget, True)
            oparsed = parse_output((original / "stdout.txt").read_text(), QUESTIONS, budget)
            self.assertEqual(mparsed[0], oparsed[0])
            self.assertEqual(normalize(mparsed[2]), normalize(oparsed[2]))
            self.assertEqual(mparsed[1], oparsed[1])
            self.assertEqual(rows(original / "runs.csv")[0]["rule_attempt_count"], "")

    def test_first_answer_steps_match_unmodified_prefix_runs(self):
        budgets = {int(r["first_answer_step"]) for r in self.answers.values() if r["first_answer_step"]}
        budgets |= {b - 1 for b in budgets if b > 0}
        states = {}
        for budget in sorted(budgets):
            output, run = execute(PETTA, {**CONFIG, "max_steps": budget, "instrumentation": "none"}, self.tmp.name, f"prefix_{budget}")
            self.assertEqual(run["status"], "completed", run)
            states[budget] = {r["query_id"]: r for r in rows(output / "query_results.csv")}
        for qid, result in self.answers.items():
            if result["first_answer_step"]:
                first = int(result["first_answer_step"])
                self.assertEqual(states[first][qid]["answer_found"], "True")
                if first:
                    self.assertEqual(states[first - 1][qid]["answer_found"], "False")

    def test_measurement_totals_match_step_records(self):
        steps = rows(self.output / "step_metrics.csv")
        self.assertEqual(len(steps), self.run_record["selected_task_count"])
        self.assertEqual(int(steps[0]["rule_attempt_count"]), 19)
        for total, field in (("rule_attempt_count", "rule_attempt_count"), ("derived_sentence_count", "derived_sentence_count"), ("unique_derived_sentence_count", "new_unique_derived_sentence_count")):
            self.assertEqual(self.run_record[total], sum(int(s[field]) for s in steps))

    def test_distractors_generate_work_without_changing_audited_answers(self):
        baseline = None
        previous_steps = 0
        for case in ("smokes_seed", "smokes_rules_only", "smokes_noise_6", "smokes_noise_24", "smokes_noise_96"):
            config = {**CONFIG, "case_id": case, "max_steps": 500, "task_queue_size": 512, "belief_queue_size": 1024, "instrumentation": "none"}
            output, run = execute(PETTA, config, self.tmp.name, "audit_" + case)
            self.assertEqual(run["status"], "completed", run)
            self.assertEqual(run["stop_reason"], "task_queue_empty")
            signature = [{k: r[k] for k in ("query_id", "answer_found", "answer_strength", "answer_confidence", "answer_evidence_ids")} for r in rows(output / "query_results.csv")]
            if baseline is None:
                baseline = signature
            self.assertEqual(signature, baseline)
            self.assertGreater(run["selected_task_count"], previous_steps)
            previous_steps = run["selected_task_count"]
            for result in signature:
                if result["answer_evidence_ids"]:
                    self.assertTrue(all(i <= 10 for i in json.loads(result["answer_evidence_ids"])))

    def test_distractor_observer_equivalence_with_order_and_capacity_controls(self):
        for case, seed, budget in (("smokes_noise_24", 17, 100), ("smokes_noise_96", 41, 10)):
            for capacity, tasks, beliefs in (("default", 10, 100), ("roomy", 512, 1024)):
                config = {**CONFIG, "case_id": case, "order_seed": seed, "max_steps": budget, "task_queue_size": tasks, "belief_queue_size": beliefs}
                suffix = case + capacity
                _, measured = execute(PETTA, config, self.tmp.name, "noise_observed_" + suffix)
                _, original = execute(PETTA, {**config, "instrumentation": "none"}, self.tmp.name, "noise_original_" + suffix)
                self.assertEqual(measured["status"], "completed", measured)
                self.assertEqual(original["status"], "completed", original)
                for key in ("final_state_sha256", "selected_trace_sha256"):
                    self.assertEqual(measured[key], original[key])

    def test_snapshot_copy_preserves_variable_sharing_without_binding_input(self):
        goal = "'Baseline.Canonical'([X,X,Y],R),var(X),var(Y),R=[A,A,B],A\\==B,halt"
        result = subprocess.run(["swipl", "-q", "-s", str(ROOT / "state_snapshot.prolog"), "-g", goal], capture_output=True, text=True, timeout=10)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_matrix_collects_paired_runs(self):
        config = {"case_ids": ["smokes_seed"], "max_steps": [5], "capacities": [{"id": "default", "task_queue_size": 10, "belief_queue_size": 100}], "order_seeds": [17], "timed_repetitions": 2, "warmup": False, "timeout_seconds": 60}
        directory, summary = run_matrix(PETTA, config, self.tmp.name, "small_matrix")
        self.assertEqual(summary["status"], "completed", summary["failures"])
        self.assertEqual(len(summary["cells"]), 1)
        self.assertEqual(summary["cells"][0]["timed_completed"], 2)
        self.assertEqual(len(summary["cells"][0]["run_ids"]), 3)
        self.assertTrue((directory / "summary.json").is_file())
        self.assertFalse((directory / "runs").exists())
        self.assertFalse((directory / "_work").exists())
        self.assertEqual(len(rows(directory / "runs.csv")), 3)
        self.assertEqual(len(rows(directory / "query_results.csv")), 15)
        self.assertEqual(len(json.loads((directory / "settings.json").read_text())["trials"]), 3)
        self.assertEqual(summary["storage"]["format"], "csv-v2")
        self.assertEqual({p.name for p in directory.iterdir()}, {*TABLES, "settings.json", "matrix.json", "summary.json"})

    def test_collection_preserves_all_measurements_and_settings(self):
        target = Path(self.tmp.name) / "compact_check"
        compact = CompactOutput(target)
        compact.add_run(self.output)
        other, _ = execute(PETTA, {**CONFIG, "max_steps": 5, "instrumentation": "none"}, self.tmp.name, "compact_other")
        expected = {name: rows(self.output / name) + rows(other / name) for name in TABLES}
        original_settings = [json.loads((p / "settings.json").read_text()) for p in (self.output, other)]
        compact.add_run(other, remove_source=True)
        self.assertFalse(other.exists())
        totals = compact.verify()
        self.assertEqual(CompactOutput.open_existing(target).verify(), totals)
        self.assertEqual(totals["runs.csv"], 2)
        for name in TABLES:
            self.assertEqual(rows(target / name), expected[name])
        saved = json.loads((target / "settings.json").read_text())
        self.assertEqual([{**saved["shared"], **trial} for trial in saved["trials"]], original_settings)
        self.assertEqual({p.name for p in target.iterdir()}, {*TABLES, "settings.json"})

    def test_csv_verification_failure_rolls_back_and_keeps_original_files(self):
        compact = CompactOutput(Path(self.tmp.name) / "verification_failure")
        before = {p.name: p.read_bytes() for p in self.output.iterdir()}
        collected_before = {p.name: p.read_bytes() for p in compact.directory.iterdir()}
        with patch.object(compact, "_verify_append", side_effect=ValueError("simulated verification failure")):
            with self.assertRaises(ValueError):
                compact.add_run(self.output, remove_source=True)
        self.assertTrue(self.output.exists())
        self.assertEqual(before, {p.name: p.read_bytes() for p in self.output.iterdir()})
        self.assertEqual(collected_before, {p.name: p.read_bytes() for p in compact.directory.iterdir()})
        self.assertEqual(compact.verify(), {name: 0 for name in TABLES})

    def test_settings_save_failure_rolls_back_and_keeps_original_files(self):
        compact = CompactOutput(Path(self.tmp.name) / "settings_failure")
        before = {p.name: p.read_bytes() for p in self.output.iterdir()}
        saved = (compact.directory / "settings.json").read_bytes()
        with patch.object(compact, "_write_settings", side_effect=OSError("simulated disk failure")):
            with self.assertRaises(OSError):
                compact.add_run(self.output, remove_source=True)
        self.assertEqual(before, {p.name: p.read_bytes() for p in self.output.iterdir()})
        self.assertEqual((compact.directory / "settings.json").read_bytes(), saved)
        self.assertEqual(compact.verify(), {name: 0 for name in TABLES})

    def test_verification_detects_changed_csv_values(self):
        compact = CompactOutput(Path(self.tmp.name) / "altered_csv")
        compact.add_run(self.output)
        path = compact.directory / "query_results.csv"
        values = rows(path)
        values[0]["answer_strength"] = "0.123"
        with path.open("w", newline="") as handle:
            writer = csv.DictWriter(handle, fieldnames=TABLES[path.name])
            writer.writeheader()
            writer.writerows(values)
        with self.assertRaisesRegex(ValueError, "checksum mismatch"):
            compact.verify()


class FailureTests(unittest.TestCase):
    def test_compaction_preserves_failed_run_logs(self):
        with tempfile.TemporaryDirectory() as tmp:
            fake = Path(tmp) / "fake_petta"
            (fake / "lib").mkdir(parents=True)
            (fake / "lib/lib_pln.metta").write_text("")
            (fake / "run.sh").write_text("echo failure-details >&2\nexit 7\n")
            source, run = execute(fake, {**CONFIG, "instrumentation": "none"}, Path(tmp) / "source", "failed")
            self.assertEqual(run["status"], "error")
            compact = CompactOutput(Path(tmp) / "compact")
            compact.add_run(source, remove_source=True)
            compact.verify()
            self.assertEqual(rows(compact.directory / "runs.csv")[0]["status"], "error")
            self.assertEqual(rows(compact.directory / "query_results.csv"), [])
            failure = json.loads((compact.directory / "errors.jsonl").read_text())
            self.assertEqual(failure["run_id"], "failed")
            self.assertIn("failure-details", failure["stderr"])
            self.assertFalse(source.exists())
            self.assertFalse((compact.directory / "details.zip").exists())
            with (compact.directory / "errors.jsonl").open("a") as handle:
                handle.write(json.dumps(failure) + "\n")
            with self.assertRaisesRegex(ValueError, "Duplicate failure log"):
                compact.verify()
    def test_nested_distractors_preserve_original_sentences_and_ids(self):
        source, _ = build_case("smokes_seed")
        original = sexpr(source[source.index("(= (kb)"):])[2]
        previous = []
        for count in (6, 24, 96):
            text, info = build_case(f"smokes_noise_{count}")
            entries = sexpr(text[text.index("(= (kb)"):])[2]
            self.assertEqual(entries[:10], original)
            self.assertEqual(info["initial_sentence_count"], 12 + count)
            self.assertEqual(len({r[2][0] for r in entries}), len(entries))
            self.assertEqual(entries[12:12 + len(previous)], previous)
            previous = entries[12:]

    def test_order_controls_keep_shared_relative_order(self):
        orders = []
        for case in ("smokes_seed", "smokes_noise_6", "smokes_noise_96"):
            text, _ = build_case(case, 17)
            entries = sexpr(text[text.index("(= (kb)"):])[2]
            orders.append([r[2][0] for r in entries if r[2][0] <= 10])
            self.assertEqual(text, build_case(case, 17)[0])
        self.assertEqual(orders[0], orders[1])
        self.assertEqual(orders[0], orders[2])
    def test_unknown_library_version_is_not_instrumented(self):
        with tempfile.TemporaryDirectory() as tmp:
            source = Path(tmp) / "library.metta"
            source.write_text("unexpected source")
            with self.assertRaisesRegex(ValueError, "reviewed PeTTa library hash"):
                instrument_library(source, "wrong hash")
            with self.assertRaisesRegex(ValueError, "observer anchor"):
                instrument_library(source, digest(source))
    def test_incomplete_trace_is_not_a_valid_no_answer(self):
        for text in ("", "(PLN_BASELINE_BEGIN)\n", "(PLN_BASELINE_BEGIN)\n(PLN_BASELINE_END)\n"):
            with self.assertRaises(ValueError):
                parse_output(text, QUESTIONS, 100)

    def test_bad_limits_are_rejected(self):
        for change in ({"max_steps": -1}, {"task_queue_size": 1}, {"belief_queue_size": 0}, {"timeout_seconds": 0}):
            with tempfile.TemporaryDirectory() as tmp, self.assertRaises(ValueError):
                execute(PETTA, {**CONFIG, **change}, tmp)

    def test_process_failures_keep_artifacts_and_no_answer_rows(self):
        with tempfile.TemporaryDirectory(prefix="pln failures ") as tmp:
            fake = Path(tmp) / "fake petta"
            (fake / "lib").mkdir(parents=True)
            (fake / "lib/lib_pln.metta").write_text("")
            for name, script, timeout, expected in (
                ("missing", "exit 0\n", 10, "error"),
                ("crash", "echo failed >&2\nexit 7\n", 10, "error"),
                ("timeout", "sleep 10\n", 0.05, "timeout"),
            ):
                (fake / "run.sh").write_text(script)
                output, run = execute(fake, {**CONFIG, "timeout_seconds": timeout, "instrumentation": "none"}, Path(tmp) / "out", name)
                self.assertEqual(run["status"], expected, run)
                self.assertTrue(run["error"])
                self.assertEqual(rows(output / "query_results.csv"), [])
                self.assertTrue((output / "stdout.txt").is_file())
                self.assertTrue((output / "stderr.txt").is_file())


if __name__ == "__main__":
    unittest.main()
