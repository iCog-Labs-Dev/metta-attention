!(import! &self lib/lib_he)
!(import! &self lib/lib_spaces)
!(import! &self ../attention/AttentionParam)
!(import! &self ../attention/baching)
!(import! &self ../attention-bank/utilities/helper-functions)
!(import! &self ../attention-bank/utilities/recentVal)
!(import! &self ../attention-bank/attention-value/getter-and-setter)
!(import! &self ../attention-bank/bank/importance-index/importance-index)
!(import! &self ../attention/Neighbors)
!(import! &self ../attention-bank/bank/attention-bank)
!(import! &self ../attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../attention-bank/bank/stochastic-importance-diffusion/stochastic-importance-diffusion)
!(import! &self ../attention-bank/synapse/utils)
!(import! &self ../attention-bank/synapse/tentativeratio)

; ==============================================================================
; Hyperparameters & Seed Data Setup
; ==============================================================================

!(updateAttentionParam FUNDS_STI        100000.0)
!(updateAttentionParam FUNDS_LTI        100000.0)
!(updateAttentionParam TARGET_STI       5000.0)
!(updateAttentionParam TARGET_LTI       5000.0)
!(updateAttentionParam MAX_AF_SIZE      10.0)

; Seed atoms with Attention Values
!(setAv tr-atom-a (900.0 800.0 0.0))
!(setAv tr-atom-b (850.0 750.0 0.0))
!(setAv tr-atom-c (800.0 700.0 0.0))

; ==============================================================================
; Synapse Tentative Ratio Profiling (tentativeratio.metta)
; ==============================================================================

; initializeBaselineClip, transitionToNextClip, & gainedEfficiency
(= (profileTentativeRatio $n)
   (if (<= $n 0)
       0
       (let* (
               ($base (initializeBaselineClip (tr-atom-a tr-atom-b)))
               ($next (transitionToNextClip $base (tr-atom-a tr-atom-b tr-atom-c) ()))
               ($_ (gainedEfficiency (tr-atom-a tr-atom-b tr-atom-c) (tr-atom-a tr-atom-b)))
               ($_ (getClipIndex $next))
               ($_ (systemPerformance (tr-atom-a tr-atom-b)))
               ($_ (totalResourceCost (tr-atom-a tr-atom-b)))
             )
             (profileTentativeRatio (- $n 1))))
)

; Execute Workloads
!(profileTentativeRatio 500)
