# Hebbian Updating

## Overview

The HebianUpdating updates the Truthvalue's (mean, confidence) of **ASYMMETRIC_HEBBIAN_LINK** 
links where an atom choosen at random from the attentional focus is the source 
atom. 

## Agent Logic

1. The agent choses an atom from the attentional focus at random 
2. The updating agent gets all **ASYMMETRIC_HEBBIAN_LINK**'s associated with the atom
3. the agent pick all **ASYMMETRIC_HEBBIAN_LINK**'s that have the random atom as
source.
4. The agent caculates a new TruthValue for all links that fulfill the above situation.


