## ECAN Experiment 1: Shifting and Drifting While Reading
- This experiment replicates and extends the original attention modeling work done in the OpenCog ECAN system, titled "Shifting and drifting attention while reading".

### 1. General Description
- This experiment investigates ECAN's capability to simulate attention allocation and topic drifting while reading a stream of related concepts. Specifically, we aim to reproduce the patterns of attention observed in the original OpenCog experiment using a ported ECAN implementation in MeTTa.

#### The core focus is to analyze:

- How attention drifts from one category to another when topic context changes.

- How ECAN allocates limited attentional focus when the cognitive context is stimulated with semantically linked concepts over time.

- 2. Data

    - Data Structure
    - Located in experiment1/data, the dataset includes:

        - adagram_sm_links.metta – contains semantic links across the above categories.

- Example Links (links.metta)
    The file includes a total of 40 curated links:

    20 SimilarityLinks (e.g., insecticide ↔ insect or poison)

    10 MemberLinks (e.g., aphid ∈ pest species)

    10 CausesLinks (e.g., aflatoxin → liver cancer)

- Link distribution:

    - 50% of links connect insecticides to poisons

    - 25% connect insects/poisons to diseases

    - 25% connect insects/poisons to species

- This distribution provides a balanced structure to observe meaningful topic shifts across semantic categories.

### 3. Execution Process
- Overview
- Randomly stimulate words from the insect-words file.

- After a defined number of insect stimulations, switch to stimulating words from the poison-words file.

- While stimulation occurs, a suite of ECAN attention agents operate in parallel:

    - HebbianCreationAgent

    - HebbianUpdatingAgent

    - AFImportanceDiffusionAgent

    - AFRentCollectionAgent

- Attentional snapshots are logged after each word stimulation.

Attention Configuration
The ECAN system is parameterized with:
```py
    scheduler.update_attention_param("MAX_AF_SIZE", 16)
    scheduler.update_attention_param("AFRentFrequency", 1.0)
    scheduler.update_attention_param("STI_FUNDS_BUFFER", 1000)
    scheduler.update_attention_param("LTI_FUNDS_BUFFER", 1000)
    scheduler.update_attention_param("TARGET_STI", 1000)
    scheduler.update_attention_param("TARGET_LTI", 1000)
    scheduler.update_attention_param("FUNDS_STI", 2000)
    scheduler.update_attention_param("FUNDS_LTI", 2000)
 
```
    
- Core Experiment Loop
- Here is the main execution loop that handles word stimulation and topic shifts:

    ```py
    scheduler.run_iterativly(6, 3)
    ```
- This logic stimulates a mix of insect and poison terms, allowing attention to accumulate on their associated concepts through stimulation and diffusion mechanisms.
- The first integer defines how many ranom words to pick from both insect and poison and the second determines after how many words to switch context.

### 4. Results
        
- output image for the above experiment with parameters in the [setting.json](output/settings.json)
  can be found in [plot 1](output/plot_faceted.png)
### Observations:
- In the plot, attention starts focused on insect-related words.

- Upon switching to poison words, a clear attention shift occurs.

- Due to a higher number of SimilarityLinks involving insecticides, they received greater attention in the drifting phase.

- Disease and species links appeared occasionally but were less dominant due to their lower representation in the link set.

### 5. Conclusion
- This experiment successfully reproduces the original ECAN drifting and attention allocation behavior in the MeTTa-based ECAN system.

Key takeaways:
- The shift in attention across semantic categories is observable and controllable via stimulation strategy.

- Link structure and link type distribution significantly influence which concepts dominate attention.

- Lower MAX_AF_SIZE values produce sharper transitions, while larger sizes allow more sustained overlap between topics.
