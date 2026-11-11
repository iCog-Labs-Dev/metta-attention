# PLN Smokes baseline

This experiment runs PeTTa's bundled `lib/lib_pln.metta` without ECAN and records what it answers under explicit step and queue limits. It includes the original Smokes knowledge, controlled distractors, scheduler observation, and a reproducible comparison matrix.

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

`cases/distractors.json` defines two fixed rules, Hobby → Practices → Enjoys, and 6, 24, or 96 hobby facts about the same six people. These are one, four, or sixteen activities per person. Original statements keep IDs 1–10; new rules use 1001–1002 and facts start at 10000. A rules-only control distinguishes adding rules from adding facts. Each larger case contains the smaller one's additions. The generated `case.metta` and its hash are saved with each run.

For `order_seed` controls, statements are sorted by SHA-256 of the seed and their evidence ID. Thus shared statements retain their relative order as new facts are added. Null or omitted order preserves the original sequence followed by additions. The same case/order is used across budgets, capacities, and observation modes. These are synthetic unrelated activities, rather than additional smoking evidence.

`baseline.metta` calls `PLN.Derive` once and evaluates every question against that final belief buffer. Its answer selector uses the same `BestCandidate ConfidenceRank` expression as `PLN.Query`. No truth-value formulas or scheduler priorities are replaced. The integration tests compare every question against direct unmodified `PLN.Query` calls.

In `scheduler_snapshots` mode, the runner writes `observed_lib_pln.metta` in the new run directory. It differs from the bundled library by one observation expression at the scheduler boundary, exposing pre-step tasks, beliefs, and raw derivations. `state_snapshot.prolog` copies and numbers variables before serialization, preserving sharing across complete buffers without binding the original terms. Both modes use this helper for final-state output, after reasoning ends. Runtime variable labels are not treated as identities. PeTTa's source files are not edited. This mode requires the reviewed library hash in `cases/provenance.json`; an unrecognized version fails explicitly. Use `instrumentation: none` for unmodified runs on other versions, then review any scheduler change before updating the observer hash. Tests compare full buffers, task order, and answers against unmodified runs at multiple budgets, and validate first-answer steps using independent prefix runs.

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
| `case.metta` | Exact input knowledge, including additions and input order |
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

## Full matrix

```bash
python3 experiments/pln/run_matrix.py
```

`configs/matrix.json` freezes five cases (original, rules-only, and three fact levels), budgets 10/100/500, default limits 10/100 and roomy limits 512/1024, and order seeds 17/41. This is 60 cells. Each has one discarded unmodified warm-up, one observed run, and three unmodified timed runs: 300 fresh interpreter runs. Each process has a 60-second timeout. Allow several minutes and space for the full observer traces.

The pilot exhausted roomy queues in 30, 32, 50, 104, and 320 selections respectively; 500 therefore serves as a generous reference, while 10 and 100 constrain work. These choices precede ECAN evaluation. Default and roomy limits expose queue pruning separately. The observer tests compare final states, task order and answers with the unmodified library, including distractors and changed input order. The roomy original-order audit checks unchanged smoking/cancer STVs and evidence for all cases; it is a bounded audit, not a proof about arbitrary future datasets.

The matrix writes its frozen configuration and `summary.json` under a new batch directory. Every cell records run IDs, requested/completed repetitions, median and min/max unmodified wall time, observed work counts, and all five query results. Observer states and task-order hashes are compared with every completed timed run. Errors, timeouts, and equivalence failures remain explicit and make the batch fail; no query rows are fabricated for failed runs. A partial summary is written after every cell so interrupted batches can be inspected. Re-running always creates a new batch; it does not overwrite or resume old artifacts.

Use `--config`, `--petta`, and `--output-root` to select another documented matrix or workspace. `results/baseline_report.md` and `results/baseline_summary.json` contain the reviewed initial benchmark; full logs stay in ignored output directories. Statistical conclusions are limited by the small question set, synthetic distractors, two input orders, and three timing repetitions. These results measure PLN alone and make no claim of ECAN improvement.
