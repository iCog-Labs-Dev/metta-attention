# Synapse Metrics Reference

All metrics are computed in `synapse.metta` via `measure-all-metrics` and recorded in CIP (Cognitive Integration Period) snapshots.

---

## Resource Cost Metrics

These represent the base cost of maintaining the current attentional state. Used as denominators in effectiveness calculations.

### `afResource`

```
afSize / totalAtoms
```

The fraction of all atoms currently residing in the Attentional Focus (AF). High values mean the system keeps a large working memory, which is expensive. Low values mean the AF is tightly focused.

### `stiConcentration`

```
afSti / totalSti
```

The fraction of the system's total STI (Short-Term Importance) that is locked inside the AF. High concentration means working memory dominates the attention budget — good for focused processing but starves the rest of the graph. Low means attention is spread thin.

### `linkDensity`

```
actualHebbianLinks / (afSize * (afSize - 1))
```

The density of HebbianLinks among AF atoms, measured against the maximum possible directed links (`n * (n-1)`). High values mean a richly interconnected AF (good for spreading activation). Low values mean AF atoms are loosely connected.

---

## Phase I: Assessment

### `connectionRatio`

```
internalHebbianLinks / totalHebbianLinksFromAF
```

Of all HebbianLinks emanating from AF atoms, what fraction target other AF atoms (internal) vs. atoms outside the AF (external). High = the AF forms a coherent, self-connected cluster. Low = AF atoms are mostly linking outward (leaky AF).

### `cognitiveSynergy`

```
pearsonCorrelation(meanSTI_per_atom, currentLTI_per_atom)
```

Pearson correlation across all atoms between each atom's time-averaged STI (across its STI history) and its current LTI. High positive correlation (near 1.0) means short-term usage aligns with long-term value — the system's short-term and long-term memory are in sync. Negative correlation means the system spends STI on things it doesn't value long-term, or has high LTI on unused atoms.

### `selectionModulation`

```
variance(STI) / maxVarianceUniform(STI)
```

How unevenly STI is spread across all atoms. The denominator is the variance of a uniform distribution over the same range (`(max-min)²/12`). Near 1.0 = STI is uniform (no focus). Above 1 = STI is concentrated on a few atoms (strong selective focus). Near 0 = all atoms have nearly identical STI.

### `globalCoordination`

```
sqrt(localCoherence * globalCoherence)
```

Geometric mean of two sub-metrics:

- **Local coherence**: For each community/module detected in the AF, the Pearson correlation between Hebbian link probabilities and temporal conjunctions (STI time-series products) of atoms within that module. High = module atoms activate coherently together.
- **Global coherence**: The same correlation, but computed across inter-module links. High = modules interact coherently.

The geometric mean rewards balance — you need both internal module harmony and cross-module integration.

---

## Phase II: Audits

### `preallocationSpace`

```
shannonEntropy(normalizedSTI) / log2(totalAtoms)
```

Normalized entropy of the STI distribution. Entropy is divided by the maximum possible entropy (`log₂(N)`, the uniform distribution). Near 1 = STI is spread evenly (no prioritization). Near 0 = a tiny number of atoms hold almost all STI (extreme focus). Measures how much of the "attention space" is already committed.

---

## Phase III: Test Probing

### `contextRetention`

```
|AF_prev ∩ AF_curr| / |AF_prev ∪ AF_curr|
```

Jaccard similarity between consecutive CIP snapshots. 1.0 = the AF is completely stable (same atoms). 0.0 = completely different atoms. Measures attentional **stability vs. volatility** from one cycle to the next.

### `cognitiveMaintenance`

```
mean(contextRetention) over all consecutive CIP pairs
```

The average Jaccard similarity across every adjacent CIP snapshot over the entire run. High values mean the system maintains a stable working memory over time. Low values mean the AF churns rapidly — atoms come and go every cycle. The long-term stability counterpart of `contextRetention`.

---

## Phase IV: Benchmarking

### `effectiveness`

```
(averageMetricScore(current) - averageMetricScore(baseline)) / totalResourceCost(current)
```

The change in overall metric score per unit of resource cost.

- **`averageMetricScore`**: mean of all non-topology metrics (afResource, stiConcentration, linkDensity, connectionRatio, preallocation, cognitiveSynergy, modulation, coordination, contextRetention, cognitiveMaintenance).
- **`totalResourceCost`**: `afResource + stiConcentration + linkDensity`.

Two variants:
- **Local** (default): change from the *previous* CIP to the current one — marginal gain per cycle.
- **Global**: change from CIP 0 (baseline) to the latest — total gain since start.

Positive = the cognitive state is improving faster than resources are consumed.

### `gainedEfficiency`

```
(optimizedEff - baselineEff) / |baselineEff|
```

Relative improvement in effectiveness at a given CIP index compared to a stored baseline. Measures efficiency gains from tuning or learning.

### `redundancyDegradation`

```
(baselinePerf - currPerf) / overhead
```

How much performance was lost per unit of extra cost. Positive when the system spends more resources but gets less cognitive performance back. Measures the cost of redundancy.

---

## Topological Analysis (Python)

Computed from the clique complex of the undirected Hebbian graph. See `topology_metrics.py` for implementation (mod-2 persistent homology).

### `triangleCount`

Number of unique 3-cliques (triangles) in the Hebbian graph. Triangles represent transitive associative triples — if A↔B, B↔C, and A↔C all have strong links. More triangles = more redundant associative pathways = robust spreading activation.

### `betti0`

Number of connected components in the Hebbian graph. 1 = the entire graph is one connected component (good for global spreading). Higher values = isolated clusters — attention cannot flow between them.

### `betti1`

Number of 1-dimensional holes in the clique complex. Cycles in the graph that aren't "filled in" by triangles. High betti1 means loose circular pathways exist without direct diagonal associations — information can flow around loops but missing connections limit integration.

### `betti2`

Number of 2-dimensional voids — empty cavities enclosed by triangles (tetrahedron shells without the interior). High betti2 means the graph has hollow higher-order structures — atoms are triangle-connected but not fully integrated into 4-cliques.

---

## Summary Table

| Metric | What it signals when *high* |
|---|---|
| `afResource` | Expensive working memory (lots of atoms in AF) |
| `stiConcentration` | STI is locked in AF, rest of graph starved |
| `linkDensity` | Richly connected working memory |
| `connectionRatio` | AF is a coherent cluster, not leaky |
| `cognitiveSynergy` | STI and LTI are aligned (good memory integration) |
| `selectionModulation` | STI is highly concentrated on few atoms (strong focus) |
| `preallocationSpace` | STI is spread evenly (no prioritization) |
| `contextRetention` | Working memory is stable across cycles |
| `cognitiveMaintenance` | Consistently stable AF over entire run |
| `coordination` | Modules are internally coherent AND well-integrated |
| `effectiveness` | Good cognitive performance per unit resource cost |
| `triangleCount` | Rich transitive associative structure |
| `betti0` | Graph is fragmented (isolated clusters) |
| `betti1` | Many unfilled cycles (missing diagonal associations) |
| `betti2` | Hollow higher-order structure (missing tetrahedral integration) |
