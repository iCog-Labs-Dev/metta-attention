# Importance-index

## Overview

This module impelemnts functions that are used to increase the functionality of
the atom-bins space.

## Functions

The functions in the module can be classifed as doing the following actions

1. Retrive
2. Update

### Retrive

The module's Retrival functions retrive different values from the **atom-bin**
space to allow other functions to work.

The functions can retrive the number of total bins, the amount of atoms in a bin
the values of the max and min value and most importantly it calculates the values
of the a bin an atom should be placed in given and **STI**.

### Update

The module holds functions to update global vairable that hold the values of 
max and min sti value, and it performs an update on the atombin space by changing
the index of an atom stored in a bin and put it into a new bin when its **STI**.

