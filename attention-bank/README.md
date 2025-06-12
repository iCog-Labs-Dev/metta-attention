# Attention-Bank

The attention bank is the back bone of the ECAN project its main functionality
will be used to enable to create a platfrom for impelment agents.

The main functionality of the attention bank are
1. Managing the attentional Focus space
2. Managing the atomBins space
3. Managing the typeSpace
4. Creating stocastic operations for operating over non-attentioanl focus atoms

## Spaces

Their are multiple spaces used for the implementation of ECAN the main spaces are

```
                    ___________________
                   |                   |
                   | Attentional Focus |
            _______|___________________|_______
           |                                   |
           |             Atom Bins             |
     ______|___________________________________|______
    |                                                 |
    |                   Type Space                    |
    |_________________________________________________|
```

The above illustration aims to show the highrarchy of the 3 spaces considerd to 
be pivotal

### **Attentional Focus**:
- A space whose size is controlled by a constant MAX_AF_SIZE in AtentionParam.
- The space only accepts only atoms that have AV values set
- New atoms will only be accepted if
    - The space is not full
    - if the space is full the new atoms has higher STI than the atom with the
    lowest STI
- Atoms storage is not sturcured but should only be done via the setAv function
to ensure that all checks are made when the atom is added.

### **AtomBin**:
- The AtomBin space is used as an intermideary.
- It holds all atoms that have an AV value set.
- The atom bin is strucutred to as a mimick as a sparse matrix that holds atoms
of the same with similar sti values in the same expression atom.
- The importance index module is responsible for calculating which bin an atom
should be place in 
- For further clarification look at the [atom-bins](atom-bins/README.md) module located in the bank
directory 

### **TypeSpace**:
- This is a space that holds all atoms that have **AV**, **STV** or both.
- This space is responsible for storing the **AV** and **STV** as types which
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
