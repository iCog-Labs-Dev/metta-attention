# Thompson Sampling Strategy Selection

A contextual bandit approach to ECAN attention strategy selection using Thompson
sampling. Maintains a Beta posterior per (strategy, conduciveness-bin) and picks
the strategy with the highest sampled reward.

## Files

| File | Purpose |
|------|---------|
| `thompson.metta` | Core bandit: posterior storage, scoring, selection, reward |
| `thompson_experiment.metta` | Main runner: imports, config, batch loop, logging |
| `thompson_stimulus.metta` | ECAN stimulus: novelty, conduciveness, risk, effort |
| `thompson_utils.metta` | Python bridge: mean, std, randomBeta, seedRandom |
| `thompson_utils.py` | Python implementations (numpy) |

## Strategies

Three attention strategies:
- **narrow-focus**: 4 in-AF atoms
- **expand-focus**: 2 in + 2 out
- **explore-novel**: 4 out-of-AF atoms

## Contextual bandit

AF activation is binned to make the bandit state-dependent:

| Bin | Condition |
|-----|-----------|
| low | mean STI ≤ 0.36 |
| mid | 0.36 < mean STI ≤ 0.65 |
| high | mean STI > 0.65 |

Each (strategy, bin) pair has a Beta(α, β) posterior stored in `&tsState`.

**Selection**: sample from each posterior, pick highest.
**Update**: reward ∈ [0,1] → α += reward, β += (1 − reward).

## Reward

```
raw = 0.6 × conduciveness_improvement + 0.4 × (1 − effort)
differentialReward = clamp01(raw − baseline + 0.5)
baseline: EMA with α = 0.1
```

## Stimulus

4-tuple `(novelty conduciveness risk effort)`:
- **Novelty**: weighted new atoms in AF vs previous snapshot
- **Conduciveness**: `getSelectionModulation`
- **Risk**: coefficient of variation of AF STI
- **Effort**: `getEffectiveness`

## Run it

```bash
cd metta-attention
source .venv/bin/activate
PYTHONPATH="/path/to/MetaMo/core:$PYTHONPATH" timeout 60 sh ../PeTTa/run.sh \
  ../metta-attention/thompson/thompson_experiment.metta
```
