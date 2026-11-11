import csv
import json
import math
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from run_baseline import ANSI, execute, parse_output, sexpr


PETTA = Path(os.environ.get("PETTA_PATH", ROOT.parents[2] / "PeTTa")).resolve()
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
        self.assertEqual(self.answers["bob_cancer"]["first_answer_step"], "")
        self.assertEqual(rows(self.output / "runs.csv")[0]["rule_attempt_count"], "")

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


class FailureTests(unittest.TestCase):
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
                output, run = execute(fake, {**CONFIG, "timeout_seconds": timeout}, Path(tmp) / "out", name)
                self.assertEqual(run["status"], expected, run)
                self.assertTrue(run["error"])
                self.assertEqual(rows(output / "query_results.csv"), [])
                self.assertTrue((output / "stdout.txt").is_file())
                self.assertTrue((output / "stderr.txt").is_file())


if __name__ == "__main__":
    unittest.main()
