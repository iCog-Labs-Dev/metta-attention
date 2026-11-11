# PLN Smokes baseline results

The initial static PLN-only benchmark is implemented and recorded, including controlled distractors. The final batch completed all 60 comparison cells and 300 fresh processes without errors, timeouts, or observer-equivalence failures. This is a baseline for later ECAN comparisons; no ECAN performance claim is made.

## Cases and controls

The original case has six people and ten sentences. The rules-only control adds two fixed Hobby → Practices → Enjoys rules. Other cases add 6, 24, or 96 hobby facts about those same people: one, four, or sixteen activities per person. Total initial sentence counts are 10, 12, 18, 36, and 108. IDs, STVs, and original statements remain intact.

The fourfold increments test scaling without changing the reasoning questions. In the original-order pilot, roomy queues exhausted after 30, 32, 50, 104, and 320 selections. This motivated fixed budgets 10 and 100 for constrained reasoning, with 500 as a generous reference. The levels were fixed before any ECAN evaluation. The [earlier PLN–ECAN paper](https://agi-conf.org/2014/wp-content/uploads/2014/08/harrigan-guiding-agi14.pdf) motivates irrelevant evidence as a hypothesis to test, rather than an established benefit.

The full matrix uses both default queue settings 10/100 and roomy settings 512/1024, plus order seeds 17/41. A stable hash order preserves the relative order of shared facts as distractors are added. Every cell has one unmodified warm-up, one observed run, and three unmodified timed repetitions. All initial states are fresh. Future ECAN conditions must use identical case hashes, orders, budgets, and capacity settings.

## Results

The following values use a 500-step budget and roomy buffers. Each pair is order 17 / order 41. Time is the median inference wall time from three unmodified runs, in milliseconds; observer printing is excluded from those timing samples. The full summary also contains end-to-end medians and min/max values.

| Case | Selected tasks | First Bob-cancer step | Median PLN ms | Answers returned out of 5 |
| --- | --- | --- | --- | --- |
| seed | 30 / 28 | 5 / 21 | 10.4 / 8.0 | 4 / 4 |
| rules_only | 32 / 30 | 7 / 23 | 11.1 / 10.1 | 4 / 4 |
| noise_6 | 50 / 48 | 12 / 41 | 27.8 / 22.2 | 4 / 4 |
| noise_24 | 104 / 102 | 26 / 95 | 106.4 / 131.3 | 4 / 4 |
| noise_96 | 320 / 318 | 59 / 311 | 995.7 / 1653.7 | 4 / 4 |

Every roomy 500-step case exhausted its task queue and returned the same four answers, STVs, and evidence as the original seed reference. Helen cancerous stayed unanswered. That unsupported target is not a false statement, and returned-answer count is not accuracy. Higher confidence is not automatically an improvement.

Default-buffer results at the same 500-step budget show a different effect:

| Case | Selected tasks, orders 17 / 41 | Final beliefs, orders 17 / 41 | Answers returned, orders 17 / 41 |
| --- | --- | --- | --- |
| seed | 27 / 24 | 28 / 26 | 4 / 4 |
| rules_only | 27 / 24 | 30 / 28 | 4 / 4 |
| noise_6 | 27 / 26 | 36 / 38 | 2 / 4 |
| noise_24 | 30 / 28 | 57 / 55 | 2 / 2 |
| noise_96 | 28 / 25 | 99 / 99 | 1 / 1 |

Shorter runs can arise because queues discard work. In particular, the largest case can lose useful smoking/cancer work under default capacities even with a large step budget. The capacity control keeps this effect visible. The baseline therefore records both useful conclusions and computational work, instead of treating fewer steps as a sufficient benefit.

The case generator uses a separate activity vocabulary and adds no explicit route to smoking or cancer. The roomy original-order audit confirms unchanged target STVs and evidence for every noise level; the full matrix also preserves those answers at generous roomy budgets. This is a bounded audit for these rules and cases, not a proof about arbitrary future additions.

## Measurement and validation

The 21 automated checks pass under the repository's Python 3.10 environment. They cover original PeTTa query equivalence, seed preservation, first-answer steps against independent prefix runs, distractor nesting and evidence IDs, matched input order, added inference work, failure/timeout handling, output preservation, and matrix pairing.

For each of 180 completed timed runs, the matrix checks complete ordered final task/belief buffers, selected-task order, and all query answers against its observed counterpart. Variable sharing is preserved by copying and numbering variables before output. The helper does not bind the original reasoning terms. A regression test covers the large, short-budget case that requires stable whole-state serialization.

`rule_attempt_count` means calls to the rule dispatcher inferred from the reviewed scheduler loop, not attempts to match individual rule clauses. Generated-sentence counts include pre-pruning derivations; unique counts exclude initial and previously generated complete sentences, up to variable renaming. First-answer steps refer to initial or post-pruning belief buffers, with input facts at step zero. All correctness labels remain unknown; the reference is an implementation benchmark rather than independent ground truth.

## Reproduction and provenance

From the metta-attention root:

```bash
python3 -m unittest discover -s experiments/pln/tests -v
python3 experiments/pln/run_matrix.py
```

Use `--petta` for a non-sibling PeTTa checkout. The frozen matrix is `configs/matrix.json`. Observation requires the reviewed library hash in `cases/provenance.json`. Unknown versions fail explicitly instead of silently changing the benchmark.

Source batch: `matrix_20261111T222648_738f655a` under `experiments/output/pln/`. `baseline_summary.json` records every cell, run IDs, query results, timed repetitions, source hashes, case hashes, and runtime details. `artifact_manifest.json` hashes the raw artifacts for all 300 processes. Each run preserves settings, the exact case and driver, CSV records, and original stdout/stderr. Raw runs are ignored by version control and are never overwritten.

Runtime: SWI-Prolog version 10.0.2 for x86_64-linux; Python 3.10.13. Timings are specific to this machine, trace mode, and workload. They include ordinary system variation and should be compared on the same machine. Three repetitions and two input orders do not establish statistical significance or broad dataset coverage.

## Scope for later work

This completes the initial static Smokes baseline. It remains a small six-person synthetic benchmark. Larger social graphs, low-attention bridge tests, retained attention, changing goals, concurrent goals, and new evidence belong to the later ECAN integration and dynamic evaluation. Preserve this version's cases and controls when adding those comparisons.
