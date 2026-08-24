# Guide: Running ECAN + Mettaclaw Experiment with OpenRouter API

This guide describes how to configure and execute the **ECAN Attention + Mettaclaw Goal-Setting** experiment using cloud LLMs via the **OpenRouter API** (e.g. `openai/gpt-oss-20b:free`, `deepseek/deepseek-chat`, `meta-llama/llama-3.3-70b-instruct`, etc.).

---

## 1. Overview & Setup

In this configuration:
* **ECAN Fluid Simulation** runs locally inside PeTTa / MeTTa.
* **Mettaclaw Goal-Setting Agent** sends prompts over HTTPS to the OpenRouter API endpoint (`https://openrouter.ai/api/v1`).
* **Environment Variables** supply your OpenRouter API key and model selection.

---

## 2. Prerequisites

1. An **OpenRouter API Key** (from [openrouter.ai/keys](https://openrouter.ai/keys)).
2. The `.ECAN` Python virtual environment.

---

## 3. Configuration (Pre-configured in Codebase — Reference Only)

> These settings are already configured in the code. You do **not** need to edit any files if your goal is to simply run the experiment.

### 3.1 Provider in `loop.metta`
In [`/home/abel/Desktop/icog_labs/ECAN/PeTTa/repos/mettaclaw/src/loop.metta`](file:///home/abel/Desktop/icog_labs/ECAN/PeTTa/repos/mettaclaw/src/loop.metta):
Line 22 is pre-set to:
```metta
(configure provider OpenRouter)
```

### 3.2 Verify `lib_llm_ext.py`
In [`/home/abel/Desktop/icog_labs/ECAN/PeTTa/repos/mettaclaw/lib_llm_ext.py`](file:///home/abel/Desktop/icog_labs/ECAN/PeTTa/repos/mettaclaw/lib_llm_ext.py):
The OpenRouter client is initialized from your environment variables:
```python
OPENROUTER_CLIENT = openai.OpenAI(
    api_key=os.environ.get("OPENROUTER_API_KEY", ""),
    base_url="https://openrouter.ai/api/v1"
)

def useOpenRouter(content):
    return _chat(
        client=OPENROUTER_CLIENT,
        model=os.environ.get("OPENROUTER_MODEL", "openai/gpt-oss-20b:free"),
        content=content
    )
```

---

## 4. How to Run the Experiment

You can pass the API keys directly inline when executing `run.sh` (or export them):

### Option A: Inline Command (Single-Line)
```bash
cd /home/abel/Desktop/icog_labs/ECAN/PeTTa && \
    source ../metta-attention/.ECAN/bin/activate && \
    OPENAI_API_KEY="sk-or-v1-xxxxxxxx" \
    OPENROUTER_API_KEY="sk-or-v1-xxxxxxxx" \
    ASI_API_KEY="dummy" \
    ANTHROPIC_API_KEY="dummy" \
    sh run.sh ../metta-attention/experiments/experiment.metta
```

### Option B: Exporting Variables
```bash
cd /home/abel/Desktop/icog_labs/ECAN/PeTTa
source ../metta-attention/.ECAN/bin/activate

export OPENROUTER_API_KEY="sk-or-v1-xxxxxxxx"
export OPENROUTER_MODEL="openai/gpt-oss-20b:free"  # Default model

sh run.sh ../metta-attention/experiments/experiment.metta
```

---

## 5. Goal-Setting Control Rules (`GOAL_RULES`)

On each CIP, Mettaclaw reads the live state and applies the following 5-rule hierarchy:

### Rule Hierarchy Summary
| Rule | Trigger Condition | Source | Action & Purpose |
| :--- | :--- | :--- | :--- |
| **`R1 BREAK`** | `modulation > 0.60` | `GRAPH_FRONTIER` (distant) | **Disperse Vortex:** Disperses over-concentrated energy jets to distant nodes. |
| **`R2 SYNERGIZE`** | `cognitiveSynergy < 0.60` | `AF` (top STI) + `GRAPH_FRONTIER` (high LTI) | **Deep Integration:** Anchors active sensory attention into core long-term knowledge. |
| **`R3 SETTLE`** | `afResource > 0.80` OR `contextRetention < 0.70` | `CURRENT_ATTENTIONAL_FOCUS` (low STI) | **Memory Preservation:** Funds decaying concepts during capacity overload or batch churn. |
| **`R4 SHARPEN`** | `modulation < 0.25` OR `preallocationSpace > 0.90` | `CURRENT_ATTENTIONAL_FOCUS` (high STI) | **Concentrate Focus:** Sharpens diffuse fog or chaotic entropy onto top active hubs. |
| **`R5 EXPAND`** | *Otherwise* (Steady State) | `GRAPH_FRONTIER` (adjacent) | **Associative Growth:** Expands associative frontier to adjacent out-of-AF nodes. |

### 5.1 Goal-Candidates
Mettaclaw selects out-of-AF goals across three candidate buckets (`EXPAND`, `BREAK`, `SYNERGIZE`). Dynamic Hebbian mode can be toggled in `experiment.metta`:

```metta
; Set to True for Dynamic Hebbian mode, or False for Static graph mode:
(= (useDynamicFrontier) False)
```
* **Static Mode (`False`):** Frontier candidates (`EXPAND` / `BREAK`) are computed strictly from the predefined graph.
* **Dynamic Mode (`True`):** Frontier candidates are augmented in real time with live Hebbian links learned during the simulation.
* **`SYNERGIZE` Bucket:** Always extracts the highest Long-Term Importance (LTI) concepts currently outside the AF.

---

## 6. Real-Time Monitoring & Logs

* **Goal Decisions:**
  ```bash
  tail -f /home/abel/Desktop/icog_labs/ECAN/PeTTa/repos/mettaclaw/memory/history.metta
  ```
* **SYNAPSE Metrics CSV:**
  ```bash
  tail -f /home/abel/Desktop/icog_labs/ECAN/metta-attention/experiments/output/metrics.csv
  ```

---

## 7. Post-Run Analysis & Visualization

```bash
cd /home/abel/Desktop/icog_labs/ECAN/metta-attention/experiments

# Plot attention category trajectories
python3 plot.py
```
