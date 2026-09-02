# Motivated Experiment

An integration between MetaMo's motivational decision cycle and the ECAN attention system. Every `(batch) = 5` stimulus events, the system inspects the current attentional focus (AF), derives a motivational stimulus from it, lets two subsystems (cautious and curious) vote over three attention strategies, picks a winner by consensus, and runs an ECAN fluid simulation seeded by the chosen strategy — whose execution then nudges the subsystems' goals for the next cycle.

## 1. Top-level cycle (`runMotivatedBatch`, `experiment.metta:138-162`)

1. Read the current cautious/curious states from `&metamoState`.
2. Compute the ECAN stimulus from the current AF (`ecanStimulus`).
3. Run one MetaMo cycle (`runMetaMoCycleDefault`): appraise → per-subsystem scoring → consensus → winning strategy.
4. Log the chosen strategy + stimulus; run Hebbian superpose; run `applyFluidSimulation` seeded with `(applyStrategy $strategy)`; write next subsystem states back; snapshot the AF for novelty.

## 2. How `ecanStimulus` is calculated

4-tuple `(novelty conduciveness risk effort)` (`stimulus.metta`), each defaulting to `0.5` on degenerate input:

| Component | Formula | Meaning | effect |
|---|---|---|---|
| **Novelty** | `1 − overlap/maxSize`; `overlap = |currentAF ∩ prevSnapshot|`, `maxSize = max(|currentAF|, |prevSnapshot|)` | How much the AF changed since the last batch | explore |
| **Conduciveness** | `getSelectionModulation` | Selection modulation signal | high→explore, mid→expand, low→narrow |
| **Risk** | `min(std(STI)/mean(STI), 1.0)` | Coefficient of variation of AF activation (uneven/spiky attention = risky) | narrow |
| **Effort** | `min(|AF|/MAX_AF_SIZE, 1.0)` | AF fullness (effective `MAX_AF_SIZE = 50.0`, overridden in `experiment.metta:58`) | narrow |

## 3. Strategies, goals, risk, deltaG

Static tuple in `config.metta`:

```
(action <id> (8 goalCorrelations) <riskEstimate> (8 deltaG))
```

| | goalCorrelations | riskEstimate | deltaG |
|---|---|---|---|
| **narrow-focus** | `(0.4 0.3 0.9 0.1 0.1 0.2 0.9 0.6)` | `0.2` | `(0.0 0.0 0.15 0.0 0.0 0.0 0.15 0.0)` |
| **expand-focus** | `(0.6 0.5 0.3 0.7 0.6 0.8 0.2 0.7)` | `0.35` | `(0.1 0.0 0.0 0.15 0.0 0.15 0.0 0.15)` |
| **explore-novel** | `(0.9 0.8 0.1 1.0 1.0 0.4 0.05 0.2)` | `0.6` | `(0.15 0.3 0.0 0.3 0.3 0.0 0.0 0.0)` |

- **riskEstimate** — scalar danger level; penalizes a subsystem's score in proportion to its caution.
- **deltaG** — the increment applied to a subsystem's goals after the strategy is chosen: damped ×0.9 (`C_CONTRACT`), added, clipped to [0,1], projected (`gInd ≥ 0.3`, goal vector within an L2 ball of radius 2). Strategies never change; deltaG only nudges subsystem goals.
- **Seeding** (`strategies.metta`): narrow-focus = 4 in-AF; expand-focus = 2 in + 2 out; explore-novel = 4 out.

### 3.x goalCorrelations — what they mean

A fixed 8-element list, one value per goal index (`GoalIndex` atoms, `openpsi/config.metta:9-16`):

```
index:   0      1      2      3      4      5      6      7
goal:   gInd  gTrans  gHelp  gCurio gNovel gSelf  gEthic gSoc
```

Each value answers: *how strongly does this strategy serve that goal?* It's static — never modified at runtime. It's read in **three** places inside `magusScore`:

**1. baseScore (6 of the 8 slots).** Only goals with a `goalModulatorRelevance` mapping (gHelp, gCurio, gNovel, gEthic, gSoc, gSelf) contribute. For each:
```
goalWeight(state) × avgRelevantModulator(state) × metaSupport(state) × corr[goalIdx]
```
The correlation is the *strategy's* vote; the state supplies the weights. **Important:** the `gInd` (0) and `gTrans` (1) slots are *not* read here — those two goals have no modulator mapping, so their correlation values currently don't affect the score.

**2. conflictPenalty (2 slots).** Only `corr[gCurio]` (3) × `corr[gEthic]` (6): if the product < −0.2, apply `exp(3·|product|)` as a penalty. So **negative correlations are meaningful** — they encode that a strategy serves curiosity by undermining ethics (or vice versa). All current strategies have positive values, so this never fires today.

**3. growthReward (3 slots).** Averages `corr[gCurio, gNovel, gSelf]` (indices 3,4,5) into the `growthScore`:
```
growthScore = 0.7 × max(0, mean(growth-corrs)) + 0.3 × mean(clip(10×deltaG[growth-idx]))
```
The stronger a strategy's growth-goal correlations, the more growth reward it can earn — but only if the subsystem's `gTrans`/arousal/approach are high enough to amplify it.

**Annotated current values** (`config.metta`):

| goal | narrow-focus | expand-focus | explore-novel |
|---|---|---|---|
| gInd (0) | 0.4 | 0.6 | **0.9** |
| gTrans (1) | 0.3 | 0.5 | **0.8** |
| gHelp (2) | **0.9** | 0.3 | 0.1 |
| gCurio (3) | 0.1 | 0.7 | **1.0** |
| gNovel (4) | 0.1 | 0.6 | **1.0** |
| gSelf (5) | 0.2 | **0.8** | 0.4 |
| gEthic (6) | **0.9** | 0.2 | 0.05 |
| gSoc (7) | 0.6 | **0.7** | 0.2 |

Reading: narrow-focus is an **ethics/social** strategy (0.9 gEthic, 0.9 gHelp, low 0.1 growth) → scores well for cautious. explore-novel is a **growth** strategy (1.0 gCurio/gNovel) → scores well for curious, but its risk 0.6 lets cautious's riskPenalty crush it. expand-focus is balanced with high gSelf (0.8) and moderate growth (0.7 gCurio).

**Why they matter:** the correlation is multiplied by the state's goal weight — a high correlation for a goal the subsystem doesn't value contributes almost nothing, and vice versa. That's the static-vs-dynamic split: strategies bring fixed "personalities," subsystems bring changing "needs," and the product is the vote.

## 4. How strategies and subsystems interact

Subsystems hold **goals** (8 priorities) and **modulators** (6: `valence arousal approach resolution threshold securing`). Cautious: high gEthic/gInd, high threshold/securing. Curious: high gTrans/gCurio/gNovel, high arousal/approach. Interaction is indirect: stimulus reshapes modulators → modulators weight strategy scores.

**Appraisal** updates only modulators (`appraisal_helpers.metta`): risk raises threshold/securing; novelty raises arousal/approach (discounted as `benignNovelty = novelty×(1−risk)`); conduciveness raises approach/resolution, lowers threshold/securing; effort mildly raises threshold/securing. Arousal/approach deltas scale by `exp(gTrans−0.5)`; threshold/securing by `exp(gInd−0.5)`.

## 5. magusScore — detailed walkthrough (`MetaMo/magus/decision.metta:113-142`)

```
score = baseScore − riskPenalty − conflictPenalty + growthReward
```

**Step 1 — meta-drive signals:** `indSignal = sigmoid((gInd−0.5)×6)`, `transSignal = sigmoid((gTrans−0.5)×6)`; `cautionSignal = avg(threshold, securing)`; `growthSignal = avg(arousal, approach)`.

**Step 2 — baseScore** = Σ over the 6 mapped goals (`gHelp gCurio gNovel gEthic gSoc gSelf`) of:
```
goalWeight × avg(relevant modulators) × metaSupport × goalCorrelation
```
where metaSupport = `0.5+0.5·indSignal` (individuation: gHelp, gEthic), `0.5+0.5·transSignal` (transcendence: gCurio, gNovel), `0.5+0.25·(ind+trans)` (dual: gSelf, gSoc).

**Step 3 — riskPenalty** `= 0.5 × gInd × cautionSignal × riskEstimate`.

**Step 4 — growthReward** `= 0.5 × gTrans × growthSignal × growthScore`, where `growthScore = 0.7·mean(corrs[gCurio,gNovel,gSelf]) + 0.3·mean(clip(10·deltaG[gCurio,gNovel,gSelf]))`.

**Step 5 — conflictPenalty**: `exp(3·|corr[gCurio]·corr[gEthic]|)` only if the product < −0.2, else 0.

**Worked example** — explore-novel `(0.9 0.8 0.1 1.0 1.0 0.4 0.05 0.2)`, risk 0.6, on initial states (pre-appraisal):

| term | cautious | curious |
|---|---|---|
| gInd / gTrans | 0.6 / 0.4 | 0.2 / 0.9 |
| indSignal / transSignal | 0.65 / 0.35 | 0.14 / 0.92 |
| caution / growth signal | 0.75 / 0.40 | 0.20 / 0.80 |
| gHelp term | 0.7·0.4·0.825·0.1 = 0.023 | 0.9·0.8·0.57·0.1 = 0.041 |
| gCurio term | 0.1·0.4·0.675·1.0 = 0.027 | 0.9·0.8·0.96·1.0 = 0.691 |
| gNovel term | 0.1·0.4·0.675·1.0 = 0.027 | 0.9·0.8·0.96·1.0 = 0.691 |
| gEthic term | 0.8·0.75·0.825·0.05 = 0.025 | 0.1·0.2·0.57·0.05 = 0.001 |
| gSoc term | 0.6·0.55·0.75·0.2 = 0.050 | 0.4·0.5·0.765·0.2 = 0.031 |
| gSelf term | 0.2·0.55·0.75·0.4 = 0.033 | 0.5·0.5·0.765·0.4 = 0.077 |
| **baseScore** | **0.185** | **1.532** |
| riskPenalty | 0.5·0.6·0.75·0.6 = 0.135 | 0.5·0.2·0.20·0.6 = 0.012 |
| growthReward | 0.5·0.4·0.40·0.86 = 0.069 | 0.5·0.9·0.80·0.86 = 0.310 |
| conflictPenalty | 0 (1.0·0.05 ≥ −0.2) | 0 |
| **magusScore** | **0.119** | **1.830** |

**Consensus** (`bimonad.metta:141-144`): `(s₁+s₂)/2 − 0.25×|s₁−s₂|` → explore-novel ≈ `0.547`. For contrast, narrow-focus scores ≈ 0.585 — narrow wins on the initial states because cautious's riskPenalty crushes explore-novel (0.135 vs 0.012) despite curious's enthusiasm. Scores are approximate; actual runs appraise the stimulus into modulators first.

The consensus winner's strategy seeds the fluid sim, and **each subsystem then applies its own locally-preferred action's deltaG to its own goals** (`computeNextStates`) — so cautious and curious drift apart over cycles.

## 6. Run it

```
cd metta-attention
source .venv/bin/activate
PYTHONPATH="/path/to/MetaMo/core:$PYTHONPATH" timeout 60 sh ../PeTTa/run.sh \
  ../metta-attention/motivated_experiment/experiment.metta
```
