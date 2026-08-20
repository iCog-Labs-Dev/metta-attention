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

; Effectiveness Calculation Chain Profiling

; getMetricsFromSnapshot
(= (profileGetMetricsFromSnapshot $n)
   (if (<= $n 0)
       0
       (let* (($snap (get-cip-snapshots 0))
              ($_ (getMetricsFromSnapshot $snap)))
             (profileGetMetricsFromSnapshot (- $n 1))))
)

; getTotalResourceCost
(= (profileGetTotalResourceCost $n)
   (if (<= $n 0)
       0
       (let* (($snap    (get-cip-snapshots 0))
              ($metrics (getMetricsFromSnapshot $snap))
              ($_ (getTotalResourceCost $metrics)))
             (profileGetTotalResourceCost (- $n 1))))
)

; getAggregateMetricDelta  (requires >= 2 CIP snapshots -- run after profileTransitionToNextCip)
(= (profileGetAggregateMetricDelta $n)
   (if (<= $n 0)
       0
       (let* (($snap0 (get-cip-snapshots 0))
              ($snap1 (get-cip-snapshots 1))
              ($_ (getAggregateMetricDelta $snap0 $snap1)))
             (profileGetAggregateMetricDelta (- $n 1))))
)

; calculateEffectiveness  (requires >= 2 CIP snapshots)
(= (profileCalculateEffectiveness $n)
   (if (<= $n 0)
       0
       (let* (($snap0 (get-cip-snapshots 0))
              ($snap1 (get-cip-snapshots 1))
              ($_ (calculateEffectiveness $snap0 $snap1)))
             (profileCalculateEffectiveness (- $n 1))))
)

; getGlobalEffectiveness
(= (profileGetGlobalEffectiveness $n)
   (if (<= $n 0)
       0
       (let* (($_ (getGlobalEffectiveness)))
             (profileGetGlobalEffectiveness (- $n 1))))
)

; getGainedEfficiency
(= (profileGetGainedEfficiency $n)
   (if (<= $n 0)
       0
       (let* (($index (get-lattest-cip-index))
              ($_ (getGainedEfficiency $index)))
             (profileGetGainedEfficiency (- $n 1))))
)

; getRedundancyDegradation
(= (profileGetRedundancyDegradation $n)
   (if (<= $n 0)
       0
       (let* (($index (get-lattest-cip-index))
              ($_ (getRedundancyDegradation $index)))
             (profileGetRedundancyDegradation (- $n 1))))
)


; CIP Internal Helper Profiling

; updateMaxIndex
(= (profileUpdateMaxIndex $n)
   (if (<= $n 0)
       0
       (let* (($_ (updateMaxIndex)))
             (profileUpdateMaxIndex (- $n 1))))
)

; get-lattest-cip-index
(= (profileGetLattestCipIndex $n)
   (if (<= $n 0)
       0
       (let* (($_ (get-lattest-cip-index)))
             (profileGetLattestCipIndex (- $n 1))))
)

; get-cip-snapshots
(= (profileGetCipSnapshots $n)
   (if (<= $n 0)
       0
       (let* (($_ (get-cip-snapshots 0)))
             (profileGetCipSnapshots (- $n 1))))
)

; get-cip-af
(= (profileGetCipAf $n)
   (if (<= $n 0)
       0
       (let* (($_ (get-cip-af 0)))
             (profileGetCipAf (- $n 1))))
)

; has-cip-snapshots
(= (profileHasCipSnapshots $n)
   (if (<= $n 0)
       0
       (let* (($_ (has-cip-snapshots)))
             (profileHasCipSnapshots (- $n 1))))
)

; cip-af-series  (fixed bound=3: avoids O(N*iters) cost from accumulated snapshots)
; Using get-lattest-cip-index here would make cost grow with every prior profileTransitionToNextCip call.
(= (profileCipAfSeries $n)
   (if (<= $n 0)
       0
       (let* (($_ (cip-af-series 0 3)))
             (profileCipAfSeries (- $n 1))))
)


; getContextRetention 2-arg Variant Profiling

; getContextRetention $prevCip $currCip  (direct 2-arg call, isolated from 0-arg dispatch)
(= (profileGetContextRetention2Arg $n)
   (if (<= $n 0)
       0
       (let* (($prev (get-cip-af 0))
              ($curr (getAfAtoms))
              ($_ (getContextRetention $prev $curr)))
             (profileGetContextRetention2Arg (- $n 1))))
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

; Effectiveness chain
!(profileGetMetricsFromSnapshot       500)
!(profileGetTotalResourceCost         500)
!(profileGetAggregateMetricDelta       500)
!(profileCalculateEffectiveness        500)
!(profileGetGlobalEffectiveness        500)

; (used only when comparing against a baseline run) rather than core real-time attentional cycle operations
; !(profileGetGainedEfficiency           500)
; !(profileGetRedundancyDegradation      500)

; CIP internals
!(profileUpdateMaxIndex     500)
!(profileGetLattestCipIndex 500)
!(profileGetCipSnapshots    500)
!(profileGetCipAf           500)
!(profileHasCipSnapshots    500)
!(profileCipAfSeries       500)  ; changed to fixed bound=3, not accumulated index.

; 2-arg context retention
!(profileGetContextRetention2Arg   500)
