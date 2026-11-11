# PLN Smokes baseline

This experiment runs PeTTa's bundled `lib/lib_pln.metta` without ECAN and records what it answers under explicit step and queue limits. It includes the original Smokes knowledge and optional scheduler observation. Controlled distractors follow as a separate increment.

## Run

Use Python 3.10 or newer and a working PeTTa checkout with SWI-Prolog on PATH. The Python runner uses only the standard library. With sibling `PeTTa` and `metta-attention` directories, run from the metta-attention root:

```bash
python3 experiments/pln/run_baseline.py
```

For a different PeTTa location or output directory:

```bash
python3 experiments/pln/run_baseline.py --petta /absolute/path/to/PeTTa --output-root /absolute/path/to/results
```

The runner uses the selected checkout's bundled library; it does not download dependencies or import a remote PLN implementation. `--config` selects a JSON configuration, defaulting to `configs/smoke.json`: scheduler observation, 100 task selections, task queue setting 10, belief queue setting 100, and a 60-second timeout. `configs/unmodified.json` imports the original library directly without observation. Edit a copy to evaluate a different budget. Steps may be zero; queue settings must be at least two.

Each invocation creates a fresh interpreter and a new output directory. An optional `--run-id NAME` makes the directory name explicit; an existing directory is rejected. The CLI returns 0 for a completed reasoning run, 1 for a recorded runtime/parse error or timeout, and 2 for invalid configuration or setup failure. A completed run can legitimately return no answer.

## Knowledge and questions

`cases/smokes_seed.metta` preserves the priors, ten input sentences, evidence IDs, and order from PeTTa's `examples/pln_tuffy.metta`. Only the example's library import and test invocation have been removed. `cases/provenance.json` records content hashes; `cases/LICENSE.PETTA` carries the source MIT notice. Source repository: [trueagi-io/PeTTa](https://github.com/trueagi-io/PeTTa).

The fixed questions cover an input fact (Anna smokes), the existing Edward-cancer regression, friendship inference (Bob smokes), multi-step inference (Bob cancerous), and an unsupported target (Helen cancerous). An unanswered question is not an assertion of falsity. Evidence annotations identify a sufficient path, rather than all possible relevant evidence. The source case also has a zero-strength friendship assertion; it remains unchanged.

`baseline.metta` calls `PLN.Derive` once and evaluates every question against that final belief buffer. Its answer selector uses the same `BestCandidate ConfidenceRank` expression as `PLN.Query`. No truth-value formulas or scheduler priorities are replaced. The integration tests compare every question against direct unmodified `PLN.Query` calls.

In `scheduler_snapshots` mode, the runner writes `observed_lib_pln.metta` in the new run directory. It differs from the bundled library by exactly one trace expression at the scheduler boundary, exposing pre-step tasks, beliefs, and raw derivations. PeTTa's source files are not edited. This mode requires the reviewed library hash in `cases/provenance.json`; an unrecognized version fails explicitly. Use `instrumentation: none` for unmodified runs on other versions, then review any scheduler change before updating the observer hash. Tests compare full buffers, task order, and answers against unmodified runs at multiple budgets, and validate first-answer steps using independent prefix runs.

## Recorded files

Default output: `experiments/output/pln/<unique_run_id>/`.

| File | Contents |
| --- | --- |
| `settings.json` | Configuration, runtime environment, question annotations, exact command, and source hashes |
| `runs.csv` | One forward run's status, limits, selected-task count, final buffer sizes, and timings |
| `query_results.csv` | One row per question, including final answer STV and evidence IDs |
| `task_trace.csv` | Ordered selected tasks; local variable names are normalized for comparison |
| `step_metrics.csv` | Before-step buffer sizes, dispatcher calls, and generated/unique sentence counts in observed mode |
| `driver.metta` | Exact generated entry point |
| `stdout.txt`, `stderr.txt` | Original PeTTa output for checking the structured records |

`schemas/metrics.json` defines units, status, and field availability. Empty cells are unavailable or inapplicable, never guessed zeroes. In observed mode, first-answer steps come from initial and post-pruning belief buffers. Work counts include raw generated conclusions and distinct new complete sentences before pruning. `rule_attempt_count` counts dispatcher calls inferred from the reviewed scheduler loop, not individual rule-clause matching attempts. These fields are empty in unmodified mode; ECAN diagnostics remain unavailable. ECAN elapsed time is zero for PLN-only runs. Failed runs retain logs and have no question rows.

`pln_elapsed_ms` measures wall time around `PLN.Derive` inside PeTTa, including tracing. Full scheduler observation prints buffers and adds substantial overhead. `total_elapsed_ms` measures process launch through parsing with a monotonic parent clock, including startup, imports, compilation, and result printing. It excludes source hashing and final CSV writing. Do not treat total time as pure inference time or compare different trace modes as a scheduling speedup. Use unmodified-mode controls for timing and compare attention conditions with matching trace modes later.

The bundled library trims queues until their length is strictly less than the configured limit. Initial input queues are not trimmed until after a step. Input order also matters for equal-confidence candidates. Settings and trace records preserve these behaviours; this experiment does not silently fix them.

## Reference and checks

`results/seed_reference.json` is a small implementation reference tied to source hashes and settings. Its STVs are regression observations, not independent ground truth or evidence that higher confidence is better. Machine timings remain in generated outputs and are not frozen as expected values.

Run the checks from the metta-attention root:

```bash
python3 -m unittest discover -s experiments/pln/tests -v
```

Set `PETTA_PATH=/absolute/path/to/PeTTa` for another checkout. Integration checks are explicitly skipped if PeTTa is absent; a successful benchmark check must include those tests. The suite compares original and wrapped query results, verifies fixture preservation, checks one shared derivation, repeatability, zero/small budgets, failure reporting, timeout handling, and refusal to overwrite an existing run.

Generated runs belong in the output directory. `experiments/output/pln/.gitignore` excludes raw runs, including their JSON and text logs. Commit the benchmark source, that scoped ignore file, and the reviewed reference only. Do not stage the whole repository.

The existing MeTTa CI workflow targets `main` and `dev2`, so a PR targeting `fluid-main` does not automatically execute this suite. Record the manual check command and result in the PR.

For review, read the case and questions first, then `baseline.metta`, the metric definitions, the Python runner, and the tests.
