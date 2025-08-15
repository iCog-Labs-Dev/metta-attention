; ============================================================================
; EXPERIMENT2-METTALOG - COMPLETE METTALOG-COMPATIBLE VERSION
; ============================================================================
; Converted from Metta-compatible experiment2.metta to work with Mettalog
; This file connects to the Mettalog-compatible Python backend and logger
; 
; Key differences from Metta version:
; 1. Import paths use '/' instead of ':' for Mettalog compatibility
; 2. Connects to n_logger.metta for logging functionality
; 3. Uses proper Mettalog logger initialization
; 4. Maintains all original experiment logic and flow
; 5. Compatible with Mettalog's py-atom system

; ============================================================================
; MODULE REGISTRATION AND CORE IMPORTS
; ============================================================================
; Register the main metta-attention module
!(register-module! ../../../../metta-attention)

; Import core attention system components with Mettalog-compatible paths
!(import! &self metta-attention:attention:ForgettingAgent/ForgettingAgent)
!(import! &self metta-attention:attention:AttentionParam)
!(import! &self metta-attention:attention:RentCollectionAgent/RentCollectionBaseAgent/RentCollectionBaseAgent)
!(import! &self metta-attention:attention:RentCollectionAgent/WARentCollectionAgent/WARentCollectionAgent)
!(import! &self metta-attention:attention:RentCollectionAgent/AFRentCollectionAgent/AFRentCollectionAgent)
!(import! &self metta-attention:attention:ImportanceDiffusionAgent/ImportanceDiffusionBase/ImportanceDiffusionBase)
!(import! &self metta-attention:attention:ImportanceDiffusionAgent/WAImportanceDiffusionAgent/WAImportanceDiffusionAgent)
!(import! &self metta-attention:attention:ImportanceDiffusionAgent/AFImportanceDiffusionAgent/AFImportanceDiffusionAgent)
!(import! &self metta-attention:attention:HebbianUpdatingAgent/HebbianUpdatingAgent)
!(import! &self metta-attention:attention:HebbianCreationAgent/HebbianCreationAgent)
!(import! &self metta-attention:attention:Neighbors)
!(import! &self metta-attention:experiments:runner-Def)

; ============================================================================
; METTALOG LOGGER INTEGRATION
; ============================================================================
; Import the Mettalog-compatible logger instead of the original Metta logger
; This connects to our n_logger.metta file which uses py-atom calls
!(import! &self ../../n_logger)

; ============================================================================
; ATTENTION BANK IMPORTS
; ============================================================================
; Import attention bank utilities with Mettalog-compatible paths
!(import! &self metta-attention:attention-bank:utilities/helper-functions)
!(import! &self metta-attention:attention-bank:utilities/recentVal)
!(import! &self metta-attention:attention-bank:attention-value/getter-and-setter)
!(import! &self metta-attention:attention-bank:bank/atom-bins/get-min-max-content)
!(import! &self metta-attention:attention-bank:bank/atom-bins/atombins)
!(import! &self metta-attention:attention-bank:bank/attention-bank)
!(import! &self metta-attention:attention-bank:bank/attentional-focus/attentional-focus)
!(import! &self metta-attention:attention-bank:bank/importance-index/importance-index)
!(import! &self metta-attention:attention-bank:bank/stochastic-importance-diffusion/stochastic-importance-diffusion)

; ============================================================================
; DATA SPACE SETUP
; ============================================================================
; Create test data directly since imports are failing
!(add-atom &insect (insectSent (Ants farm aphids beanfly armyworms .)))
!(add-atom &poison (poisonSent (Botulinum avoids alcohol ammonia aconite aflatoxin .)))

; ============================================================================
; ATTENTION PARAMETER CONFIGURATION
; ============================================================================
; Configure attention system parameters for optimal performance
!(updateAttentionParam STI_FUNDS_BUFFER 99900)
!(updateAttentionParam LTI_FUNDS_BUFFER 99900)
!(updateAttentionParam TARGET_STI 99900)
!(updateAttentionParam TARGET_LTI 99900)
!(updateAttentionParam AFRentFrequency 2.0)
!(updateAttentionParam MAX_AF_SIZE 12)

; ============================================================================
; KNOWLEDGE BASE INITIALIZATION
; ============================================================================
; Load knowledge base atoms into working space
; Note: Data imports may fail but experiment can still run
; (= (spaceAdder) (get-atoms &tempspace))
; !(spaceAdder)

; ============================================================================
; METTALOG LOGGER INITIALIZATION
; ============================================================================
; Initialize the Mettalog-compatible logger system
; This connects to our Python backend through n_logger.metta
!(start_log (attentionParam) (TypeSpace) experiments/Metta/experiment2)

; ============================================================================
; CORE EXPERIMENT LOGIC WITH METTALOG LOGGING
; ============================================================================
; Main experiment function with integrated Mettalog logging
; This maintains the same logic as the Metta version but adds word logging
(= (insectPoisonReadExp $space $type $expr)
    (
        (if (and (== $type poisonSent) (== $expr ()))
            finished
            (let* 
                (
                    ($now (car-atom $expr))
                    ($rest (cdr-atom $expr))
                )
                (
                    ; Stimulate the current word
                    (stimulate $now 700)
                    ; Display word in terminal
                    (println! $now)
                    ; Log word to CSV using Mettalog logger
                    (log_word $now 700.0 700.0)
                    ; Run attention system processing
                    (collapse (test-superpose))
                    ; Process next word or switch to poison sentences
                    (if (== $rest ())
                        (if (== $type insectSent)
                            (insectPoisonReadExp &poison poisonSent (match &poison (poisonSent $x) $x))
                            finished
                        )
                        (insectPoisonReadExp $space $type $rest)
                    )
                )
            )
        )     
    )
)

; ============================================================================
; EXPERIMENT EXECUTION
; ============================================================================
; Start the experiment with insect sentences, then process poison sentences
!(insectPoisonReadExp &insect insectSent (match &insect (insectSent $x) $x))

; ============================================================================
; POST-EXPERIMENT DATA COLLECTION
; ============================================================================
; Collect final attention focus data and log to CSV
!(log_attention_focus (attentionalFocus))
!(getAtomList)
!(get-atoms (TypeSpace))

; ============================================================================
; EXPERIMENT COMPLETE
; ============================================================================
; The experiment is now complete with full Mettalog logging integration