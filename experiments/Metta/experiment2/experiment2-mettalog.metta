; ============================================================================
; EXPERIMENT2-METTALOG - OPTIMIZED VERSION
; ============================================================================
; Professional attention system experiment with optimized import structure
; Uses centralized import system for better maintainability and performance

; Import all required modules through centralized import system
!(import! &self imports-mettalog)

; ============================================================================
; ATTENTION PARAMETER CONFIGURATION
; ============================================================================
; Optimized parameters for stable performance and memory usage
!(updateAttentionParam STI_FUNDS_BUFFER 99900)
!(updateAttentionParam LTI_FUNDS_BUFFER 99900)
!(updateAttentionParam TARGET_STI 99900)
!(updateAttentionParam TARGET_LTI 99900)
!(updateAttentionParam AFRentFrequency 1.0)
!(updateAttentionParam MAX_AF_SIZE 12)

; ============================================================================
; KNOWLEDGE BASE INITIALIZATION
; ============================================================================
; Load knowledge base atoms into working space
(= (spaceAdder) (get-atoms &tempspace))
!(spaceAdder)

; ============================================================================
; EXPERIMENT LOGGING INITIALIZATION
; ============================================================================
; Initialize logging system for experiment tracking
!(start_log (attentionParam) experiments/Metta/experiment2)

; ============================================================================
; CORE EXPERIMENT LOGIC
; ============================================================================
; Main experiment function for processing insect and poison sentences
; Processes words sequentially through the attention system
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
                    ; Stimulate current word with attention value
                    (stimulate $now 700)
                    ; Display word in terminal
                    (println! $now)
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
; POST-EXPERIMENT ANALYSIS
; ============================================================================
; Retrieve final atom list and type space for analysis
!(getAtomList)
!(get-atoms (TypeSpace))

; ============================================================================
; EXPERIMENT2-METTALOG COMPLETE
; ============================================================================
