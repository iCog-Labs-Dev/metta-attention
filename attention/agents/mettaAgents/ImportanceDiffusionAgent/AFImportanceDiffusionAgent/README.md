# AFImportanceDiffusion agent

## Overview

The **AFImportanceDiffusion** agent is an agent that is responsible to diffuse 
STI values from atoms in the attentional focus to all atoms that the atoms are 
conected to via **ASYMMETRIC_HEBBIAN_LINK**'s or other links of any type other
than **HEBBIAN_LINK**'s.  

## Agent Logic

1. The agents first matches all atoms in the attentional focus.
2. The agent then caculates what value each atom is going to give to other atoms
and what it is going to recive.
    1. The amount an atom give to other atoms is controlled by the constant
    *maxSpreadPercentage* which tells the percentage of the STI to diffuse.
    2. The indcident atoms (links the atom is present in), outgoing atoms (atoms
    that are in the atoms, if it is a link) will be diffused to unless the 
    incident atoms are **ASYMMETRIC_HEBBIAN_LINK** or **HEBBIAN_LINK** 
    3. For **ASYMMETRIC_HEBBIAN_LINK**'s the agent diffuses an amount based on 
    **max_hebbian_speard_percentage** and the Truthvalue of the atom.
    4. **ASYMMETRIC_HEBBIAN_LINK**'s are diffsed to first then the remaning 
    STI amount to the remaining atoms.
