# ECAN + MeTTaClaw Fluid Attention Experiment

Guide for configuring, running, and evaluating the **ECAN fluid attention** simulation with a **detached MeTTaClaw** goal-setting agent (OpenRouter / Anthropic / OpenAI).

This directory is the MeTTaClaw-driven experiment. The vanilla baseline (no claw) lives one level up at `experiments/experiment.metta`.

---

## 1. System Architecture

ECAN owns the main thread. MeTTaClaw runs on a detached SWI-Prolog thread and exchanges goals through `&goalspace` under a mutex:

```text
┌────────────────────────────────────────────────────────────────────────┐
│ Main Simulation Thread (ECAN + SYNAPSE)                                │
│                                                                        │
│  [Sensory Stimulus] ──► [AtomSpace] ──► [Rent Collection]              │
│                                │                                       │
│                                ▼                                       │
│                      [Importance Diffusion]                            │
│                                │                                       │
│                                ▼                                       │
│                 [Navier-Stokes Fluid Transport] ◄───┐                  │
│                                │                    │                  │
│                                ▼                    │                  │
│                 [SYNAPSE Metric Calculation]        │ (Sets Fluid      │
│                     (M, CS, CR, AF, Entropy)        │  Drains/Sinks)   │
└────────────────────────────────┼────────────────────┼──────────────────┘
                                 │                    │
                      Reads State│                    │ Thread-Safe Mutex
                                 ▼                    │ (&goalspace)
┌─────────────────────────────────────────────────────┼──────────────────┐
│ Detached Executive Thread (MeTTaClaw)               │                  │
│                                                     │                  │
│   [Goal Rules Evaluator] ──► [LLM Inference] ───────┘                  │
│   (R1 BREAK / R2 SYNERGIZE   (OpenRouter /                             │
│    R3 SETTLE / R4 SHARPEN /   Anthropic / OpenAI)                      │
│    R5 EXPAND)                                                          │
└────────────────────────────────────────────────────────────────────────┘
```

### Cadence (important)

This is **asynchronous free-run**, not sequential per-CIP coupling:

| Side | Cadence |
| :--- | :--- |
| **ECAN** | Stimulates one atom at a time; runs a fluid/attention batch every `(batch) = 5` stimuli; logs a CIP every stimulus |
| **MeTTaClaw** | Detached loop: build prompt → LLM → `focus-attention` → `sleep (sleepInterval)` → repeat. Default `sleepInterval = 1` (seconds). Wall-clock between goals is mostly LLM latency + that sleep |

ECAN reads whatever goals are currently in `&goalspace` at batch time. The claw does not wait for CIP boundaries.

### Layout

```text
experiments/mettaclaw/
├── experiment.metta          # Runner (imports, thresholds, detach, batch loop)
├── README.md
└── utils/
    ├── detach_claw.pl        # Spawns claw on a detached thread; restarts after errors
    ├── goal_candidates.py    # GRAPH_FRONTIER buckets (EXPAND / BREAK / SYNERGIZE)
    └── inject.py             # Makes fluidDiffusion/connection importable from PeTTa CWD
```

`inject.py` exists because this experiment is launched from `PeTTa/` (required for MeTTaClaw library/memory paths). The fluid solver's `connection.py` import is written relative to `experiments/` as CWD, so without `inject.py` the first fluid step fails with `ModuleNotFoundError: connection`. The baseline experiment does not need this file because it is typically run with a different working-directory layout.

---

## 2. Prerequisites & Setup

### Requirements
* **Python 3.10+** with the `.ECAN` virtual environment (`metta-attention/.ECAN`)
* **SWI-Prolog** (v9.0+) with Janus Python bridge
* An **OpenRouter**, **OpenAI**, or **Anthropic** API key
* MeTTaClaw on branch [`expt4/decision_policy`](https://github.com/abelfx/mettaclaw/tree/expt4/decision_policy)

### Setup
```bash
cd PeTTa
source ../metta-attention/.ECAN/bin/activate

# Fresh clone:
git clone -b expt4/decision_policy https://github.com/abelfx/mettaclaw.git repos/mettaclaw

# Or switch an existing checkout:
cd repos/mettaclaw
git fetch https://github.com/abelfx/mettaclaw.git expt4/decision_policy
git checkout expt4/decision_policy
cd ../..
```

---

## 3. Provider Configuration

Edit `PeTTa/repos/mettaclaw/src/loop.metta` (`initLoop`):

```metta
(configure LLM openai/gpt-oss-20b:free)     ; Model name
(configure provider OpenRouter)             ; OpenRouter | OpenAI | Anthropic
(configure sleepInterval 1)                 ; Seconds between claw iterations
(configure wakeupInterval 5)                ; Wake gate after loop budget exhausts
```

| Provider | `provider` setting | Required env vars | Model source |
| :--- | :--- | :--- | :--- |
| **OpenRouter** | `OpenRouter` | `OPENROUTER_API_KEY` | `LLM` in `loop.metta`; optional override `OPENROUTER_MODEL` |
| **Anthropic** | `Anthropic` | `ANTHROPIC_API_KEY` | Claude path in `lib_llm_ext` / loop |
| **OpenAI** | `OpenAI` | `OPENAI_API_KEY` | `useGPT` path in loop |

For OpenRouter free-tier runs, set both `OPENROUTER_API_KEY` and `OPENAI_API_KEY` to the same OpenRouter key (some client paths still read `OPENAI_API_KEY`). Unused providers can be set to `dummy`.

---

## 4. How to Run

Always launch from **`PeTTa/`**:

```bash
cd PeTTa && \
    source ../metta-attention/.ECAN/bin/activate && \
    OPENAI_API_KEY="sk-or-v1-xxxxxxxx" \
    OPENROUTER_API_KEY="sk-or-v1-xxxxxxxx" \
    ASI_API_KEY="dummy" \
    ANTHROPIC_API_KEY="dummy" \
    sh run.sh ../metta-attention/experiments/mettaclaw/experiment.metta | tee output_1.txt
```

Or with exported env vars:

```bash
cd PeTTa
source ../metta-attention/.ECAN/bin/activate

export OPENAI_API_KEY="sk-or-v1-xxxxxxxx"
export OPENROUTER_API_KEY="sk-or-v1-xxxxxxxx"
export OPENROUTER_MODEL="openai/gpt-oss-20b:free"   # optional override
export ASI_API_KEY="dummy"
export ANTHROPIC_API_KEY="dummy"

sh run.sh ../metta-attention/experiments/mettaclaw/experiment.metta | tee output_1.txt
```

### What healthy output looks like
* ECAN: `(read-step N word …)`, `fluid diagnostics: … goal_mass=…` (nonzero `goal_mass` means drains are active)
* Claw: `(---------iteration N)`, `(RESPONSE: ((pin "R…") (focus-attention …)))`, `Goals set: …`
* Bad: `MettaClaw detached thread error: …` then `MettaClaw restarting in 15s...` — claw crashed; ECAN may keep running without fresh goals. Rate limits are transient; `FileNotFoundError` / `ModuleNotFoundError` usually mean a path bug.

---

## 5. Goal-Setting Decision Policies (`GOAL_RULES`)

On each claw iteration the prompt carries live SYNAPSE metrics and candidate lists. The LLM should apply the **first matching rule**:

| Rule | Trigger Condition | Candidate Source | Action |
| :--- | :--- | :--- | :--- |
| **`R1 BREAK`** | `modulation > 0.60` | `GRAPH_FRONTIER (BREAK)` | Disperse a concentrated trap: pick 2 distant out-of-AF nodes |
| **`R2 SYNERGIZE`** | `cognitiveSynergy < 0.60` | 1 from AF + 1 from `GRAPH_FRONTIER (SYNERGIZE)` | Bridge active focus to high-LTI / LTM-aligned nodes |
| **`R3 SETTLE`** | `afResource > 0.80` OR `contextRetention < 0.70` | AF (low STI) | Capacity overflow or churn: stabilize starved members |
| **`R4 SHARPEN`** | `modulation < 0.25` OR `preallocationSpace > 0.90` | AF (high STI) | Diffuse / high-entropy focus: concentrate on top STI |
| **`R5 EXPAND`** | Otherwise | `GRAPH_FRONTIER (EXPAND)` | Grow the frontier to AF-adjacent out-of-AF nodes |

Thresholds are configurable in `experiment.metta` (see below). Occasional rule mis-picks are expected with small free models; that is prompt policy noise, not a broken rule engine.

---

## 6. Experiment Parameters

In `experiment.metta`:

```metta
(= (batch) 5)                       ; ECAN fluid/attention batch every N stimuli

(= (useDynamicFrontier) False)      ; False = static fluid graph; True = + live Hebbian

(= (thresholdBreak) 0.60)           ; R1
(= (thresholdSynergy) 0.60)         ; R2
(= (thresholdAfResource) 0.80)      ; R3
(= (thresholdSettle) 0.70)          ; R3
(= (thresholdSharpen) 0.25)         ; R4
(= (thresholdEntropyHigh) 0.90)     ; R4

!(start-log (attentionParam) "current_experiment" "fluid_integration" "redundancy_baseline_1")
```

Rename the `"current_experiment"` argument if you want a fresh output folder under `experiments/output/`.

---

## 7. Metrics & Output Files

With the default `start-log` name, outputs land here:

| Artifact | Path (from `PeTTa/`) |
| :--- | :--- |
| SYNAPSE metrics | `../metta-attention/experiments/output/current_experiment/metrics.csv` |
| ECAN stimulus / AF log | `../metta-attention/experiments/output/current_experiment/output.csv` |
| Run settings | `../metta-attention/experiments/output/current_experiment/settings.json` |
| Claw decision history | `repos/mettaclaw/memory/history.metta` |

### SYNAPSE metric used glossary

| Metric | Description | Typical target band |
| :--- | :--- | :--- |
| **`modulation` ($M$)** | $\mathrm{Var}(STI) / \mathrm{Var}_{\mathrm{uniform}}(STI)$ — focus peakedness | $\approx 0.25$–$0.60$ |
| **`cognitiveSynergy` ($CS$)** | Corr(STI, LTI) — working memory vs long-term importance | $\ge 0.60$ |
| **`contextRetention` ($CR$)** | Jaccard $|AF_t \cap AF_{t-1}| / |AF_t \cup AF_{t-1}|$ | $\ge 0.70$ |
| **`afResource` ($AF_{Res}$)** | $|AF| / \mathrm{MAX\_AF\_SIZE}$ | $\le 0.80$ |
| **`preallocation`** | Normalized Shannon entropy of STI | $\le 0.90$ |
---
