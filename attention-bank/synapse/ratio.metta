!(bind! &afsnap (new-space))
(= (afSnap) &afsnap)

(= (getTotalSti () $out) $out)
(= (getTotalSti (cons $head $tail) $out)
    (getTotalSti $tail (+ $out (getSti $head)))
)

(= (getHebLinks () $out) $out)
(= (getHebLinks (cons $head $tail) $out)
    (getHebLinks $tail 
        (union-atom 
            (collapse (match (TypeSpace) ((ASYMMETRIC_HEBBIAN_LINK $head $any) $val) (ASYMMETRIC_HEBBIAN_LINK $head $any)))
            $out
        )
    )
)

(= (square $value)
    (* $value $value)
)

(= (meanDiff $atom $meanSti $meanLti)
    (* (- (getSti $atom) $meanSti) (- (getLti $atom) $meanLti))
)

(= (pearsonCorrelation $afAtoms $meanSti $meanLti)
    (let*
        (
            ($numenator (foldl-atom (map-atom $afAtoms $x (meanDiff $x $meanSti $meanLti)) 0 $acc $x (+ $acc $x)))
            ($stiDistance (foldl-atom (map-atom $afAtoms $x (pow-math (- (getSti $x) $meanSti) 2)) 0 $acc $x (+ $acc $x)))
            ($ltiDistance (foldl-atom (map-atom $afAtoms $x (pow-math (- (getLti $x) $meanLti) 2)) 0 $acc $x (+ $acc $x)))
            ($denomenator (sqrt-math (* $stiDistance $ltiDistance)))
        )
        (/ $numenator $denomenator)
    )
)

(= (variance $stiValue) 
    (let*
        (
            ($mean (/ (foldl-atom $stiValue 0 $acc $x (+ $acc $x)) (size-atom $stiValue)))
            ($meanDiff (map-atom $stiValue $x (pow-math (- $x $mean) 2)))
            ($numenator (foldl-atom $meanDiff 0 $acc $x (+ $acc $x)))
        )
        (/ $numenator (size-atom $stiValue))
    )
)

(= (variance-uniform $size)
    (let*
        (
            ($max (max-atom $size))
            ($min (min-atom $size))
        )
        (/ (pow-math (- $max $min) 2) 12)
    )
)

(= (afResourceUsage)
    (let $allSize
        (size-atom (getAllAtomsWithBins))
        (if (> $allSize 0)
            (/ (size-atom (getAfAtoms)) $allSize)
            0.0
        )
    )
)

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

(= (correlation)
    (let*
        (
            ($afAtoms (getAfAtoms))
            ($stival (map-atom $afAtoms getSti))
            ($ltival (map-atom $afAtoms getLti))
            ($totalSti (foldl-atom $stival 0 $acc $x (+ $acc $x)))
            ($totalLti (foldl-atom $ltival 0 $acc $x (+ $acc $x)))
            ($meanSti (/ $totalSti (size-atom $stival)))
            ($meanLti (/ $totalLti (size-atom $ltival)))
        )
        (pearsonCorrelation $afAtoms $meanSti $meanLti)
    )
)

(= (contextRetention $prevState $state)
    (let*
        (
            ($overlap (size-atom (intersection-atom $state $prevState)))
            ($unionSize (+ (size-atom $prevState) (- (size-atom $state) $overlap)))
        )
        (/ $overlap $unionSize)
    )
)

(= (selectionModulation)
    (let* 
        (
            ($afAtoms (getAfAtoms))
            ($stiValue (map-atom $afAtoms getSti))
            ($variance (variance $stiValue))
            ($maxVariance (variance-uniform $stiValue))
            ($1 (println! (sti $maxVariance $variance )))
        )
        (/ $variance $maxVariance)
    )
)

(= (getLinkTarget (ASYMMETRIC_HEBBIAN_LINK $src $tgt)) $tgt)

(= (isInternalLink $link $afAtoms)
  (let*
     (
       ($tgt (getLinkTarget $link))
       ;; wrap target in tuple to use intersection-atom against the afAtoms
       ($overlap (size-atom (intersection-atom $afAtoms (cons $tgt ()))))
     )
     (if (> $overlap 0) 1 0)
  )
)

(= (connectionRatio)
  (let*
      (
        ($afAtoms (getAfAtoms))
        ($allAfLinks (getHebLinks $afAtoms ()))
        ($totalLinks (size-atom $allAfLinks))

        ;; map over links to get the internal ones
        ($internalFlags (map-atom $allAfLinks $link (isInternalLink $link $afAtoms))
        ($internalLinks (foldl-atom $internalFlags 0 $acc $x (+ $acc $x)))
      )
        (
        if (> $totalLinks 0)
          (/ $internalLinks $totalLinks)
          0.0
        )
  )
)

(= (entropyTerm $p)
     (if (> $p 0)
       (* $p (log2-math $p))
       0.0
     )
)

(= (preallocationSpace)
  (let* 
     (
        ($allAtoms (getAllAtomsWithBins))
        ($totalAtoms (size-atom $allAtoms))
        ($totalSti (getTotalSti $allAtoms 0))
        ($probabilities (map-atom $allAtoms $atom)(/ (getsti $atom) $totalSti))
        ($entropyTerms (map-atom $probabiliries $p (entropyTerm $p)))
        ($sumTerms (foldl-atom $entropyTerms 0 $acc $x (+ $acc $x)))
        ($entropy (* -1 $sumTerms))
        ($maxEntropy (log2-math $totalAtoms))
      )

        (if (> $maxEntropy 0)
            (/ $entropy $maxEntropy)
            0.0
        )
  )
)

;; cognitive maintainance
(= (cognitiveMaintainanceHelper () $sum $count)
     (if (> $count 0) (/ $sum $count) 0.0)
)

(= (cognitiveMaintainanceHelper (cons $single ()) $sum $count)
     (if (> $count 0) (/ $sum $count) 0.0)
)

(= (cognitiveMaintainanceHelper (cons $state1 (cons $state2 $tail)) $sum $count)
     (let*
          (
             ($retenttion (contextRetention $state1 $state2))
             ($newSum (+ $sum $retention))
             ($newCount (+ $count 1))
          )
     )
     (
       (cognitiveMaintainanceHelper (cons state2 $tail) $newSum $newCount)
     )
)
(= (cognitiveMaintainance $trajectory)
     (cognitiveMaintainanceHelper $trajectory 0.0 0)
)

(= (averageList $list)
    (let* 
         (
            ($sum (foldl-atom $list 0.0 $acc $x (+ $acc $x)))
            ($count (size-atom $list))
         )
         (if (> $count 0) (/ $sum $count) 0.0)
    )
)

;; internal coherence for a single module
(= (moduleInternalCoherence $moduleAtoms)
    (let*
        (
          ($moduleSize (size-atom $moduleAtoms))
          ($allLinks (getHebLinks $moduleAtoms ()))
          ($internalFlags (map-atom $allLinks $link (isInternalLink $link $moduleAtoms)))
          ($internalCount (foldl-atom $internalFlags 0 $acc $x (+ $acc $x)))

          ($maxLinks (* $moduleSize (- $moduleSize)))
        )
        (if (> $maxLinks 0) (/ $internalCount $maxLinks) 0.0)
     )
)

(= (globalCoordination $state)
    (let*
         (
            ($modules (identifyModules $state)) ;; todo -> write a module identifier

            ($localCoherences (map-atom $modules $mod (moduleInternalCoherence $mod)))
            ($localCoherence (averageList $localCoherences))
            ($allAtoms (getAllAtomsWithBins))
            ($totalLinks (size-atom (getHebLinks $allAtoms ())))
            
            ($internalCounts (map-atom $modules $mod 
                (foldl-atom (map-atom (getHebLinks $mod ()) $link (isInternalLink $link $mod)) 0 $acc $x (+ $acc $x))
            ))
            ($totalInternal (foldl-atom $internalCounts 0 $acc $x (+ $acc $x))

            ($totalExternal (- $totalLinks $totalInternal))
            ($globalCoherence(if (> $totalLinks 0) (/ $totalExternal $totalLinks) 0.0)

            ($coordination (sqrt-math (* *localCOherence *globalCoherence)))
         )
        $coordination
    )
)

(= (systemPerformance $state)
  ;; todo -> an actual performance metrics is required
  1.0
)

(= (totalResourceCost $state)
  ;; todo -> again an actual cost metrics is required, I will try out afResourceUsage
  1.0
)

(= (gainedEfficiency $optimizedState $baselineState)
    (let*
        (
           ($baselineCost (totalResourceCost $baselineState))
           ($optimizedCost (totalResourceCost $optimizedState))
           ($baselinePerf (systemPerformance $baselineState))
           ($optimizedPerf (systemPerformance $optimizedState))

           ($baselineEff
              (if (> $baselineCost 0) (/ $baselinePerf $baselineCost) 0.0)
           )
           ($optimizedEff 
                (if (> $optimizedCost 0) (/ $optimizedPerf $optimizedCost) 0.0)
           )

           ($efficiencyDiff (- $optimizedEff $baselineEff))
        ) 

        (if (> $baselineEff 0)
            (/ $efficiencyDiff $baselineEff)
            0.0
        )
    )
)



(= (getClipIndex (CIPSnapshot $index $state $time $metrics)) $index)

(= (currentTime)
 ;; bind to an actual time lib
 0 
)

(= (measureAllMetrics $state $trajectory)
   ((DummyMetric 1.0))
)

(= (initializeBaselineClip $initialState)
    (let*
        (
            ($metrics (measureAllMetrics $initialState))
            ($timestamp (currentTime))
        )
        (CIPSnapshot 0 initialState $timestamp $metrics)
    )
)

(= (transitionToNextClip $prevClip $newState $trajectory)
    (let*
        (
          ($prevIndex (getClipIndex $prevClip))
          ($newIndex (+ $prevIndex 1))

          ($metrics (measureAllMetrics $newState $trajectory))

          ($timestamp (currentTime))
    )
     (CIPSnapshot $newIndex $newState $timestamp $metrics)
    )
)

