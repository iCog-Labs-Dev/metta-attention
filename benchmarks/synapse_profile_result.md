# Profile Results

Only application-level functions and direct Python FFI are shown (Prolog built-ins and MeTTa runtime internals excluded).

### Synapse Overview

| Synapse Component | Total Time | 
|-------------------|------------|
| **Synapse** | **18.109s** |
| **Synapse Utilities** | **4.114s** |
| **Synapse Tentative Ratio** | **0.225s** |
| **Total Synapse Suite** | **22.448s** |


## 1. Synapse

| Function                  | Calls     | Self Time     | Children Time | Total Time    |
|---------------------------|-----------|---------------|---------------|---------------|
| `get-cip-snapshots`       | 11,400    | 0.06s ( 0.3%) | 6.43s (35.5%) | 6.49s (35.8%) |
| `janus:py_call/2` (Python)| 17        | 2.36s (13.0%) | 0.05s ( 0.3%) | 2.41s (13.3%) |
| `resolve_memoization`     | 90,110    | 0.04s ( 0.2%) | 0.06s ( 0.3%) | 0.10s ( 0.5%) |
| `get-lattest-cip-index`   | 2,401     | 0.06s ( 0.3%) | 0.01s ( 0.1%) | 0.07s ( 0.4%) |
| `janus:py_call/3`         | 201       | 0.04s ( 0.2%) | 0.00s ( 0.0%) | 0.04s ( 0.2%) |
| `janus:py_initialize_/3`  | 1         | 0.03s ( 0.2%) | 0.00s ( 0.0%) | 0.03s ( 0.2%) |



## 2. Synapse Utils

| Function                  | Calls     | Self Time     | Children Time | Total Time    |
|---------------------------|-----------|---------------|---------------|---------------|
| `janus:py_call`           | 15        | 1.79s (43.6%) | 0.04s (1.1%)  | 1.83s (44.7%) |
| `profileUpdateAtomHistory`| 1         | 0.01s ( 0.3%) | 0.55s (13.4%) | 0.56s (13.7%) |
| `profilePearsonCorrelation`| 1        | 0.01s ( 0.3%) | 0.46s (11.2%) | 0.47s (11.5%) |
| `updateAtomHistory`       | 2,001     | 0.01s ( 0.2%) | 0.45s (11.0%) | 0.46s (11.2%) |
| `getValueType`            | 21,023    | 0.00s ( 0.1%) | 0.30s ( 7.2%) | 0.30s ( 7.3%) |
| `getAv`                   | 21,012    | 0.00s ( 0.1%) | 0.30s ( 7.3%) | 0.30s ( 7.4%) |
| `pearsonCorrelationLists` | 1,000     | 0.01s ( 0.2%) | 0.16s ( 3.9%) | 0.17s ( 4.1%) |
| `shanon-entropy`          | 1,000     | 0.01s ( 0.2%) | 0.10s ( 2.4%) | 0.11s ( 2.6%) |
| `meanDiff`                | 3,000     | 0.00s ( 0.1%) | 0.07s ( 1.8%) | 0.07s ( 1.9%) |
| `janus:py_call/3`         | 400       | 0.05s ( 1.2%) | 0.00s ( 0.0%) | 0.05s ( 1.2%) |
| `getHebLinks`             | 1,001     | 0.01s ( 0.3%) | 0.02s ( 0.4%) | 0.03s ( 0.7%) |
| `profileGetHebLinks`      | 1         | 0.00s ( 0.1%) | 0.03s ( 0.7%) | 0.03s ( 0.8%) |
| `variance-uniform`        | 2,000     | 0.01s ( 0.3%) | 0.02s ( 0.4%) | 0.03s ( 0.7%) |
| `zipMultiply`             | 1,001     | 0.00s ( 0.1%) | 0.02s ( 0.4%) | 0.02s ( 0.5%) |
| `getHebLinksWithValues`   | 1,200     | 0.01s ( 0.3%) | 0.00s ( 0.1%) | 0.01s ( 0.4%) |
| `log-math`                | 5,005     | 0.01s ( 0.2%) | 0.00s ( 0.1%) | 0.01s ( 0.3%) |



## 3. Synapse Tentative Ratio 
- No application-level functions exceeded 0.001s self time.
> - All 500 iterations of `profileTentativeRatio` executed in under **0.225 seconds total**.


## 4. Synapse Topology Metrics (Python)

| Function | Calls | Avg Time | Min Time | Total Time |
|--------------------|-------|----------|----------|------------|
| `Full Metrics` (`topology_metric_values`) | 200 | 31.21 ms | 27.50 ms | 6.242s |
| `Full Dictionary` (`topology_metrics`) | 200 | 30.93 ms | 27.46 ms | 6.185s |
| `Nested S-Exp Parsing & Topology` | 200 | 29.26 ms | 25.94 ms | 5.852s |
| `Edge Normalization` (`_normalize_edges`) | 200 | 6.26 ms | 5.23 ms | 1.252s |
| `Triangular Mesh Invariants` | 200 | 1.02 ms | 0.77 ms | 0.204s |


## 5. Synapse Community Detector (Python)

| Function | Calls | Avg Time | Min Time | Total Time |
|--------------------|-------|----------|----------|------------|
| `get_dynamic_modules` *(AF-scoped)* | 200 | 6.33 ms | 4.42 ms | 1.265s |
| `get_dynamic_hebbian_modules` *(Global)* | 200 | 5.42 ms | 4.48 ms | 1.084s |