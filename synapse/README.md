# Synapse Module

The `synapse` module is the evaluation and analysis layer for the ECAN
attention system. It records attention-state snapshots, keeps STI histories,
computes metrics over the current Attentional Focus and Hebbian graph, and
provides Python-backed helpers for community detection and topology analysis.

In practice, this module is used by experiments to answer questions like:

- how much of the total cognitive resource is held inside the Attentional Focus;
- how concentrated STI is compared with the whole AtomSpace;
- whether Hebbian links inside the focus are dense and internally connected;
- how stable the focus is across attention cycles;
- whether STI history and LTI are moving together;
- whether discovered modules are locally coherent and globally coordinated;
- how the current run compares with baseline efficiency and redundancy runs.

## Files

| File | Purpose |
| --- | --- |
| `synapse.metta` | Public MeTTa metric API. Defines CIP snapshots, metric collection, effectiveness, context retention, coordination, gained efficiency, redundancy degradation, and topology wrappers. |
| `utils.metta` | Shared MeTTa helpers for STI history, Hebbian link extraction, list math, entropy, Pearson correlation, module detection wrappers, and metric-list aggregation. |
| `community_detector.py` | Python helper that builds an `igraph` graph and detects dynamic modules using weighted multilevel community detection. |
| `topology_metrics.py` | Python helper that normalizes Hebbian links and computes clique-complex topology metrics: triangles and Betti numbers. |
| `test/synapse-test.metta` | Integration-style MeTTa assertions for CIP behavior, metrics, AF transitions, STI series, context retention, and module detection. |
| `test/test_community_detector.py` | Python unit tests for dynamic module detection. |
| `test/test_topology_metrics.py` | Python unit tests for graph normalization and topology metrics. |

`attention-bank/synapse/` currently only contains generated cache files. The
active source lives in the root `synapse/` directory.

## Main Concepts

### Cognitive Integration Periods

A Cognitive Integration Period, or CIP, is a snapshot of the cognitive state at
a meaningful boundary such as an agent cycle, batch boundary, diffusion round,
or any point where the Attentional Focus changes.

Snapshots are stored in `&cipspace` as:

```metta
(CIPSnapshot index timestamp af-atoms metrics)
```

The module also stores `(maxIndex n)` in `&cipspace` to track the latest CIP
index. This is used by functions such as `get-lattest-cip-index`,
`get-cip-snapshots`, and `transition-to-next-cip`.

The spelling `get-lattest-cip-index` is the current public function name in the
codebase.

### STI Series

The module records the STI history of each known atom in `&stiSeries`:

```metta
(atom (sti-at-current-cip sti-at-previous-cip ...))
```

`recordCipSeries` updates this history when a CIP is captured. If an atom did
not exist in earlier snapshots, the history is padded with zeros so STI series
for different atoms can still be compared.

These histories are used by temporal conjunction, coherence, and cognitive
synergy calculations.

### Hebbian Graph

The synapse metrics inspect Hebbian links stored in the shared ECAN `TypeSpace`.
The main link helpers are:

- `getHebLinks`: returns Hebbian links sourced from a supplied atom list;
- `getHebLinksWithValues`: returns those links together with their stored values;
- `getAllHebLinks` and `getAllHebLinksWithValues`: provided by the attention
  bank and used by the topology and module-detection code;
- `getLinkSource` and `getLinkTarget`: extract source and target atoms from
  plain links or valued link records.

## CIP Lifecycle

### `initialize-baseline-cip`

Creates the baseline snapshot at index `0`.

It captures:

- the current Attentional Focus from `getAfAtoms`;
- the current time from `current-time`;
- the full metric list from `measure-all-metrics`;
- the first STI history update through `recordCipSeries`.

This baseline is later used by global effectiveness calculations.

### `transition-to-next-cip`

Captures the next snapshot after attention agents or experiment steps have run.

The function:

1. updates the CIP index marker;
2. reads the current Attentional Focus;
3. computes the base metrics with `measure-all-metrics`;
4. stores a CIP snapshot in `&cipspace`;
5. computes `gainedEfficiency` and `redundancyDegradation` for the new index;
6. returns a `CIPSnapshot` that includes the base metrics plus the benchmarking
   metrics;
7. records the latest STI series.

The experiment logger writes the returned snapshot to `metrics.csv`. The stored
snapshot in `&cipspace` is used by later comparisons.

### CIP Read Helpers

- `get-cip-snapshots index`: returns the full snapshot for an index, or `()`.
- `get-cip-af index`: returns the AF atom list for an index, or `()`.
- `get-cip-af-or-empty index`: explicit empty-safe AF lookup.
- `baselineCip`: returns CIP index `0`.
- `has-cip-snapshots`: checks whether any CIP snapshots exist.
- `cip-af-series start end`: returns the AF list for every CIP in a range.

## Metrics

`measure-all-metrics` is the main collector. It returns a list of metric pairs
that can be stored inside a CIP snapshot and written to experiment output.

Current metric names:

```metta
(afResource ...)
(stiConcentration ...)
(fundSti ...)
(linkDensity ...)
(connectionRatio ...)
(preallocation ...)
(cognitiveSynergy ...)
(modulation ...)
(coordination ...)
(contextRetention ...)
(cognitiveMaintenance ...)
(effectiveness ...)
(triangleCount ...)
(betti0 ...)
(betti1 ...)
(betti2 ...)
```

### Resource Metrics

#### `getAfResourceUsage`

Measures how much of the known atom population is inside the Attentional Focus.

```text
afResource = number_of_AF_atoms / number_of_atoms_with_bins
```

Returns `0.0` when there are no known atoms.

#### `getStiConcentration`

Measures how much total STI is concentrated inside the Attentional Focus.

```text
stiConcentration = total_STI_in_AF / total_STI_in_all_atoms
```

Returns `0.0` when total STI is zero.

#### `getLinkDensity`

Measures how densely the current AF atoms are connected by outgoing Hebbian
links.

```text
linkDensity = hebbian_links_from_AF_atoms / (AF_size * (AF_size - 1))
```

Returns `0.0` when the AF is too small to form links.

#### `getTotalResourceCost`

Combines the resource-side metrics used by effectiveness and redundancy
calculations:

```text
resourceCost = afResource + stiConcentration + linkDensity
```

`fundSti` is recorded for visibility but is excluded from resource-cost and
performance-average calculations.

### Performance and Effectiveness

#### `averageMetricScore`

Computes the average of metric values that contribute to performance.

The following metric groups are excluded:

- topology metrics: `triangleCount`, `betti0`, `betti1`, `betti2`;
- `fundSti`;
- `effectiveness`.

This prevents topology placeholders, raw fund accounting, and prior
effectiveness values from restating the performance average.

#### `getAggregateMetricDelta`

Compares two CIPs by subtracting the baseline average metric score from the
current average metric score.

```text
aggregateMetricDelta = averageMetricScore(current) - averageMetricScore(baseline)
```

#### `calculateEffectiveness`

Computes performance gained per resource cost:

```text
effectiveness = aggregateMetricDelta / resourceCost
```

Returns `0.0` when resource cost is zero.

#### `getLocalEffectiveness`

Compares the latest CIP with the previous CIP.

#### `getGlobalEffectiveness`

Compares the latest CIP with CIP `0`.

#### `getEffectiveness`

Currently returns global effectiveness.

### Focus Stability Metrics

#### `getContextRetention previous current`

Computes Jaccard-style overlap between two AF atom lists.

```text
contextRetention = size(intersection(previous, current)) / size(union(previous, current))
```

Returns `0.0` for empty unions.

#### `getContextRetention`

Compares the latest stored CIP AF with the current `getAfAtoms` result.

#### `getCognitiveMaintenance`

Computes average context retention across the stored CIP AF series. It builds
the series with `cip-af-series 0 latest-index` and averages pairwise retention
between consecutive CIPs.

### Assessment Metrics

#### `getCognitiveSynergy`

Measures whether the system's short-term attention history aligns with current
long-term importance.

For all atoms with bins:

1. read the STI history from `getStiSeries`;
2. average each atom's STI history;
3. read each atom's current LTI;
4. compute Pearson correlation between averaged STI values and LTI values.

Returns `0.0` when there are no comparable values or the denominator is zero.

#### `getSelectionModulation`

Measures how unevenly STI is distributed across known atoms.

It computes the variance of current STI values and divides it by the uniform
variance implied by the current STI range:

```text
modulation = variance(STI values) / (((max(STI) - min(STI)) ^ 2) / 12)
```

Returns `0.0` when the denominator is zero.

#### `getConnectionRatio`

Measures how many Hebbian links sourced from AF atoms also point back into the
current AF.

```text
connectionRatio = internal_AF_link_count / total_AF_link_count
```

A link is internal when its target atom is present in the AF atom list.

### Audit Metrics

#### `getPreallocationSpace`

Measures the entropy of STI allocation across all known atoms. The current
implementation:

1. reads all atoms with bins;
2. collects their STI values;
3. shifts all values by subtracting the minimum STI;
4. normalizes the shifted values into a distribution;
5. computes Shannon entropy;
6. divides by `log2(number_of_atoms)`.

The result is high when STI is spread broadly and low when STI is concentrated
on fewer atoms.

### Coherence and Coordination Metrics

#### `measureCoherence atoms`

Measures internal coherence for a list of atoms.

It:

1. collects Hebbian links sourced by those atoms;
2. filters links whose targets are also in the atom list;
3. reads link probabilities with `getProbability`;
4. computes temporal conjunction for each link from STI history;
5. returns Pearson correlation between link probabilities and temporal
   conjunction values.

#### `getAfCoherence`

Runs `measureCoherence` over the current Attentional Focus.

#### `getGlobalCoordination state`

Measures coordination across a supplied atom state.

The function:

1. gets valued Hebbian links for the state;
2. finds modules with `identifyModules`;
3. computes local coherence for each module;
4. averages the local coherence scores;
5. filters inter-module links;
6. compares inter-module link probabilities with temporal conjunctions;
7. returns the geometric mean of local coherence and global coherence.

```text
coordination = sqrt(localCoherence * globalCoherence)
```

If the product is not positive, coordination returns `0.0`.

### Benchmarking Metrics

#### `getGainedEfficiency index`

Compares the current run's effectiveness against a baseline run loaded by the
experiment logger.

```text
gainedEfficiency =
  (current_effectiveness - baseline_effectiveness) / abs(baseline_effectiveness)
```

If the baseline effectiveness is zero, the function returns current
effectiveness.

#### `getRedundancyDegradation index`

Compares current performance and resource cost against a redundancy baseline.

The logger reads baseline rows from:

```text
experiments/output/<redundancy_baseline_name>/metrics.csv
```

The calculation reconstructs baseline cost and performance, then computes:

```text
redundancyDegradation = (baselinePerformance - currentPerformance) / costOverhead
```

where:

```text
currentCost = afResource + stiConcentration + linkDensity
currentPerformance = currentEffectiveness * currentCost
costOverhead = currentCost - baselineCost
```

Returns `0.0` when the baseline cost is zero or the overhead is effectively
zero.

### Topology Metrics

`topology_metrics.py` implements real graph-topology analysis. It accepts
MeTTa-style Hebbian links, plain Python pairs, and Hyperon-like atoms.

It computes:

- `triangles`: count of unique 3-cliques;
- `betti0`: number of connected components;
- `betti1`: number of unfilled 1-dimensional cycles;
- `betti2`: number of enclosed 2-dimensional voids.

The calculation treats the Hebbian graph as undirected, ignores duplicate
directions, skips self-loops as edges, and builds a clique complex. Betti
numbers are computed over mod-2 boundary ranks.

MeTTa wrappers:

```metta
(topologyMetrics)
(getTopologyTriangleCount metrics)
(getTopologyBetti0 metrics)
(getTopologyBetti1 metrics)
(getTopologyBetti2 metrics)
```

`topology_metric_values` returns values in this MeTTa-friendly order:

```text
(triangles betti0 betti1 betti2)
```

Current integration note: `measure-all-metrics` has the live topology calls
commented out and currently emits placeholder values of `1` for
`triangleCount`, `betti0`, `betti1`, and `betti2`. The Python topology helper and
MeTTa wrapper are implemented, but automatic CIP metric wiring is not fully
enabled in the current source.

## Community Detection

`community_detector.py` provides dynamic module detection through `igraph`.

### `get_dynamic_modules(af_atoms, af_links)`

Builds an undirected graph from the supplied AF atoms and valued Hebbian links,
then runs weighted multilevel community detection.

Behavior:

- supplied AF atoms are always added as graph vertices;
- unlinked AF atoms become singleton modules;
- nested atoms are converted to S-expression strings;
- STV records such as `["STV", mean, confidence]` are converted to weights with
  `mean * confidence`;
- links with explicit numeric weights are supported;
- links with missing weights default to `0.5`;
- self-loops and non-positive weights do not connect modules;
- if community detection fails, connected components are returned as a fallback.

### `get_dynamic_hebbian_modules(hebbian_links)`

Runs the same module detection over all supplied Hebbian links without first
seeding the graph with AF atoms.

MeTTa wrappers:

```metta
(identifyModules state afLinks)
(identifyHebbianModules hebbianLinks)
(identifyAllHebbianModules)
```

## Experiment Integration

`experiments/experiment.metta` imports the synapse module and uses it around the
attention loop.

Typical flow:

```metta
!(import! &self ../synapse/utils)
!(import! &self ../synapse/synapse)
!(import! &self "../synapse/topology_metrics.py")

!(start-log (attentionParam) "current_experiment" "effectiveness_baseline_1" "redundancy_baseline_1")
!(initialize-baseline-cip)

(= (logcurrCip)
    (let* (
            ($cip (transition-to-next-cip))
            ((CIPSnapshot $index $time $af_atoms $metrice) $cip)
        )
        (write_cip_wrapper $index $time $af_atoms $metrice)
    )
)
```

During the experiment, each read step stimulates an atom. At batch boundaries,
the ECAN agents run through `agent-runner`. After each step, `logcurrCip`
captures the current CIP and writes the metrics row.

Logger output is written under:

```text
experiments/output/<run_name>/
```

The key files are:

- `settings.json`: attention parameters used by the run;
- `output.csv`: optional AF snapshots;
- `metrics.csv`: CIP metric rows, including the AF atoms for each row.

The metric logger normalizes MeTTa metric names to snake_case CSV columns. For
example, `afResource` becomes `af_resource`, and `gainedEfficiency` becomes
`gained_efficiency`.

## Importing

For local module work, import the helpers directly after registering
`metta-attention` as a library:

```metta
!(import! &self (library metta-attention synapse/community_detector.py))
!(import! &self (library metta-attention synapse/topology_metrics.py))
!(import! &self (library metta-attention synapse/utils))
!(import! &self (library metta-attention synapse/synapse))
```

For full ECAN usage, the root `lib.metta` imports the synapse module together
with the attention bank, agents, logger, and shared helpers:

```metta
!(import! &self (library metta-attention lib))
```

## Running Tests

Install repository dependencies first:

```sh
pip install -r requirments.txt
```

Run the Python unit tests from the repository root:

```sh
python -m unittest discover -s synapse/test -p 'test_*.py'
```

Run the MeTTa synapse integration test through PeTTa:

```sh
cd ../PeTTa
sh run.sh ../metta-attention/synapse/test/synapse-test.metta -s
```

The MeTTa test registers the local repository as a library, imports the ECAN
attention modules, creates a small incident space, stimulates atoms, runs the
agent runner, initializes CIPs, and checks the expected metric behavior.

## Development Notes

- The module was moved to the root `synapse/` directory so it can be reused
  independently from `attention-bank/`.
- Dynamic logging was added so every CIP can be written to `metrics.csv` with a
  stable column order.
- Baseline comparison support was added for effectiveness, gained efficiency,
  and redundancy degradation.
- Community detection uses `igraph` multilevel clustering and supports both
  plain weighted links and valued STV records.
- Topology metrics are implemented and tested in Python, but automatic topology
  metric collection inside `measure-all-metrics` is currently disabled by
  comments and replaced by placeholder values.
- `averageMetricScore` intentionally excludes topology metrics, `fundSti`, and
  `effectiveness` from the performance average.
- STI history padding allows atoms that appear later in a run to be compared
  against atoms that were present from the beginning.
