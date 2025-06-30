# Bank

## Overview

The bank module is a responsible for defining modules responsible for 

- [**atom-bins**](atom-bins/README.md)
- [**attentional-focus**](attontional-focus/README.md)
- [**importance-index**](importance-index/README.md)
- [**stocastic-importance-diffusion**](importance-index/README.md)

Additionally the bank hold functions to control the disbursment of the STI and LTI.

## Funds

The funds are mainly stored in the fundsSTI and fundsLTI variable 
these values are the total amount of STI and LTI that can be in the system at one time.

The **targetSTI**, **targetLTI**, **stiFundsBuffer** and **ltiFundsBuffer** are hyper parameters
that control the rent collection and stimulation values.

The **STIAtomWge** and **LTIAtomWage** are multiples that are dependant on the above mentioned hyper parameters
and are a multiplier that determine how much the **STI** and **LTI** are given from the stimulation value.

## Wage

Wage is the main way an atom recives an **STI** and **LTI** values. The function takes a number as an argument
and calculates wage by checking if the total funds is lower than the target funds. As the total available fund falls
below the **targetSTI** and **targetLTI** the provided **STI** and **LTI** is reduced for each additional call to the stimulate
function.

## Rent

Rent a ways in which an atom returns it **STI** and **LTI** values back into the buffer. While wage is initiaed by a system outside of
the ECAN. Rent is handled by the [**RentCollectionAgent**](../../attention/agents/mettaAgents/RentCollectionAgent) and is called consitantly.
One of the main requirments to be full filled before rent start being collected is the **fundsSTI** and **fundsLTI** values beings lower
than**targetSTI** and **targetLTI** respectivley.



