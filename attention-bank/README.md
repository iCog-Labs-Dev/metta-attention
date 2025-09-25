# Attention-Bank

The attention bank is the back bone of the ECAN project its main functionality
will be used to enable to create a platfrom for impelment agents.

The main functionality of the attention bank are
1. Managing the attentional focus
2. Managing the typeSpace
3. Creating stocastic operations for operating over non-attentioanl focus atoms


### **Attentional Focus**:
- A function which returns expression of atoms. the expression size is controlled by a constant MAX_AF_SIZE in AtentionParam.
- The expression holds atoms which have high importance

### **TypeSpace**:
- This is a space that holds all atoms that have **AV**, **STV** or both.
- This space is responsible for storing the **AV**, **bin** and **STV** as types which
are defined in the **[types.metta](../../types.metta)** function defined in the project root.
- This space is used to store links such as **ASYMMETRIC_HEBBIAN_LINK** which 
will be created by the hebbian creation agent used for diffusion.

## STI

The **STI** value is the main value that determine's the movement of an atom
higher in the spaces with repect to the above mentioned diagram.

Atoms gain **STI** by wage which is supplied through wage via the stimulate function
and through diffusion via the [**Diffusionagent**](../attention/agents/mettaAgents/ImportanceDiffusionAgent).

Atoms loose **STI** based on Rent collected by [**RentCollectionAgent**](../attention/agents/mettaAgents/RentCollectionAgent) and through 
diffusion to atoms that are have connection to the atom under consideration.

for further information on **Wage** and **Rent** refer to the [README.md](bank/README.md)
