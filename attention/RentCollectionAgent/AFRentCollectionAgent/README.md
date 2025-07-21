# AFRentCollection Agent

## overview

The resposiblity of the Rent collection agent is to collect to collect Rent
ie. To return a percentage of STI from all atoms in the attentional Focus space.

## Agent Logic

1. The agent selects all atoms in the attentional focus.
2. the agent checks if it is the first time that it has been called.
    1. If it is the first time being called it records the time and exits.
    2. if not it calculates the time difference between now and last time it 
    was called
3. The agents then tries to calculate the rent which will only be applyed if the
FUNDS_STI and FUNDS_LTI global variables (which is a number showing the amount of
LTI and STI that system hasnt used) are below the TARGET_STI and TARGET_LTI 
variables.
4. The amount of STI and LTI subtracted is a value based on the difference between
the TARGET_STI and FUNDS_STI and the amount of time elapsed from the last update 
time for the STI and simlar operation for the LTI also.
