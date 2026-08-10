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

; ==============================================================================
; Hyperparameters & Seed Data Setup
; ==============================================================================

!(updateAttentionParam FUNDS_STI        100000.0)
!(updateAttentionParam FUNDS_LTI        100000.0)
!(updateAttentionParam TARGET_STI       5000.0)
!(updateAttentionParam TARGET_LTI       5000.0)
!(updateAttentionParam MAX_AF_SIZE      10.0)

; Seed atoms with Attention Values
!(setAv util-atom-a (900.0 800.0 0.0))
!(setAv util-atom-b (850.0 750.0 0.0))
!(setAv util-atom-c (800.0 700.0 0.0))
!(setAv util-atom-d (750.0 650.0 0.0))
!(setAv util-atom-e (700.0 600.0 0.0))

; Seed Hebbian links with Strength Truth Values
!(setStv (ASYMMETRIC_HEBBIAN_LINK util-atom-a util-atom-b) (0.8 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK util-atom-b util-atom-c) (0.7 0.8))
!(setStv (ASYMMETRIC_HEBBIAN_LINK util-atom-c util-atom-d) (0.6 0.7))
!(setStv (ASYMMETRIC_HEBBIAN_LINK util-atom-d util-atom-e) (0.5 0.6))
!(setStv (ASYMMETRIC_HEBBIAN_LINK util-atom-e util-atom-a) (0.4 0.5))

; ==============================================================================
; Synapse Utils Profiling (utils.metta)
; ==============================================================================

; recordCipSeries
(= (profileRecordCipSeries $n)
   (if (<= $n 0)
       0
       (let* (($_ (recordCipSeries)))
             (profileRecordCipSeries (- $n 1))))
)

; updateAtomHistory & getStiSeries
(= (profileUpdateAtomHistory $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (updateAtomHistory util-atom-a (+ 800.0 $n) $n))
               ($_ (getStiSeries util-atom-a))
             )
             (profileUpdateAtomHistory (- $n 1))))
)

; getTotalSti
(= (profileGetTotalSti $n)
   (if (<= $n 0)
       0
       (let* (($_ (getTotalSti (util-atom-a util-atom-b util-atom-c util-atom-d) 0)))
             (profileGetTotalSti (- $n 1))))
)

; getHebLinks & getHebLinksWithValues
(= (profileGetHebLinks $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (getHebLinks (util-atom-a util-atom-b util-atom-c) ()))
               ($_ (getHebLinksWithValues (util-atom-a util-atom-b util-atom-c) ()))
             )
             (profileGetHebLinks (- $n 1))))
)

; variance & variance-uniform
(= (profileVariance $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (variance (900.0 850.0 800.0 750.0 700.0)))
               ($_ (variance-uniform (900.0 850.0 800.0 750.0 700.0)))
             )
             (profileVariance (- $n 1))))
)

; identifyAllHebbianModules & identifyModules
(= (profileIdentifyModules $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (identifyAllHebbianModules))
               ($_ (identifyModules (util-atom-a util-atom-b util-atom-c) (getHebLinksWithValues (util-atom-a util-atom-b) ())))
             )
             (profileIdentifyModules (- $n 1))))
)

; pearsonCorrelation & pearsonCorrelationLists
(= (profilePearsonCorrelation $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (pearsonCorrelation (util-atom-a util-atom-b util-atom-c) 800.0 700.0))
               ($_ (pearsonCorrelationLists (10.0 20.0 30.0 40.0) (15.0 25.0 35.0 45.0)))
             )
             (profilePearsonCorrelation (- $n 1))))
)

; temporalConjunction & measureCoherence
(= (profileCoherenceAndConjunction $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (temporalConjunction util-atom-a util-atom-b))
               ($_ (measureCoherence (util-atom-a util-atom-b util-atom-c)))
             )
             (profileCoherenceAndConjunction (- $n 1))))
)

; shanon-entropy
(= (profileShanonEntropy $n)
   (if (<= $n 0)
       0
       (let* (($_ (shanon-entropy (0.3 0.3 0.2 0.1 0.1))))
             (profileShanonEntropy (- $n 1))))
)

; Execute Workloads
!(profileRecordCipSeries           200)
!(profileUpdateAtomHistory        1000)
!(profileGetTotalSti              2000)
!(profileGetHebLinks              1000)
!(profileVariance                 2000)
!(profileIdentifyModules           200)
!(profilePearsonCorrelation       1000)
!(profileCoherenceAndConjunction  1000)
!(profileShanonEntropy            1000)
