# Stochastic-importance

## Overview

The main usage of this **Stochastic-importance** is to allow **ECAN** to operate
more efficently over atoms in the **typeSpace** but not in the **attentionalFocus**
list by working only with atoms randomly selected rather than all atoms.

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
