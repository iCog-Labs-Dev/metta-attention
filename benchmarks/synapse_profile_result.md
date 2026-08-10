# Profile Results

Only application-level functions are shown (Prolog built-ins and MeTTa runtime internals excluded).


## 1. Synapse

| Function                  | Calls     | Self Time     | Children Time | Total Time    |
|---------------------------|-----------|---------------|---------------|---------------|
| `janus:py_call` (Python)  | 17        | 2.61s (35.5%) | 0.05s ( 0.6%) | 2.66s (36.1%) |
| `getHebLinks`             | 1,009     | 0.01s ( 0.2%) | 0.03s ( 0.4%) | 0.04s ( 0.6%) |
| `zipMultiply`             | 200       | 0.02s ( 0.2%) | 0.00s ( 0.0%) | 0.02s ( 0.2%) |



## 2. Synapse Utils

| Function                  | Calls     | Self Time     | Children Time | Total Time    |
|---------------------------|-----------|---------------|---------------|---------------|
| `profileUpdateAtomHistory`| 1         | 0.01s ( 0.3%) | 0.55s (13.4%) | 0.56s (13.7%) |
| `profilePearsonCorrelation`| 1        | 0.01s ( 0.3%) | 0.46s (11.2%) | 0.47s (11.5%) |
| `updateAtomHistory`       | 2,001     | 0.01s ( 0.2%) | 0.45s (11.0%) | 0.46s (11.2%) |
| `getValueType`            | 21,023    | 0.00s ( 0.1%) | 0.30s ( 7.2%) | 0.30s ( 7.3%) |
| `getAv`                   | 21,012    | 0.00s ( 0.1%) | 0.30s ( 7.3%) | 0.30s ( 7.4%) |
| `pearsonCorrelationLists` | 1,000     | 0.01s ( 0.2%) | 0.16s ( 3.9%) | 0.17s ( 4.1%) |
| `shanon-entropy`          | 1,000     | 0.01s ( 0.2%) | 0.10s ( 2.4%) | 0.11s ( 2.6%) |
| `meanDiff`                | 3,000     | 0.00s ( 0.1%) | 0.07s ( 1.8%) | 0.07s ( 1.9%) |
| `getHebLinks`             | 1,001     | 0.01s ( 0.3%) | 0.02s ( 0.4%) | 0.03s ( 0.7%) |
| `profileGetHebLinks`      | 1         | 0.00s ( 0.1%) | 0.03s ( 0.7%) | 0.03s ( 0.8%) |
| `variance-uniform`        | 2,000     | 0.01s ( 0.3%) | 0.02s ( 0.4%) | 0.03s ( 0.7%) |
| `zipMultiply`             | 1,001     | 0.00s ( 0.1%) | 0.02s ( 0.4%) | 0.02s ( 0.5%) |
| `getHebLinksWithValues`   | 1,200     | 0.01s ( 0.3%) | 0.00s ( 0.1%) | 0.01s ( 0.4%) |
| `log-math`                | 5,005     | 0.01s ( 0.2%) | 0.00s ( 0.1%) | 0.01s ( 0.3%) |



## 3. Synapse Tentative Ratio 
- No application-level functions exceeded 0.00s self time.
