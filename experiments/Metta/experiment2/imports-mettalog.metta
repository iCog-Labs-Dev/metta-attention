; ============================================================================
; OPTIMIZED IMPORT SYSTEM FOR EXPERIMENT2-METTALOG
; ============================================================================
; This file centralizes all imports for the experiment2-mettalog.metta
; Organized by functional groups for better maintainability and performance

; ============================================================================
; CORE SYSTEM REGISTRATION
; ============================================================================
!(register-module! ../../../../metta-attention)

; ============================================================================
; ATTENTION SYSTEM CORE
; ============================================================================
; Core attention parameters and configuration
!(import! &self metta-attention:attention:AttentionParam)
!(import! &self metta-attention:attention:Neighbors)

; ============================================================================
; ATTENTION AGENTS
; ============================================================================
; Forgetting Agent
!(import! &self metta-attention:attention:ForgettingAgent/ForgettingAgent)

; Rent Collection Agents
!(import! &self metta-attention:attention:RentCollectionAgent/RentCollectionBaseAgent/RentCollectionBaseAgent)
!(import! &self metta-attention:attention:RentCollectionAgent/WARentCollectionAgent/WARentCollectionAgent)
!(import! &self metta-attention:attention:RentCollectionAgent/AFRentCollectionAgent/AFRentCollectionAgent)

; Importance Diffusion Agents
!(import! &self metta-attention:attention:ImportanceDiffusionAgent/ImportanceDiffusionBase/ImportanceDiffusionBase)
!(import! &self metta-attention:attention:ImportanceDiffusionAgent/WAImportanceDiffusionAgent/WAImportanceDiffusionAgent)
!(import! &self metta-attention:attention:ImportanceDiffusionAgent/AFImportanceDiffusionAgent/AFImportanceDiffusionAgent)

; Hebbian Learning Agents
!(import! &self metta-attention:attention:HebbianUpdatingAgent/HebbianUpdatingAgent)
!(import! &self metta-attention:attention:HebbianCreationAgent/HebbianCreationAgent)

; ============================================================================
; EXPERIMENT FRAMEWORK
; ============================================================================
; Runner definitions and logging system
!(import! &self metta-attention:experiments:runner-Def)
!(import! &self metta-attention:experiments:logger)

; ============================================================================
; ATTENTION BANK UTILITIES
; ============================================================================
; Helper functions and utilities
!(import! &self metta-attention:attention-bank:utilities/helper-functions)
!(import! &self metta-attention:attention-bank:utilities/recentVal)

; Attention value management
!(import! &self metta-attention:attention-bank:attention-value/getter-and-setter)

; ============================================================================
; ATTENTION BANK CORE COMPONENTS
; ============================================================================
; Atom bins and content management
!(import! &self metta-attention:attention-bank:bank/atom-bins/get-min-max-content)
!(import! &self metta-attention:attention-bank:bank/atom-bins/atombins)

; Core attention bank
!(import! &self metta-attention:attention-bank:bank/attention-bank)

; Attentional focus management
!(import! &self metta-attention:attention-bank:bank/attentional-focus/attentional-focus)

; Importance and diffusion systems
!(import! &self metta-attention:attention-bank:bank/importance-index/importance-index)
!(import! &self metta-attention:attention-bank:bank/stochastic-importance-diffusion/stochastic-importance-diffusion)

; ============================================================================
; EXPERIMENT DATA SPACES
; ============================================================================
; Knowledge base and sentence data
!(import! &tempspace metta-attention:experiments:Metta/experiment2/data/sent-kb)
!(import! &insect metta-attention:experiments:Metta/experiment2/data/insect-sent)
!(import! &poison metta-attention:experiments:Metta/experiment2/data/poison-sent)

; ============================================================================
; IMPORT SYSTEM COMPLETE
; ============================================================================
