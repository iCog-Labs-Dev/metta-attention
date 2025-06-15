# ECAN Experiment in MeTTa: Shifting and Drifting Attention

This document summarizes an experiment conducted using **ECAN (Economic Attention Network)** with **MeTTa**. The goal was to observe and analyze the behavior of **attentional shifting** and **drifting**.

---

## Plot Overview

![Category Frequency Over Time](plot.png)

The plot shows the frequency of different concept categories entering the attentional focus over time:

- **Poison**-related atoms increase in focus **after** insect-related input stops.
- **Insecticide** (bridge concept) appears **steadily**, illustrating **drifting**.
- The red line **(Entered through spreading)** confirms that related atoms enter via **importance diffusion**.
- **Noise** ("other") remains present, especially due to short input context.

---

##  Experimental Setup

Due to **performance limitations in MeTTa**, only **short input sentences** were used for two concept groups:

-  **Insect-related** concepts
-  **Poison-related** concepts
-  **Insecticide** served as a **bridge concept** linked to both.

These concept groups were processed **sequentially** — first insects, then poison.

---

##  Observed Attentional Behaviors

### Shifting

After feeding poison-related sentences:

- Insect-related atoms faded from focus.
- Poison-related atoms rose in prominence.
- The system **shifted attention** based on new, directly stimulated input.

### Drifting

Before direct stimulation:

- `insecticide` entered focus due to links from both categories.
- This shows **drifting**

---

##  Challenges

- MeTTa’s slowness required **very short input**.
- This led to:
  - **Unrelated (noisy)** atoms entering focus.

---

## Conclusion

Despite system constraints, the experiment clearly demonstrated:

- **Shifting** of attention between concepts.
- **Drifting** via importance spreading.

These findings validate ECAN's **attention allocation** model in MeTTa and provide strong support for cognitive modeling of **dynamic focus**.

---

> _Improving MeTTa’s performance will allow longer texts and more meaningful transitions to emerge._
