# Stochastic-importance

## Overview

The main usage of this **Stochastic-importance** is to allow **ECAN** to operate
more efficently over atoms in the **atom-bin** but not in the **attentionalFocus**
space by working only with atoms randomly selected rather than all atoms.

## Spaces

The module creates a space **atomBinInfo**. This space is used to store information
about bins. The information is stroed as in a sturcutre 
`($index ((count $count) (index $index) (_size $newSize) (update_rate $newUpdateRate) (last_update $now)))`

The above information is stored for all bins that are present and have been 
initialized.

## Functions

The functions in the module can be classifed as doing the following actions

1. Update

The main working of the functions is to allow updating of the module to create


### Update

The Function responsible for updating the values stored in the space is used
to tell to the system information about the bin which the atom that has been 
choosen randomly exists in.

The values tell the system when the bin was last updated how many times it was
updated, its size and other information based on which it tells the 
[**WAImportanceDiffusionAgent**](../../../attention/agents/mettaAgents/ImportanceDiffusionAgent/WAImportanceDiffusionAgent) and [**WARentCollectionAgent**](../../../attention/agents/mettaAgents/RentCollectionAgent/WARentCollectionAgent) 
(target3 () 0.0 -0.0)
(target3 () 0.0 -0.0)
(target3 (INHERITANCE_LINK target3 (ASYMMETRIC_HEBBIAN_LINK sorce target4)) 1600.0 -1600.0)
(target3 (INHERITANCE_LINK target3 source) 1600.0 -1600.0)
(source target4 2.5000000000000004 -2.5000000000000004)
(source target3 3.0 -3.0)
(source (INHERITANCE_LINK source target4) 998.625 -998.625)
(source (INHERITANCE_LINK source target6) 998.625 -998.625)
(source (INHERITANCE_LINK source target5) 998.625 -998.625)
(source (INHERITANCE_LINK target3 source) 998.625 -998.625)
(target2 () 0.0 -0.0)
(target2 target3 0.0 -0.0)
(target6 () 0 0)
(target1 target2 0.0 -0.0)
(target4 () 0.0 -0.0)
(target4 (INHERITANCE_LINK source target4) 3200.0 -3200.0)
(target5 (INHERITANCE_LINK source target5) 3200.0 -3200.0)
(atoms ((INHERITANCE_LINK source target5) 3200.0))
(atoms (target5 -3200.0))
(atoms ((INHERITANCE_LINK source target4) 3200.0))
(atoms (target4 -3200.0))
(atoms (() 0.0))
(atoms (target4 -0.0))
(atoms (target2 0.0))
(atoms (target1 -0.0))
(atoms (() 0))
(atoms (target6 0))
(atoms (target3 0.0))
(atoms (target2 -0.0))
(atoms (() 0.0))
(atoms (target2 -0.0))
(atoms ((INHERITANCE_LINK target3 source) 998.625))
(atoms (source -998.625))
(atoms ((INHERITANCE_LINK source target5) 998.625))
(atoms (source -998.625))
(atoms ((INHERITANCE_LINK source target6) 998.625))
(atoms (source -998.625))
(atoms ((INHERITANCE_LINK source target4) 998.625))
(atoms (source -998.625))
(atoms (target3 3.0))
(atoms (source -3.0))
(atoms (target4 2.5000000000000004))
(atoms (source -2.5000000000000004))
(atoms ((INHERITANCE_LINK target3 source) 1600.0))
(atoms (target3 -1600.0))
(atoms ((INHERITANCE_LINK target3 (ASYMMETRIC_HEBBIAN_LINK sorce target4)) 1600.0))
(atoms (target3 -1600.0))
(atoms (() 0.0))
(atoms (target3 -0.0))
(atoms (() 0.0))
(atoms (target3 -0.0))
((INHERITANCE_LINK target3 (ASYMMETRIC_HEBBIAN_LINK sorce target4)) target3 640.0 -640.0)
((INHERITANCE_LINK source target6) target6 199.72500000000002 -199.72500000000002)
((INHERITANCE_LINK source target6) source 199.72500000000002 -199.72500000000002)
((INHERITANCE_LINK target3 source) source 519.725 -519.725)
((INHERITANCE_LINK target3 source) target3 519.725 -519.725)
((INHERITANCE_LINK source target4) target4 839.725 -839.725)
((INHERITANCE_LINK source target4) source 839.725 -839.725)
((INHERITANCE_LINK source target5) target5 839.725 -839.725)
((INHERITANCE_LINK source target5) source 839.725 -839.725)
(source target4 1.5000000000000002 -1.5000000000000002)
(source target3 1.8 -1.8)
(source (INHERITANCE_LINK source target4) 599.175 -599.175)
(source (INHERITANCE_LINK source target6) 599.175 -599.175)
(source (INHERITANCE_LINK source target5) 599.175 -599.175)
(source (INHERITANCE_LINK target3 source) 599.175 -599.175)
(target6 () 0 0)
(target2 () 0.0 -0.0)
(target2 target3 0.0 -0.0)
(target5 (INHERITANCE_LINK source target5) 1920.0 -1920.0)
(target3 () 0.0 -0.0)
(target3 () 0.0 -0.0)
(target3 (INHERITANCE_LINK target3 (ASYMMETRIC_HEBBIAN_LINK sorce target4)) 960.6 -960.6)
(target3 (INHERITANCE_LINK target3 source) 960.6 -960.6)
(target1 target2 0.0 -0.0)
(target4 () 0.0 -0.0)
(target4 (INHERITANCE_LINK source target4) 1921.0 -1921.0)
