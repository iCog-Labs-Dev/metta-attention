# Economic Attention Networks (ECAN)

- This repository contains MeTTa code for [attention](https://github.com/singnet/attention) codebase port/re-implementation.

## Introduction

- ECAN(Economic Attention Network) is a general term for the way that Attentional dynamics (centrally, the Competition for Attention) is carried out within OpenCogPrime.

- Each Atom has an Attention Value attached to it. The process of updating these values is carried out according to nonlinear dynamical equations that are derived based on "artificial economics," utilizing two separate "currencies," one for `Short Term Importance (STI)` and one for `Long Term Importance (LTI)`.

- One aspect of these equations is a form of `Hebbian Learning:` Atoms called `HebbianLinks` record which Atoms were habitually used together in the past, and when it occurred that Atom A's utilization appeared to play a role in causing Atom B's utilization. Then, these HebbianLinks are used to guide the flow of currency between Atoms: `B` gives `A` some money if `B` thinks that this money will help `A` to get used, and that this utilization will help `B` to get used.


- Very roughly speaking, these dynamical equations play a similar role to that played by `activation-spreading` in Neural Network AI systems.

## Running the Code

- Make sure to install MeTTa `v0.2.1` following the instruction on the [hyperon-experimental](https://github.com/trueagi-io/hyperon-experimental) repository.
- For windows users, an alternative way of running MeTTa can be using the [metta-run](https://github.com/iCog-Labs-Dev/metta-prebuilt-binary) binary.


## Contributing 

Before you start contributing to this repository, make sure to read the [CONTRIBUTING.md](https://github.com/iCog-Labs-Dev/metta-attention/blob/main/.github/CONTRIBUTING.md) file from our repository

## References

- Original [paper](https://www.researchgate.net/publication/239925326_Economic_Attention_Networks_Associative_Memory_and_Resource_Allocation_for_General_Intelligence)

- [Economic attention allocation](https://wiki.opencog.org/w/Economic_attention_allocation_(Obsolete)) wiki page 

- C++ implementation of [attention](https://github.com/singnet/attention) codebase

