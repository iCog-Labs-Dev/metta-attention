# Economic Attention Networks (ECAN)

- This repository contains MeTTa code for [attention](https://github.com/singnet/attention) codebase port/re-implementation.

## Introduction

- **ECAN**(Economic Attention Network) is a general term for the way that Attentional dynamics (centrally, the Competition for Attention) is carried out within OpenCogPrime.

- Each Atom has an Attention Value attached to it. The process of updating these values is carried out according to nonlinear dynamical equations that are derived based on "artificial economics," utilizing two separate "currencies," one for `Short Term Importance (STI)` and one for `Long Term Importance (LTI)`.

- One aspect of these equations is a form of `Hebbian Learning:` Atoms called `HebbianLinks` record which Atoms were habitually used together in the past, and when it occurred that Atom A's utilization appeared to play a role in causing Atom B's utilization. Then, these HebbianLinks are used to guide the flow of currency between Atoms: `B` gives `A` some money if `B` thinks that this money will help `A` to get used, and that this utilization will help `B` to get used.

- Very roughly speaking, these dynamical equations play a similar role to that played by `activation-spreading` in Neural Network AI systems.

## Running the Code

- The system's main dependancy requires the operating system to be either
*MACOS* or *LINUX* based systems. For running on windows using *WSL* or other
means of virtualization is required.

- To run the code clone the folloing github repository

```sh
git clone https://github.com/trueagi-io/PeTTa
```

```sh
git clone https://github.com/iCog-Labs-Dev/metta-attention
cd metta-attention
```

- Important note: make sure the PeTTa and metta-attention have sibling folders for your parent folder.

- After cloning the repo create a python virtual enviroment and load all dependancies.
NB: The **Hyperon** python module requires python versions greater than or equal to 3.8 

```sh
python3 -m venv .ECAN
source .ECAN/bin/activate
pip install -r requirments.txt
```

- to run tests
    - cd PeTTa repository
    - run `sh run.sh ../metta-attention/go-to-the-test-you-want-to-run` 
    - e.g 
    
    ```
    sh run.sh ../metta-attention/attention/HebbianCreationAgent/HebbianCreationAgentTest/HebbianCreationAgentc++-test.metta
    ```

## Using ECAN as a Library

The root [`lib.metta`](lib.metta) file loads the reusable ECAN attention bank,
agents, and helper functions. In another PeTTa project, register this repository
first, then import the library entry point:

```metta
!(import! &self (library lib_import))

!(git-import! "https://github.com/iCog-Labs-Dev/metta-attention.git")

!(import! &self (library metta-attention lib))

!(getAttentionParam FUNDS_STI)
```

For local development before the library entry point is published, register your
checkout directly with an absolute path:

```metta
!(assertaPredicate (Predicate (library_path "/absolute/path/to/metta-attention")))

!(import! &self (library metta-attention lib))
```

After the import, ECAN functions such as `stimulate`, `setAv`, `getAfAtoms`,
`HebbianCreationAgent-Run`, `HebbianUpdatingAgent-Run`,
`AFImportanceDiffusionAgent-Run`, `WAImportanceDiffusionAgent-Run`,
`AFRentCollectionAgent-run`, `WARentCollectionAgent-Run`, and
`forgettingAgent-Run` are available in `&self`.

PeTTa standard libraries should be imported with `(library ...)`, for example
`(library lib_spaces)`. This keeps imports independent of the directory where
the user runs `run.sh`.

- to run the experiment
    - first run the run.sh script as follows `sh run.sh` the script uses pyhton3 by default to run scripts to convert
      wordnet and coneptnet data to metta equivalent data but you can specify desired metta version as `PYTHON=python3.10 sh run.sh`

    - go to PeTTa repository and run the experiment.metta which is `sh run.sh ../metta-attention/experiments/experiment.metta `
      Note: Make sure to be using swipl version greater than or equal to 9.3.25 to insuure foldall is natively supported. 

## Contributing 

Before you start contributing to this repository, make sure to read the [CONTRIBUTING.md](https://github.com/iCog-Labs-Dev/metta-attention/blob/main/.github/CONTRIBUTING.md) file from our repository

## References

- Original [paper](https://www.researchgate.net/publication/239925326_Economic_Attention_Networks_Associative_Memory_and_Resource_Allocation_for_General_Intelligence)

- [Economic attention allocation](https://wiki.opencog.org/w/Economic_attention_allocation_(Obsolete)) wiki page 

- C++ implementation of [attention](https://github.com/singnet/attention) codebase
