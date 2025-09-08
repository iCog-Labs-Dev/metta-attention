# Attention Value

## Overview

This module is used to set and retrive the AV, STV and bin values of an atom.

## Setting AV

The **AV** value is composed of three numbers and describing 
- STI (Short term Importance)
- LTI (Long term Importance)
- VLTI (Very Long term Importance)

This values are used to describe how important an atom is and how much resource
to allocate to it.

To set an AV of an atom
- The system retrives the atoms *STI*, *LTI* and *VLTI* if it has if not it defaults 
to zero
- It then calculates the bin of an atom
- We check the value of the atom and check if it has prior AV or STV
    - If the atom is has no prior *AV* or *STV* it simply adds the atom to the
    typespace space.
    - If the atom has an *AV* but no *STV* we remove the old *AV* and add the
    new *AV* value.
    - If the atom has an *STV* we get the value of *STV* and concatenate it with 
    the new *AV* value and we remove the past value and new value.
- After this we balance of the *STI* and *LTI* with thier respective buffers.
- Finally we check if we need to add or remove the atom from the attentionalfocus 
space.

## Getting AV

The values of AV is stored in the typespace and stored as a type to the atom

- We retrive the atom and then call the `getValueType` function and retirive the AV

## Setting STV

The **STV** value is composed of two numbers defined as
- Mean
- Confidence

The values are used as the strength of values held in links
ie. links are defined as expression atoms with the first atom describing the 
type of the functions.

Setting the *STV* of an atom is simpler compared to setting AV since it does not
change the bin index in the atom bin space, it does not dictate if the atom 
should be entered into the attentional focus and its values are not conserved
so we dont need to consider if it is within funds value.

- The agent First check if the atom is already presnt in the **Typespace**
- If the atoms is found the old value is removed and added **typeSpace**.
- If the atom is not found it is simply added to the **typeSpace**.

## modified atom structure

(atom (((STV mean conf) (AV sti lti vlti)) (Bin binNumber)))
we removed atombin space. now all information of an atom is stored in typespace.
