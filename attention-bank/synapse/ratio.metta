!(bind! &afsnap (new-space))
(= (afSnap) &afsnap)

!(bind! &cipspace (new-space))

; ## CIP Records

; this is cognitive integration point, it help us to Capture what cognition looked like at a specific boundary
; cip snapshoot could be
    ; every batch boundary
    ; every agent cycle
    ; every diffusion/update round
    ; every moment where AF changes meaningfully

(= (measure-all-metrics)
   (let* (
      ($af (getAfAtoms))
      ($afResource (afResourceUsage))
      ($stiConcentration (stiConcentration))
      ($linkDensity (linkDensity))
      ($connectionRatio (connectionRatio))
      ($preallocation (preallocationSpace))
      ($cognitiveSynergy (cognitiveSynergy))
      ($modulation (selectionModulation))
      ($coordination (globalCoordination $af))
      ($contextRetention (contextRetention))
      ($cognitiveMaintenance (cognitiveMaintenance))
      ($effectiveness (getEffectiveness))
   )
   (
    (afResource $afResource)
    (sticoncentration $stiConcentration)
    (linkdensity $linkDensity)
    (connectionratio $connectionRatio)
    (preallocation $preallocation)
    (cognitivesynergy $cognitiveSynergy)
    (modulation $modulation)
    (coordination $coordination)
    (contextretention $contextRetention)
    (cognitivemaintenance $cognitiveMaintenance)
    (effectiveness $effectiveness)
)))

(= (updateMaxIndex)
    (let $index 
        (collapse (match &cipspace (maxIndex $cindex) $cindex))
        (if (== $index ())
            (add-atom &cipspace (maxIndex 0))
            (let*
                (
                    ($num (car-atom $index))
                    ($newIndex (+ 1 $num))
                )
                (
                    (remove-atom &cipspace (maxIndex $num))
                    (add-atom &cipspace (maxIndex $newIndex))
                )
            )
        )
    )
)

(= (initialize-baseline-cip)
   (let*
      (
          ($af (getAfAtoms))
          ($metrics (measure-all-metrics))
          ($time (current-time))
          ($cip0 (CIPSnapshot 0 $time $af $metrics))
          ($_ (add-atom &cipspace $cip0))
          ($stiSeries (recordCipSeries))
        )
        $cip0 
   )
)

(= (get-lattest-cip-index)
    (let $res 
        (collapse (match &cipspace (maxIndex $index) $index))
        (if (== $res ())
            0
            (car-atom $res)
        )
    )
)

(= (get-cip-af $targetIndex)
   (let $res (collapse (match &cipspace (CIPSnapshot $targetIndex $time $af $matrice) $af))
       (if (== $res ())
           ()
           (car-atom $res)
       )
   )
)

(= (get-cip-af-or-empty $targetIndex)
   (let $af (get-cip-af $targetIndex)
       (if (== $af ())
           ()
           $af
       )
   )
)

(= (get-cip-snapshots $index)
   (let $cip (collapse (match &cipspace (CIPSnapshot $index $time $af $matrice) (CIPSnapshot $index $time $af $matrice)))
       (if (== $cip ())
           ()
           (car-atom $cip)
       )
   )
)

; (: transitiontonextcip (-> CIPSnapshot CIPSnapshot))
(= (transition-to-next-cip)
    (let*
      (
         ($update (updateMaxIndex))
         ($index (get-lattest-cip-index))
         ($newIndex (+ $index 1))
         ($af (getAfAtoms))
         ($metrics (measure-all-metrics))
         ($time (current-time))
         ($_ (add-atom &cipspace (CIPSnapshot $newIndex $time $af $metrics)))
         ($stiSeries (recordCipSeries))
      )
      (CIPSnapshot
          $newIndex
          $time
          $af
          $metrics
      )
   )
)

; ## Resource Cost Functions

; this is the ratio of the number of atoms inside af atom over the total number of atoms in typespace
(= (afResourceUsage)
    (let $allSize
        (size-atom (getAllAtomsWithBins))
        (if (> $allSize 0)
            (/ (size-atom (getAfAtoms)) $allSize)
            0.0
        )
    )
)


; the ratio between af sti and typespace sti
(= (stiConcentration)
    (let*
        (
            ($afSti (getTotalSti (getAfAtoms) 0))
            ($totalSti (getTotalSti (getAllAtomsWithBins) 0))
        )
        (if (> $totalSti 0)
            (/ $afSti $totalSti)
            0.0
        )
    )
)


; the ratio between the total hebbian link and hebbian link inside af atoms
(= (linkDensity)
    (let*
        (
            ($afAtoms (getAfAtoms))
            ($afSize (size-atom $afAtoms))
            ($hebLinks (size-atom (getHebLinks $afAtoms ())))
            ($maxHeblink (* $afSize (- $afSize 1)))
        )
        (if (> $maxHeblink 0)
            (/ $hebLinks $maxHeblink)
            0.0
        )
    )
)



; ## Effectiveness Calculation


(= (totalResourceCost $metrics)
    (let* ( 
            ($afRatio (getMetrics afResource $metrics))
            ($stiRatio (getMetrics sticoncentration $metrics))
            ($densityRatio (getMetrics linkdensity $metrics))

            ($costAf (* $afRatio (weight-afRatio)))
            ($costSti (* $stiRatio (weight-stiRatio)))
            ($costLink (* $densityRatio (weight-densityRatio)))
        ) 
        
        (+ (+ $costAf $costSti) $costLink)
    )
)

(= (getMetricsFromSnapshot ()) 
    ()
)

(= (getMetricsFromSnapshot (CIPSnapshot $index $time $af $metrics))
     $metrics
)

(= (aggregateMetricDelta $baseline $current)
    (let* (
            ($baseMetrics (getMetricsFromSnapshot $baseline))
            ($currMetrics (getMetricsFromSnapshot $current))
            ($baseScore (averageMetricScore $baseMetrics))
            ($currScore (averageMetricScore $currMetrics))
        )
        (- $currScore $baseScore)
    )
)

(= (calculateEffectiveness $baseline $current)
    (let* (
            ($currMetrics (getMetricsFromSnapshot $current))
            ($perfDelta (aggregateMetricDelta $baseline $current))
            ($resourceCost (totalResourceCost $currMetrics))
        )
        (if (> $resourceCost 0)
            (/ $perfDelta $resourceCost)
            0.0
        )
    )
)

(= (baselineCip)
   (get-cip-snapshots 0)
)

(= (localEffectiveness)
   (calculateEffectiveness
      (get-cip-snapshots
          (- (get-lattest-cip-index) 1))
      (get-cip-snapshots
          (get-lattest-cip-index))
   )
)

(= (globalEffectiveness)
   (calculateEffectiveness
      (baselineCip)
      (get-cip-snapshots
         (get-lattest-cip-index))
   )
)

(= (getEffectiveness)
   (globalEffectiveness)
)

; ## Minimal Viable Evaluation

; AF coherence : me asure- cohere nce restricted to current AF members
(= (afCoherence)
   (measureCoherence (getAfAtoms))
)

; this tell us the ratio of the intersection atoms between prevcip and currcip over thire unique total atom

(= (contextRetention $prevCip $currCip)
    (let*
        (
            ($overlap (size-atom (intersection-atom $currCip $prevCip)))
            ($unionSize (+ (size-atom $prevCip) (- (size-atom $currCip) $overlap)))
        )
        (if (> $unionSize 0)
            (/ $overlap $unionSize)
            0.0
        )
    )
)

(= (contextRetention)
    (let*
        (
            ($prevCip (get-cip-af (get-lattest-cip-index)))
            ($currCip (getAfAtoms))
        )
        (contextRetention $prevCip $currCip)
    )
)

; ## PHASE I: Assessment
 
; determine the Pearson correlation between sti series and lti
; Cognitive Synergy : Pearson correlation between each atoms
; time-averaged STI and its current LTI

(= (cognitiveSynergy) ;; previously called correlation
    (let*
        (
            ($atoms (getAllAtomsWithBins))
            ($sizeAtoms (size-atom $atoms))
        )
        (if (> $sizeAtoms 0)
            (let*
                (
                    ($stiSeries (map-atom $atoms get-sti-series))
                    ($stival (map-atom $stiSeries averageList))
                    ($ltival (map-atom $atoms getLti))
                    ($sizeSti (size-atom $stival))
                    ($sizeLti (size-atom $ltival))
                )
                (if (and (> $sizeSti 0) (> $sizeLti 0))
                    (pearsonCorrelationLists $stival $ltival)
                    0.0
                )
            )
            0.0
        )
    )
)


; we get all the atoms and thire sti
; we find the variance and thire uniform variance
; then we calculate variance over uniform variance

(= (selectionModulation)
    (let*
        (
            ($atoms (getAllAtomsWithBins))
            ($stiValue (map-atom $atoms getSti))
            ($variance (variance $stiValue))
            ($maxVariance (variance-uniform $stiValue)) ; the doc pass count(stiValue) for uniform variance??
        )
        (if (> $maxVariance 0)
            (/ $variance $maxVariance)
            0.0
        )
    )
)

; we get the af atoms and thire hebbian links
; we take all the links and we find if there is any target atom inside the links that is already inside af atoms
; then we sum and see how many of them are already inside af atom
; then we return the total already existing atoms over the number of total af links
(= (connectionRatio)
    (let*
        (
            ($afAtoms (getAfAtoms))
            ($allAfLinks (getHebLinks $afAtoms ()))
            ($totalLinks (size-atom $allAfLinks)) ; seems to me the sum of source and target link atoms

            ;; map over links to get the internal ones
            ($internalFlags (map-atom $allAfLinks $link (isInternalLink $link $afAtoms)))
            ($internalLinks (foldl-atom $internalFlags 0 $acc $x (+ $acc $x)))
        )
        (if (> $totalLinks 0)
            (/ $internalLinks $totalLinks)
            0.0
        )
    )
)

 
; ## PHASE II: Audits

; this is the ratio of the entropy of sti distribution over the maximum entropy of uniform distribution
(= (preallocationSpace)
    (let*
        (
            ($allAtoms (getAllAtomsWithBins))
            ($totalAtoms (size-atom $allAtoms))
        )
        (if (> $totalAtoms 0)
            (let*
                (
                    ($stiValues (map-atom $allAtoms $atom (getSti $atom)))
                    ($minSti (min-atom $stiValues))
                    ($shifted (map-atom $stiValues $val (- $val $minSti)))
                    ($tt (foldl-atom $shifted 0 $acc $x (+ $acc $x)))
                    ($total (if (== $tt 0.0) 1.0 $tt))
                    ($stiDistribution (map-atom $shifted $s (/ $s $total)))
                    ($entropy (shanon-entropy $stiDistribution))
                    ($maxEntropy (log2-math $totalAtoms))
                )
                (if (> $maxEntropy 0)
                    (/ $entropy $maxEntropy)
                    0.0
                )
            )
            0.0
        )
    )
)


; ## PHASE III: Test Probing

; Average pairwise AF Jaccard similarity across consecutive CIP snapshots
; this implementation should be changed based on the new CIP implementation,
; we can calculate the retention for pair of transition and then average the overlap

(= (has-cip-snapshots)
    (let $indexes (collapse (match &cipspace (CIPSnapshot $index $time $af $matrice) $index))
        (if (== $indexes ()) False True)
    )
)

(= (cip-af-series $startIndex $endIndex)
    (if (> $startIndex $endIndex)
        ()
        (cons-atom
            (get-cip-af $startIndex)
            (cip-af-series (+ $startIndex 1) $endIndex)
        )
    )
)

(= (retention-average $sum $count)
    (if (> $count 0.0)
        (/ $sum $count)
        0.0
    )
)

(= (average-context-retention-pairs $series)
    (average-context-retention-pairs-acc $series 0.0 0.0)
)

(= (average-context-retention-pairs-acc () $sum $count)
    (retention-average $sum $count)
)

(= (average-context-retention-pairs-acc (cons $last ()) $sum $count)
    (retention-average $sum $count)
)

(= (average-context-retention-pairs-acc (cons $prev (cons $curr $tail)) $sum $count)
    (let $retention (contextRetention $prev $curr)
        (average-context-retention-pairs-acc
            (cons $curr $tail)
            (+ $sum $retention)
            (+ $count 1.0)
        )
    )
)

(= (cognitiveMaintenance)
    (let*
        (
            ($storedSeries (if (has-cip-snapshots) (cip-af-series 0 (get-lattest-cip-index)) ()))
        )
        (average-context-retention-pairs $storedSeries)
    )
)



; this measure the global coordination for a given state, it is the geometric mean of local coherence and global coherence
(= (globalCoordination $state)
    (let*
        (
            ($afLinks (getAllHebLinks))
            ($modules (identifyModules $state $afLinks))
            ($localCoherences (map-atom $modules $mod (measureCoherence $mod)))
            ($localCoherence (averageList $localCoherences))

            ($interFlags (map-atom $afLinks $link (isExternalLink $link $modules)))
            ($interLinks (filterLinksByFlag $afLinks $interFlags))

            ($linkProbs (map-atom $interLinks getProbability))
            ($conjunctions (map-atom $interLinks temporalConjunctionLink))
            ($globalCoherence (pearsonCorrelationLists $linkProbs $conjunctions))

            ($product (* $localCoherence $globalCoherence))
            ($coordination (if (> $product 0) (sqrt-math $product) 0.0))
        )
        $coordination
    )
)


; ## PHASE IV: Benchmarking

(: gainedEfficience (-> CipSnapshot CipSnapshot CipSnapshot CipSnapshot Number))

; ## Topological Analysis

; persistent homology will be implemented here

