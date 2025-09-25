# Attentional-focus

## Overview

The attentional-focus module is a module used to define atoms in **attentionalFocus**.

## attentionalFocus

The **attentionalFoucs** (**AF**) is a list whose size is dictatied by the **MAX_AF_SIZE**
located in the [AttentionParam](../../../attention/agents/mettaAgents/AttentionParam.metta)

The expresssion is used to store all atoms that are deemed to be important by the value
of the STI. 

we can get those atoms by using getAfAtoms which returns top **MAX_AF_SIZE** number of atoms in typespace.


## Functions

The functions in the module are used 
 - to get atoms that should be in af
 - get random atom in and not in af
 - get atoms with specific links in af

