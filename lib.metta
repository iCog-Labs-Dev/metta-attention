; ECAN public library entry point.
; Register this repository as the metta-attention library before importing this file:
; !(import! &self (library lib_import))
; !(git-import! "https://github.com/iCog-Labs-Dev/metta-attention.git")
; !(import! &self (library metta-attention lib))

; Core Hyperon libraries used by the ECAN modules.
!(import! &self (library lib_he))
!(import! &self (library lib_spaces))
!(import! &self (library lib_import))

; Parameters and shared helpers.
!(import! &self (library metta-attention attention/AttentionParam))
!(import! &self (library metta-attention attention/baching))
!(import! &self (library metta-attention attention-bank/utilities/helper-functions))
!(import! &self (library metta-attention attention-bank/utilities/recentVal))
!(import! &self (library metta-attention attention/Neighbors))

; Attention value storage and bank functionality.
!(import! &self (library metta-attention attention-bank/attention-value/getter-and-setter))
!(import! &self (library metta-attention attention-bank/bank/importance-index/importance-index))
!(import! &self (library metta-attention attention-bank/bank/attention-bank))
!(import! &self (library metta-attention attention-bank/bank/attentional-focus/attentional-focus))
!(import! &self (library metta-attention attention-bank/bank/stochastic-importance-diffusion/merge-bin))
!(import! &self (library metta-attention attention-bank/bank/stochastic-importance-diffusion/stochastic-importance-diffusion))

; Python helpers used by the agents and optional logging/metrics functions.
!(import! &self (library metta-attention attention/ImportanceDiffusionAgent/getelement.py))
!(import! &self (library metta-attention experiments/utils/logger.py))
!(import! &self (library metta-attention synapse/community_detector.py))
!(import! &self (library metta-attention synapse/topology_metrics.py))
!(import! &self (library metta-attention experiments/logger))

; ECAN agents.
!(import! &self (library metta-attention attention/RentCollectionAgent/RentCollectionBaseAgent/RentCollectionBaseAgent))
!(import! &self (library metta-attention attention/RentCollectionAgent/WARentCollectionAgent/WARentCollectionAgent))
!(import! &self (library metta-attention attention/RentCollectionAgent/AFRentCollectionAgent/AFRentCollectionAgent))
!(import! &self (library metta-attention attention/RentCollectionAgent/AFRentCollectionAgent/AFRentCollectionAgent2))
!(import! &self (library metta-attention attention/ImportanceDiffusionAgent/ImportanceDiffusionBase/ImportanceDiffusionBase))
!(import! &self (library metta-attention attention/ImportanceDiffusionAgent/WAImportanceDiffusionAgent/WAImportanceDiffusionAgent))
!(import! &self (library metta-attention attention/ImportanceDiffusionAgent/AFImportanceDiffusionAgent/AFImportanceDiffusionAgent))
!(import! &self (library metta-attention attention/HebbianUpdatingAgent/HebbianUpdatingAgent))
!(import! &self (library metta-attention attention/HebbianCreationAgent/HebbianCreationAgent))
!(import! &self (library metta-attention attention/ForgettingAgent/ForgettingAgent))
!(import! &self (library metta-attention attention/runner-Def))

; Optional ECAN analysis and topology helpers.
!(import! &self (library metta-attention synapse/utils))
!(import! &self (library metta-attention synapse/synapse))

; tests
!(import! &self (library metta-attention tests/all-tests))

