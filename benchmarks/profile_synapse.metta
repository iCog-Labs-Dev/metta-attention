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
!(import! &self ../attention-bank/synapse/community_detector.py)
!(import! &self ../attention-bank/synapse/topology_metrics.py)
!(import! &self ../attention-bank/synapse/utils)
!(import! &self ../attention-bank/synapse/synapse)

; ==============================================================================
; Hyperparameters & Seed Data Setup
; ==============================================================================

!(updateAttentionParam FUNDS_STI        100000.0)
!(updateAttentionParam FUNDS_LTI        100000.0)
!(updateAttentionParam TARGET_STI       5000.0)
!(updateAttentionParam TARGET_LTI       5000.0)
!(updateAttentionParam MAX_AF_SIZE      10.0)

; Seed atoms with Attention Values
!(setAv syn-atom-a (900.0 800.0 0.0))
!(setAv syn-atom-b (850.0 750.0 0.0))
!(setAv syn-atom-c (800.0 700.0 0.0))
!(setAv syn-atom-d (750.0 650.0 0.0))
!(setAv syn-atom-e (700.0 600.0 0.0))
!(setAv syn-atom-f (650.0 550.0 0.0))
!(setAv syn-atom-g (600.0 500.0 0.0))
!(setAv syn-atom-h (550.0 450.0 0.0))

; Seed Hebbian links with Strength Truth Values
!(setStv (ASYMMETRIC_HEBBIAN_LINK syn-atom-a syn-atom-b) (0.8 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK syn-atom-b syn-atom-c) (0.7 0.8))
!(setStv (ASYMMETRIC_HEBBIAN_LINK syn-atom-c syn-atom-d) (0.6 0.7))
!(setStv (ASYMMETRIC_HEBBIAN_LINK syn-atom-d syn-atom-e) (0.5 0.6))
!(setStv (ASYMMETRIC_HEBBIAN_LINK syn-atom-e syn-atom-f) (0.4 0.5))
!(setStv (ASYMMETRIC_HEBBIAN_LINK syn-atom-f syn-atom-g) (0.3 0.4))
!(setStv (ASYMMETRIC_HEBBIAN_LINK syn-atom-g syn-atom-a) (0.2 0.3))

; ==============================================================================
; Synapse Core Metrics & CIP Lifecycle Profiling (synapse.metta)
; ==============================================================================

; measure-all-metrics
(= (profileMeasureAllMetrics $n)
   (if (<= $n 0)
       0
       (let* (($_ (measure-all-metrics)))
             (profileMeasureAllMetrics (- $n 1))))
)

; initialize-baseline-cip
(= (profileInitializeBaselineCip $n)
   (if (<= $n 0)
       0
       (let* (($_ (initialize-baseline-cip)))
             (profileInitializeBaselineCip (- $n 1))))
)

; transition-to-next-cip
(= (profileTransitionToNextCip $n)
   (if (<= $n 0)
       0
       (let* (($_ (transition-to-next-cip)))
             (profileTransitionToNextCip (- $n 1))))
)

; getAfResourceUsage
(= (profileGetAfResourceUsage $n)
   (if (<= $n 0)
       0
       (let* (($_ (getAfResourceUsage)))
             (profileGetAfResourceUsage (- $n 1))))
)

; getStiConcentration
(= (profileGetStiConcentration $n)
   (if (<= $n 0)
       0
       (let* (($_ (getStiConcentration)))
             (profileGetStiConcentration (- $n 1))))
)

; getLinkDensity
(= (profileGetLinkDensity $n)
   (if (<= $n 0)
       0
       (let* (($_ (getLinkDensity)))
             (profileGetLinkDensity (- $n 1))))
)

; getPreallocationSpace
(= (profileGetPreallocationSpace $n)
   (if (<= $n 0)
       0
       (let* (($_ (getPreallocationSpace)))
             (profileGetPreallocationSpace (- $n 1))))
)

; getCognitiveSynergy
(= (profileGetCognitiveSynergy $n)
   (if (<= $n 0)
       0
       (let* (($_ (getCognitiveSynergy)))
             (profileGetCognitiveSynergy (- $n 1))))
)

; getSelectionModulation
(= (profileGetSelectionModulation $n)
   (if (<= $n 0)
       0
       (let* (($_ (getSelectionModulation)))
             (profileGetSelectionModulation (- $n 1))))
)

; getConnectionRatio
(= (profileGetConnectionRatio $n)
   (if (<= $n 0)
       0
       (let* (($_ (getConnectionRatio)))
             (profileGetConnectionRatio (- $n 1))))
)

; getGlobalCoordination
(= (profileGetGlobalCoordination $n)
   (if (<= $n 0)
       0
       (let* (($_ (getGlobalCoordination (syn-atom-a syn-atom-b syn-atom-c syn-atom-d))))
             (profileGetGlobalCoordination (- $n 1))))
)

; getCognitiveMaintenance
(= (profileGetCognitiveMaintenance $n)
   (if (<= $n 0)
       0
       (let* (($_ (getCognitiveMaintenance)))
             (profileGetCognitiveMaintenance (- $n 1))))
)

; getEffectiveness / getGlobalEffectiveness / getLocalEffectiveness
(= (profileGetEffectiveness $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (getEffectiveness))
               ($_ (getLocalEffectiveness))
             )
             (profileGetEffectiveness (- $n 1))))
)

; getAfCoherence
(= (profileGetAfCoherence $n)
   (if (<= $n 0)
       0
       (let* (($_ (getAfCoherence)))
             (profileGetAfCoherence (- $n 1))))
)

; getContextRetention
(= (profileGetContextRetention $n)
   (if (<= $n 0)
       0
       (let* (($_ (getContextRetention)))
             (profileGetContextRetention (- $n 1))))
)

; topologyMetrics
(= (profileTopologyMetrics $n)
   (if (<= $n 0)
       0
       (let* (($_ (topologyMetrics)))
             (profileTopologyMetrics (- $n 1))))
)

; Execute Workloads
!(profileInitializeBaselineCip      50)
!(profileMeasureAllMetrics         200)
!(profileTransitionToNextCip        50)
!(profileGetAfResourceUsage       1000)
!(profileGetStiConcentration      1000)
!(profileGetLinkDensity           1000)
!(profileGetPreallocationSpace     500)
!(profileGetCognitiveSynergy       200)
!(profileGetSelectionModulation    500)
!(profileGetConnectionRatio       1000)
!(profileGetGlobalCoordination     200)
!(profileGetCognitiveMaintenance   200)
!(profileGetEffectiveness          300)
!(profileGetAfCoherence            500)
!(profileGetContextRetention       500)
!(profileTopologyMetrics           200)
