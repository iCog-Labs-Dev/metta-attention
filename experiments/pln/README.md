# PLN experiments

[baseline/](baseline/README.md) contains the PLN-only Smokes benchmark: cases, configurations, runners, metrics, and tests. See its README for setup, run commands, and the seven-file matrix output format.

Generated baseline output belongs in `experiments/output/pln/baseline/`. The parent output directory's `.gitignore` excludes generated data from version control.

Future ECAN–PLN integration work will live beside `baseline/` and reuse its evaluation cases and metric definitions for matched comparisons.
