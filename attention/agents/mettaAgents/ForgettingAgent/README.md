# Forgetting Agent

The forgetting Agent is an agent responsible for removeing atoms of any kind 
from the all relevant spaces available. The agent uses the value of the static 
parameter of **ForgetThresold** and removes all atoms with **STI** values below
this and leaves a certain number of atoms free based on the **maxSize** and
**accDivSize** parametters

## Agent Logic

The forgetting agent takes the following steps 

1. The agent takes all atoms from the Atombin Space
2. It then filters all atoms that are below the **ForgetThreshold**
3. The agent sorts in ascending orderd filtered atoms based on Lti values and
uses mean value as a differentitation factor.
4. For an atom to be removed (Forgotten) 
    1. It has to be below the thresold and
    2. We should have not removed more atoms than allowed by maxSize and accDivSize
    3. It should not be in part of a link that is not a ASYMMETRIC_HEBBIAN_LINK link
5. If an atom is deemed to be removed the agent will remove all the atom and its
ASYMMETRIC_HEBBIAN_LINK links.
6. Atoms removed are stored are in thier own space
