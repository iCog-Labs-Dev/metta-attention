# Profile Results

Only application-level functions and direct Python FFI are shown (Prolog built-ins and MeTTa runtime internals excluded).

### Synapse Overview

| Synapse Component | Total Time | 
|-------------------|------------|
| **Synapse** | **24.949s** |
| **Synapse Utilities** | **4.114s** |
| **Synapse Tentative Ratio** | **0.600s** |
| **Total Synapse Suite** | **29.663s** |


## 1. Synapse

| Function | Calls | Self Time | Children Time | Total Time | % of Synapse |
|---|---|---|---|---|---|
| `get-cip-snapshots` | 11,400 | 0.09s ( 0.4%) | 8.35s (33.5%) | **8.44s** | 33.8% |
| `get-cip-af` | 7,000 | 0.02s ( 0.1%) | 5.09s (20.4%) | **5.11s** | 20.5% |
| `janus:py_call/2` (Python FFI) | 17 | 3.15s (12.6%) | 0.08s ( 0.3%) | **3.23s** | 12.9% |
| `profileCipAfSeries` | 2,001 | 0.01s ( 0.0%) | 2.92s (11.7%) | **2.93s** | 11.7% |
| `cip-af-series` | 2,500 | 0.02s ( 0.1%) | 2.90s (11.6%) | **2.92s** | 11.7% |
| `getGlobalEffectiveness` | 2,400 | 0.01s ( 0.0%) | 2.60s (10.4%) | **2.61s** | 10.5% |
| `map-atom` | 2,700 | 0.03s ( 0.1%) | 2.43s ( 9.7%) | **2.46s** | 9.9% |
| `getStiSeries` | 3,200 | 0.01s ( 0.0%) | 2.22s ( 8.9%) | **2.23s** | 8.9% |
| `profileGetEffectiveness` | 1,201 | 0.00s ( 0.0%) | 2.00s ( 8.0%) | **2.00s** | 8.0% |
| `getPreallocationSpace` | 500 | 0.02s ( 0.1%) | 1.58s ( 6.3%) | **1.60s** | 6.4% |
| `profileGetAggregateMetricDelta` | 1,001 | 0.01s ( 0.0%) | 1.44s ( 5.8%) | **1.45s** | 5.8% |
| `profileCalculateEffectiveness` | 1,001 | 0.00s ( 0.0%) | 1.39s ( 5.6%) | **1.39s** | 5.6% |
| `baselineCip` | 1,600 | 0.00s ( 0.0%) | 1.24s ( 5.0%) | **1.24s** | 5.0% |
| `has-cip-snapshots` | 1,400 | 0.00s ( 0.0%) | 0.98s ( 3.9%) | **0.98s** | 3.9% |
| `getAv` | 25,666 | 0.02s ( 0.1%) | 0.90s ( 3.6%) | **0.92s** | 3.7% |
| `getSti` | 24,057 | 0.02s ( 0.1%) | 0.89s ( 3.6%) | **0.91s** | 3.6% |
| `profileGetContextRetention` | 501 | 0.01s ( 0.0%) | 0.85s ( 3.4%) | **0.86s** | 3.4% |
| `profileGetMetricsFromSnapshot` | 501 | 0.03s ( 0.1%) | 0.78s ( 3.1%) | **0.81s** | 3.2% |
| `profileGetTotalResourceCost` | 501 | 0.00s ( 0.0%) | 0.79s ( 3.2%) | **0.79s** | 3.2% |
| `getStiConcentration` | 1,003 | 0.02s ( 0.1%) | 0.73s ( 2.9%) | **0.75s** | 3.0% |
| `profileHasCipSnapshots` | 501 | 0.01s ( 0.0%) | 0.71s ( 2.9%) | **0.72s** | 2.9% |
| `getAllAtomsWithBins` | 3,206 | 0.01s ( 0.0%) | 0.55s ( 2.2%) | **0.56s** | 2.2% |
| `getSelectionModulation` | 500 | 0.00s ( 0.0%) | 0.27s ( 1.1%) | **0.27s** | 1.1% |
| `intersection-atom` | 5,000 | 0.09s ( 0.4%) | 0.16s ( 0.6%) | **0.25s** | 1.0% |
| `resolve_memoization` | 90,110 | 0.04s ( 0.2%) | 0.15s ( 0.6%) | **0.19s** | 0.8% |
| `getAfResourceUsage` | 1,003 | 0.01s ( 0.0%) | 0.13s ( 0.5%) | **0.14s** | 0.6% |
| `pearsonCorrelationLists` | 200 | 0.01s ( 0.1%) | 0.13s ( 0.5%) | **0.14s** | 0.6% |
| `getHebLinks` | 1,009 | 0.05s ( 0.2%) | 0.04s ( 0.2%) | **0.09s** | 0.4% |
| `averageList` | 2,000 | 0.00s ( 0.0%) | 0.08s ( 0.3%) | **0.08s** | 0.3% |
| `getContextRetention` | 1,000 | 0.02s ( 0.1%) | 0.04s ( 0.2%) | **0.06s** | 0.2% |
| `getAfAtoms` | 4,019 | 0.00s ( 0.0%) | 0.06s ( 0.2%) | **0.06s** | 0.2% |
| `janus:py_call/3` | 201 | 0.05s ( 0.2%) | 0.00s ( 0.0%) | **0.05s** | 0.2% |
| `janus:py_initialize_/3` | 1 | 0.05s ( 0.2%) | 0.00s ( 0.0%) | **0.05s** | 0.2% |
| `calculateEffectiveness` | 1,600 | 0.00s ( 0.0%) | 0.05s ( 0.2%) | **0.05s** | 0.2% |
| `getAggregateMetricDelta` | 2,100 | 0.00s ( 0.0%) | 0.05s ( 0.2%) | **0.05s** | 0.2% |
| `getTotalResourceCost` | 2,100 | 0.03s ( 0.1%) | 0.01s ( 0.0%) | **0.04s** | 0.2% |
| `entropyTerm` | 4,000 | 0.03s ( 0.1%) | 0.01s ( 0.0%) | **0.04s** | 0.2% |
| `union-atom` | 59,366 | 0.00s ( 0.0%) | 0.04s ( 0.1%) | **0.04s** | 0.1% |
| `get-lattest-cip-index` | 2,401 | 0.02s ( 0.1%) | 0.01s ( 0.0%) | **0.03s** | 0.1% |
| `size-atom` | 15,516 | 0.02s ( 0.1%) | 0.01s ( 0.0%) | **0.03s** | 0.1% |
| `averageMetricScore` | 4,200 | 0.00s ( 0.0%) | 0.02s ( 0.1%) | **0.02s** | 0.1% |
| `car-atom` | 35,749 | 0.01s ( 0.1%) | 0.00s ( 0.0%) | **0.01s** | 0.0% |




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

| Function | Calls | Self Time | Children Time | Total Time | % of Benchmark |
|---|---|---|---|---|---|
| `janus:py_initialize_/3` (Python) | 1 | 0.08s (13.2%) | 0.00s (0.0%) | **0.08s** | 13.2% |
| `janus:py_call/1` (Python FFI) | 1 | 0.05s ( 8.2%) | 0.00s (0.0%) | **0.05s** | 8.2% |
| `profileTentativeRatio` | 1 | 0.00s ( 0.0%) | 0.01s (1.5%) | **0.01s** | 1.5% |
| `systemPerformance` | 1,500 | 0.00s ( 0.0%) | 0.00s (0.0%) | **<0.001s** | <0.1% |
| `getClipIndex` | 1,000 | 0.00s ( 0.0%) | 0.00s (0.0%) | **<0.001s** | <0.1% |
| `measureAllMetrics` | 1,000 | 0.00s ( 0.0%) | 0.00s (0.0%) | **<0.001s** | <0.1% |
| `cipCurrentTime` | 1,000 | 0.00s ( 0.0%) | 0.00s (0.0%) | **<0.001s** | <0.1% |
| `initializeBaselineClip` | 500 | 0.00s ( 0.0%) | 0.00s ( 0.0%) | **<0.001s** | <0.1% |
| `gainedEfficiency` | 500 | 0.00s ( 0.0%) | 0.00s ( 0.0%) | **<0.001s** | <0.1% |
| `resolve_memoization` | 746 | 0.00s ( 0.0%) | 0.00s ( 0.0%) | **<0.001s** | <0.1% |
| `getAttentionParam` | 18 | 0.00s ( 0.0%) | 0.00s ( 0.0%) | **<0.001s** | <0.1% |
| `getValueType` | 12 | 0.00s ( 0.0%) | 0.00s ( 0.0%) | **<0.001s** | <0.1% |
| `setAv` | 9 | 0.00s ( 0.0%) | 0.00s ( 0.0%) | **<0.001s** | <0.1% |
| `getAv` | 8 | 0.00s ( 0.0%) | 0.00s ( 0.0%) | **<0.001s** | <0.1% |



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