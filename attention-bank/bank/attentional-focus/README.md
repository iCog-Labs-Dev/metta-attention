# Attentional-focus

## Overview

The attnentional-focus module is a module used to define the **attentionalFocus**
and **newAtomInAV** spaces and defines functions that interact with these spaces.

## Spaces

### attentionalFocus

The **attentionalFoucs** (**AF**) is a space whose size is dictatied by the **MAX_AF_SIZE**
located in the [AttentionParam](../../../attention/agents/mettaAgents/AttentionParam.metta)

The space is used to store all atoms that are deemed to be important by the value
of the STI. If the spapce is full and only atoms having STI values bigger than
the atom with the smallest STI are allowed to enter.

### newAtomInAV

The **newAtomInAV** space is used to store atoms that are new to be sored into
the **AF**. 

This space is mainly used by the [HebbianCreation agent](../../../attention/agents/mettaAgents/HebbianCreationAgent/README.md) to ensure that is does not 
work over the whole **AF** space but only atoms that are newly entered to the 
AF.

## Functions

The functions in the module can be classifed as doing the following actions

1. Create
2. Retrive
3. Update
4. Delete

and utility function to facilitate the above overall functionalities.

The above functionality is provided to interacct with the **AF** space. The
**newAtomInAV** has function to Create and Retriv.
