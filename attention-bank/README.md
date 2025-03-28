# Attention Bank Module

## Overview
The **Attention Bank** module is a core component of the Hyperon ECAN (Attention Allocation Network) port from OpenCog to Hyperon. This module is responsible for handling attention allocation mechanisms, including assigning, modifying, and propagating attention values across AtomSpace.

The module is structured into three main directories:
- **attention-value/** – Manages attention and truth values for atoms.
- **bank/** – Implements attention allocation strategies, including importance indexing and stochastic diffusion.
- **utilities/** – Provides helper functions for the Attention Bank module.

## Module Structure

### 1. `attention-value/`
This module handles the assignment, retrieval, and modification of attention values and simple truth values for atoms (symbols or expressions) in AtomSpace.

#### Key Features:
- Assign and retrieve attention values.
- Assign and retrieve simple truth values.
- Provide utility functions for computing mean, confidence, long-term importance (LTI), short-term importance (STI), and very-long-term importance (VLTI).

#### Main Files:
- **getter-and-setter.metta**: Contains core functions such as:
  - `setAv`, `getAv` – Set and get attention values.
  - `setStv`, `getStv` – Set and get simple truth values.
  - `getMean`, `getConfidence`, `getLTI`, `getSTI`, `getVLTI` – Compute various importance metrics.
- **test/**: Includes unit tests for verifying that attention values and truth values are correctly assigned and retrieved.

---

### 2. `bank/`
This module manages attention allocation through different mechanisms. It consists of four submodules:

#### **2.1. importance-index/**
- Handles the calculation of importance indices for atoms.
- Enables adding, accessing, and removing atoms based on their importance values.
- Directly influences attention allocation decisions.

#### **2.2. attentional-focus/**
- Manages atoms that exceed a specified importance threshold.
- Implements sorting, removal, and reallocation mechanisms.
- Determines which atoms receive the most attention in the network.

#### **2.3. stochastic-importance-diffusion/**
Implements a link-based propagation mechanism that diffuses importance values across atoms in a stochastic manner.

##### Key Features:
- **Stochastic Diffusion**: Uses probabilistic methods to distribute importance across related atoms.
- **Graph-Based Propagation**: Ensures that importance flows through connected structures in AtomSpace.
- **Dynamic Updates**: Continuously adjusts importance values in response to network changes.

#### Main Files:
- **attention-bank.metta**: containes Stimulate Function `(stimulate)`, Wage Calculation `calculateSTIWage, calculateLTIWage)`, Attention Value Management `(attentionValueChanged)`, Funds Management `(updateSTIFunds, updateLTIFunds)` and other functions which integrate all the bank functionalities into one.
- **test/**: Contains test cases to validate functions found inside `attention-bank.metta` file

---

### 3. `utilities/`
This module provides general utility functions and helpers used across the Attention Bank. These functions ensure consistency and simplify common operations throughout the module.

## Conclusion
The **Attention Bank** module is essential for managing and distributing attention values in Hyperon ECAN. By leveraging mechanisms like importance indexing, attentional focus, and stochastic diffusion, it ensures an adaptive and efficient attention allocation system.

For further details, refer to the source files and test cases included in each submodule.

