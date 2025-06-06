# Hebbian Creation

## Overview

The Hebbian Creation agent works unders the prinicple
> " links that wire together fire together "

In This defination the concept of firiing together is understood to mean to be 
in the attentional-focus space at the same time.

The idea of to atoms being wired is meant to mean that they have a link (edge)
that connects them in this case it will be an expression atom with a type
ASYMMETRIC_HEBBIAN_LINK with structure 
` (ASYMMETRIC_HEBBIAN_LINK ...) `

The created links will be stored in the typeSpace and be used in diffusion.

## Agent Logic

- The agent starts work by frist looking at the size of the attentionalFocusSize
if the space is empty the agent does no change and exits. 

- The agents retrives all atoms in the space newAtomInAV and clears the space
the space is used to only hold values for atoms that are newly entered into the 
attentional focus space after since the last time the Hebbian creation agent was
called.

- The agent checks if links of type **HEBBIAN_LINK** are entered into the attentioanl focus
if so it removes them from the attentional focus and does not create **ASYMMETRIC_HEBBIAN_LINK**'s
for them.

    - **ASYMMETRIC_HEBBIAN_LINK**'s are ordered links which means they convey information
      in one direction such that `(ASYMMETRIC_HEBBIAN_LINK source target)` means
      given *source* is in the **attentionalFocus** space *target* should be given 
      importance but it does not say what should happen to *source* given *target* 
      is in the **attentionalFocus**.

- prior to adding atoms we first check if we are missing target and source 
**ASYMMETRIC_HEBBIAN_LINK** for the current atom in consideration.

- if there are missing hebbian links we add those links to the type space with
default values.

