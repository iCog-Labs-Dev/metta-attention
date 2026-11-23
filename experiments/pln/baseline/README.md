# PLN Smokes baseline

This experiment runs PeTTa's bundled `lib/lib_pln.metta` without ECAN and records what it answers under explicit step and queue limits. It includes the original Smokes knowledge, controlled distractors, scheduler observation, and a reproducible comparison matrix.

## Run

Use Python 3.10 or newer and a working PeTTa checkout with SWI-Prolog on PATH. The Python runner uses only the standard library. With sibling `PeTTa` and `metta-attention` directories, run from the metta-attention root:

```bash
python3 experiments/pln/baseline/run_baseline.py
```

For a different PeTTa location or output directory:

```bash
python3 experiments/pln/baseline/run_baseline.py --petta /absolute/path/to/PeTTa --output-root /absolute/path/to/results
```

The runner uses the selected checkout's bundled library; it does not download dependencies or import a remote PLN implementation. `--config` selects a JSON configuration, defaulting to `configs/smoke.json`: scheduler observation, 100 task selections, task queue setting 10, belief queue setting 100, and a 60-second timeout. `configs/unmodified.json` imports the original library directly without the added scheduler snapshots. Edit a copy to evaluate a different budget. Steps may be zero; queue settings must be at least two.

To run the same seed case without the added scheduler snapshots:

```bash
python3 experiments/pln/baseline/run_baseline.py --config experiments/pln/baseline/configs/unmodified.json
```

Each invocation creates a fresh interpreter and a new output directory. An optional `--run-id NAME` makes the directory name explicit; an existing directory is rejected. The CLI returns 0 for a completed reasoning run, 1 for a recorded runtime/parse error or timeout, and 2 for invalid configuration or setup failure. A completed run can legitimately return no answer.

## Permanent MeTTa entry point

`experiment.metta` is the permanent executable entry point. It visibly loads the snapshot helper, the selected PLN library, `baseline.metta`, and the prepared knowledge, then calls `Baseline.Run`. The Python runner passes changing values as command-line arguments instead of generating a new driver script.

| Argument position in MeTTa | Value |
| --- | --- |
| 1 | Selected PLN library path: original source or observed copy |
| 2 | Prepared `case.metta` path |
| 3 | Maximum task selections |
| 4 | Task-queue limit |
| 5 | Belief-buffer limit |
| 6 | Question IDs and terms as one MeTTa tuple argument |
| 7 | Snapshot helper module path |

The `Experiment.*` functions give these arguments readable names. PeTTa resolves the relative `baseline` import from the permanent entry point's directory. The other paths are absolute. Python passes an argument list directly, so paths with spaces and the complete question tuple remain single arguments.

Use the Python commands above to prepare the case and supply those arguments. `settings.json` records the exact launch command and the entry point's source hash. No `driver.metta` is generated for new runs. Historical settings retain the commands and hashes from their original execution, even when an output folder is moved.

## Knowledge and questions

`cases/smokes_seed.metta` preserves the priors, ten input sentences, evidence IDs, and order from PeTTa's `examples/pln_tuffy.metta`. Only the example's library import and test invocation have been removed. `cases/provenance.json` records content hashes; `cases/LICENSE.PETTA` carries the source MIT notice. Source repository: [trueagi-io/PeTTa](https://github.com/trueagi-io/PeTTa).

The fixed questions cover an input fact (Anna smokes), the existing Edward-cancer regression, friendship inference (Bob smokes), multi-step inference (Bob cancerous), and an unsupported target (Helen cancerous). An unanswered question is not an assertion of falsity. Evidence annotations identify a sufficient path, rather than all possible relevant evidence. The source case also has a zero-strength friendship assertion; it remains unchanged.

`cases/distractors.json` defines two fixed rules, Hobby → Practices → Enjoys, and 6, 24, or 96 hobby facts about the same six people. These are one, four, or sixteen activities per person. Original statements keep IDs 1–10; new rules use 1001–1002 and facts start at 10000. A rules-only control distinguishes adding rules from adding facts. Each larger case contains the smaller one's additions. A standalone run saves the generated `case.metta`; matrix runs keep its hash and generation settings after temporary inputs are removed.

For `order_seed` controls, statements are sorted by SHA-256 of the seed and their evidence ID. Thus shared statements retain their relative order as new facts are added. Null or omitted order preserves the original sequence followed by additions. The same case/order is used across budgets, capacities, and observation modes. These are synthetic unrelated activities, rather than additional smoking evidence.

`baseline.metta` calls `PLN.Derive` once and evaluates every question against that final belief buffer. Its answer selector uses the same `BestCandidate ConfidenceRank` expression as `PLN.Query`. No truth-value formulas or scheduler priorities are replaced. The integration tests compare every question against direct unmodified `PLN.Query` calls.

In `scheduler_snapshots` mode, the runner writes `observed_lib_pln.metta` in the new run directory. It differs from the bundled library by one observation expression at the scheduler boundary, exposing pre-step tasks, beliefs, and raw derivations. `state_snapshot.prolog` copies and numbers variables before serialization, preserving sharing across complete buffers without binding the original terms. Both modes use this helper for final-state output, after reasoning ends. Runtime variable labels are not treated as identities. PeTTa's source files are not edited. This mode requires the reviewed library hash in `cases/provenance.json`; an unrecognized version fails explicitly. Use `instrumentation: none` for unmodified runs on other versions, then review any scheduler change before updating the observer hash. Tests compare full buffers, task order, and answers against unmodified runs at multiple budgets, and validate first-answer steps using independent prefix runs.

## Single-run output

Default output: `experiments/output/pln/baseline/<unique_run_id>/`.

| File | Contents |
| --- | --- |
| `settings.json` | Configuration, runtime environment, question annotations, exact command, and source hashes |
| `runs.csv` | One forward run's status, limits, selected-task count, final buffer sizes, and timings |
| `query_results.csv` | One row per question, including final answer STV and evidence IDs |
| `task_trace.csv` | Ordered selected tasks; local variable names are normalized for comparison |
| `step_metrics.csv` | Before-step buffer sizes, dispatcher calls, and generated/unique sentence counts in observed mode |
| `case.metta` | Exact input knowledge, including additions and input order |
| `observed_lib_pln.metta` | Run-local PLN copy with the observation expression; present only in `scheduler_snapshots` mode |
| `stdout.txt`, `stderr.txt` | Original PeTTa output for checking the structured records |

`schemas/metrics.json` documents units, status, and field availability; it is not an executable JSON Schema validator. Column names and calculations are implemented in `run_baseline.py`. Empty cells are unavailable or inapplicable, never guessed zeroes. In observed mode, first-answer steps come from initial and post-pruning belief buffers. Work counts include raw generated conclusions and distinct new complete sentences before pruning. `rule_attempt_count` counts dispatcher calls inferred from the reviewed scheduler loop, not individual rule-clause matching attempts. These fields are empty in unmodified mode; ECAN diagnostics remain unavailable. ECAN elapsed time is zero for PLN-only runs. Failed runs retain logs and have no question rows.

`pln_elapsed_ms` measures wall time around `PLN.Derive` inside PeTTa, including tracing. Full scheduler observation prints buffers and adds substantial overhead. `total_elapsed_ms` measures process launch through parsing with a monotonic parent clock, including startup, imports, compilation, and result printing. It excludes source hashing and final CSV writing. Do not treat total time as pure inference time or compare different trace modes as a scheduling speedup. Use unmodified-mode controls for timing and compare attention conditions with matching trace modes later.

The bundled library trims queues until their length is strictly less than the configured limit. Initial input queues are not trimmed until after a step. Input order also matters for equal-confidence candidates. Settings and trace records preserve these behaviours; this experiment does not silently fix them.

## Using the records for later ECAN comparisons

Join CSV records within a batch by `run_id`, and step records by `run_id` and `step`. Across baseline and ECAN batches, match the knowledge and truth values, input order, questions, step budget, buffer settings, PLN source, and fresh/retained-state policy. Repeat timing controls on the same machine and include ECAN overhead in the integrated condition.

| Comparison | Recorded fields |
| --- | --- |
| Supported targets answered within a fixed budget | `query_results.csv`: `answer_found`; `runs.csv`: `max_steps` |
| Earlier answers | `query_results.csv`: `first_answer_step` |
| Effort to reach an answer | `step_metrics.csv`: cumulative dispatcher and derivation counts through the first-answer step |
| Whole-run work and runtime | `runs.csv`: task/dispatcher/derivation counts and elapsed times; `summary.json`: unmodified timing medians |
| Final answer strength, confidence, and support | `query_results.csv`: `answer_strength`, `answer_confidence`, `answer_evidence_ids` |
| Selection of annotated evidence | `query_results.csv`: relevant-evidence counts; `task_trace.csv`: ordered tasks and evidence IDs |

All five questions are recorded; assess Helen's unsupported target separately from the four supported targets. Higher confidence alone is not correctness, and `verified_answer_status` remains `unknown` without an independent check. First-answer steps do not measure elapsed time to first answer. Selected-task evidence does not capture every premise used as a paired belief, and the annotations describe sufficient paths rather than all possible paths.

At a fixed step limit, both conditions can consume the same number of selections; compare answers reached and first-answer steps as well. ECAN-specific timings, attention traces, and diagnostics must be collected during integration. New community/goal-switching or new-evidence scenarios need matching PLN-only controls; the current matrix measures fixed cases from fresh state.

## Reference and checks

The tests check the seed against PeTTa's original example and direct `PLN.Query` calls. These STVs are implementation regression observations, not independent ground truth or evidence that higher confidence is better. Machine timings remain in generated outputs and are not frozen as expected values.

Run the checks from the metta-attention root:

```bash
python3 -m unittest discover -s experiments/pln/baseline/tests -v
```

Set `PETTA_PATH=/absolute/path/to/PeTTa` for another checkout. Integration checks are explicitly skipped if PeTTa is absent; a successful benchmark check must include those tests. The suite compares original and wrapped query results, verifies fixture preservation, checks one shared derivation, repeatability, zero/small budgets, failure reporting, timeout handling, and refusal to overwrite an existing run.

Generated runs belong in the output directory. `experiments/output/pln/.gitignore` excludes generated measurements, settings, summaries, and logs. The benchmark source and scoped ignore file belong in version control; there is no separate manually maintained `results/` directory. Share the generated batch folder when sharing measured results. Do not stage the whole repository.

The existing CI workflow runs the MeTTa shell tests for `main` and `dev2`; it does not invoke this Python suite or trigger for PRs targeting `fluid-main`. Record the manual check command and result in the PR.

For review, read the case and questions first, then `experiment.metta`, `baseline.metta`, the metric definitions, the Python runner, and the tests. A regression check compares the permanent entry point with the previous generated-driver mechanism across both observation modes, zero/small/full budgets, distractors, buffer settings, and paths containing spaces. It compares answers, task order, final buffers, and observed step snapshots; elapsed times are naturally excluded from equality checks.

## Full matrix

```bash
python3 experiments/pln/baseline/run_matrix.py
```

`configs/matrix.json` freezes five cases (original, rules-only, and three fact levels), budgets 10/100/500, default limits 10/100 and roomy limits 512/1024, and order seeds 17/41. This is 60 cells. Each has one unmodified warm-up excluded from timing summaries, one observed run, and three unmodified timed runs: 300 fresh interpreter runs. Each process has a 60-second timeout. Allow several minutes and temporary space for one trial's observer traces.

The pilot exhausted roomy queues in 30, 32, 50, 104, and 320 selections respectively; 500 therefore serves as a generous reference, while 10 and 100 constrain work. These choices precede ECAN evaluation. Default and roomy limits expose queue pruning separately. The observer tests compare final states, task order and answers with the unmodified library, including distractors and changed input order. The roomy original-order audit checks unchanged smoking/cancer STVs and evidence for all cases; it is a bounded audit, not a proof about arbitrary future datasets.

The full matrix creates **one batch folder with seven files** when all runs succeed:

```text
experiments/output/pln/baseline/matrix_<batch_id>/
  matrix.json
  summary.json
  settings.json
  runs.csv
  query_results.csv
  task_trace.csv
  step_metrics.csv
```

`runs.csv` contains all 300 trial rows, including warm-ups; join other CSV records by `run_id`. `summary.json` uses only the three unmodified timed repetitions for each timing median, and keeps observed work counts separate. `settings.json` stores the shared environment/source information once and preserves each trial's complete configuration, timestamps, input hash, and command. Combining its `shared` object with a trial reconstructs the original settings exactly.

These files are generated automatically. The four CSVs retain the recorded measurements; the JSON files retain the matrix, source/environment settings, and comparison summaries. `settings.json` also records row counts and checksums for each trial's CSV records, so integrity checks need no ZIP or separate manifest.

`compact_output.py` reads back and verifies appended CSV rows and reconstructed settings before removing a trial's temporary working folder. If saving or verification fails, the collector rolls back the append and leaves the original trial available in `_work/`. Successful trials' raw console output, generated inputs, and observed library copies are discarded after verification. Use a standalone run when those raw files are needed for investigation. Errors and timeouts retain their console output in one additional `errors.jsonl` file. No ZIP is generated. A partial summary is written after every cell. Re-running creates a fresh batch and never overwrites old results.

Every cell records run IDs, requested/completed repetitions, median and min/max unmodified wall time, observed work counts, and all five query results. Observer states and task-order hashes are compared with every completed timed run. Errors, timeouts, and equivalence failures remain explicit and make the batch fail; no query rows are fabricated for failed runs.

Verify a batch's saved CSV records, trial settings, and any failure logs:

```bash
python3 experiments/pln/baseline/compact_output.py PATH_TO_BATCH --verify
```

Use `--config`, `--petta`, and `--output-root` on `run_matrix.py` to select another documented matrix or workspace. Statistical conclusions are limited by the small question set, synthetic distractors, two input orders, and three timing repetitions. These results measure PLN alone and make no claim of ECAN improvement.
