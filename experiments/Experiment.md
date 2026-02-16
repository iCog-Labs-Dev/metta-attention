# ECAN Experiment in MeTTa: Shifting and Drifting Attention

This document summarizes an experiment conducted using **ECAN (Economic Attention Network)** with **MeTTa**. The goal was to observe and analyze the behavior of **attentional shifting** and **drifting**.


## 1.Description

The experiment aimed to simulate how attention shifts and drifts within a cognitive system when presented with sequential inputs related to different concept groups. Specifically, it focused on two primary categories:
- **Insect-related concepts**: Representing one domain of interest.
- **Poison-related concepts**: Representing another domain of interest.
- **Insecticide**: Acting as a bridge concept linking both domains.

The ECAN, implemented in MeTTa, manages attention through agents such as Hebbian link creation, Importance diffusion, Rent collection, and Forgetting. The experiment tracked how these mechanisms influence the movement of atoms into and out of the **Attentional Focus (AF)** over time.


## 2.The Data used in the experiment

The input data consisted of two sets of sentences:
1. **Insect-related sentence**: Stimulated the system with insect-related concepts.
2. **Poison-related sentence**: Stimulated the system with poison-related concepts.
   

Key points about the data:
- Due to performance limitations in MeTTa, only short input sentences were used.
- `Insecticide` served as a bridge concept, connecting the insect and poison domains.
- The system processed these inputs sequentially: first insect-related sentence, then poison-related sentence.



## 3.Execution 

The experiment was executed using the following steps:

### Initialization
1. **Import Modules**:
   - Imported essential modules for attention management, including:
     - ForgettingAgent, RentCollectionAgent, ImportanceDiffusionAgent, HebbianUpdatingAgent, and HebbianCreationAgent.
   - Configured the parameters  in the attention bank

2. **Load Knowledge Base**:
   - Loaded the knowledge base containing predefined relationships between concepts.
   - Initialized the system with specific sentences for insects and poisons.

### Input Processing
3. **Stimulate Concepts**:
   - Used the `insectPoisonReadExp` function to process insect-related sentence first, followed by poison-related sentence.
   - Each word in the sentence is stimualated, increasing  it's Importance value.

4. **Execute ECAN Agents**:
   - Ran ECAN agents at each step to manage attention dynamics:

     - **HebbianCreationAgent**:creates ASYMMETRIC_HEBBIAN_LINK  connections between atoms in the attentional focus
     - **HebbianUpdatingAgent**:the HebianUpdating updates the Truthvalue's (mean, confidence) of ASYMMETRIC_HEBBIAN_LINK links
     - **AFImportanceDiffusionAgent**: Diffuse importance within the Attentional Focus.
     - **AFRentCollectionAgent**: Collected rent from  atoms in the Attentional Focus.
     - **ForgettingAgent**: an agent responsible for removing atoms of any kind from the all relevant spaces available.

5. **Monitor Attentional Focus**:
   - Tracked the frequency of different concept categories entering the Attentional Focus over time.
   - Logged results to analyze attentional shifting and drifting.



## 4.Results

The experiment produced the following insights based on the plot titled **"Category Frequency Over Time"**:

### Key Observations
1. **Shifting of Attention**:
   - After processing insect-related sentences, the focus shifted toward poison-related concepts when poison-related sentences were introduced.
   - This shift was evident in the increased prominence of poison-related atoms in the Attentional Focus.

2. **Drifting of Attention**:
   - the `insecticide` concept (a bridge concept) appeared steadily in the Attentional Focus.
   - This demonstrates **drifting**, where related but unstimulated concepts enter the focus due to their connections to stimulated concepts.

3. **Importance Diffusion**:
   - The red line labeled **"Entered through spreading"** confirmed that related atoms entered the focus via importance diffusion.
   - This highlights how ECAN dynamically redistributes attention across connected concepts.

4. **Noise in the System**:
   - Due to short input contexts and performance constraints, unrelated ("noisy") atoms occasionally entered the Attentional Focus.
   - These noisy entries were more pronounced during transitions between input phases.

### Plot Analysis

Here is the plot showing the **Category Frequency Over Time**:

![Category Frequency Over Time](output/plot.png)

#### Observations from the Plot:
- **Insect-related concepts** dominated initially but decreased after poison-related sentences were introduced.
- **Poison-related concepts** rose in prominence, reflecting attentional shifting.
- **Insecticide** remained steady, illustrating drifting behavior.
- The **red line** ("Entered through spreading") showed consistent entry of related atoms via diffusion.



## 5. Conclusion

Despite the performance limitations of MeTTa, which restricted the use of longer texts, the experiment clearly demonstrated the following:

1. **Shifting of Attention**:
   - The system effectively shifted attention from insect-related concepts to poison-related concepts upon receiving new, directly stimulated input.

2. **Drifting of Attention**:
   - Unstimulated but related concepts (e.g., `insecticide`) drifted into the Attentional Focus due to their connections to stimulated concepts.

3. **Dynamic Focus Management**:
   - ECAN's agents (e.g., Hebbian links, importance diffusion, rent collection) successfully managed attention allocation over time.

### Future Improvements
- **Enhanced Performance**: Improving MeTTa's performance would allow for longer and more complex inputs, enabling richer transitions and interactions.
- **Noise Reduction**: Refining the system to better filter out unrelated atoms could enhance focus clarity.



This experiment provides strong evidence for the effectiveness of ECAN's attention allocation in MeTTa, validating its ability to stimulate dynamic cognitive processes like attentional shifting and drifting.
