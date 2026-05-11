!(import! &self "../../../experiments/utils/community_detector.py")
!(import! &self "../../../experiments/utils/history_tracker.py")

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
        (if (> $denomenator 0)
            (/ $numenator $denomenator)
            0.0
        )
    )
)

(= (variance $stiValue) 
    (let*
        (
            ($size (size-atom $stiValue))
            ($sum (foldl-atom $stiValue 0 $acc $x (+ $acc $x)))
            ($mean (if (> $size 0) (/ $sum $size) 0.0))
            ($meanDiff (map-atom $stiValue $x (pow-math (- $x $mean) 2)))
            ($numenator (foldl-atom $meanDiff 0 $acc $x (+ $acc $x)))
        )
        (if (> $size 0)
            (/ $numenator $size)
            0.0
        )
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

(= (log2-math $x)
    (if (> $x 0.0)
        (log-math 2.0 $x)
        0.0
    )
)

(= (entropyTerm $p)
     (if (> $p 0)
       (* $p (log2-math $p))
       0.0
     )
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

(= (identifyModules $state $afLinks)
    (py-call (community_detector.get_dynamic_modules $state $afLinks))
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
            ($afAtoms (getAllAtomsWithBins))
            ($stival (map-atom $afAtoms getSti))
            ($ltival (map-atom $afAtoms getLti))
            ($totalSti (foldl-atom $stival 0 $acc $x (+ $acc $x)))
            ($totalLti (foldl-atom $ltival 0 $acc $x (+ $acc $x)))
            ($sizeSti (size-atom $stival))
            ($sizeLti (size-atom $ltival))
            ($meanSti (if (> $sizeSti 0) (/ $totalSti $sizeSti) 0.0))
            ($meanLti (if (> $sizeLti 0) (/ $totalLti $sizeLti) 0.0))
        )
        (if (and (> $sizeSti 0) (> $sizeLti 0))
            (pearsonCorrelation $afAtoms $meanSti $meanLti)
            0.0
        )
    )
)

(= (contextRetention $prevState $state)
    (let*
        (
            ($overlap (size-atom (intersection-atom $state $prevState)))
            ($unionSize (+ (size-atom $prevState) (- (size-atom $state) $overlap)))
        )
        (if (> $unionSize 0)
            (/ $overlap $unionSize)
            0.0
        )
    )
)

(= (selectionModulation)
    (let* 
        (
            ($afAtoms (getAllAtomsWithBins))
            ($stiValue (map-atom $afAtoms getSti))
            ($variance (variance $stiValue))
            ($maxVariance (variance-uniform $stiValue))
        )
        (if (> $maxVariance 0)
            (/ $variance $maxVariance)
            0.0
        )
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
            ($internalFlags (map-atom $allAfLinks $link (isInternalLink $link $afAtoms)))
            ($internalLinks (foldl-atom $internalFlags 0 $acc $x (+ $acc $x)))
        )
        (if (> $totalLinks 0)
            (/ $internalLinks $totalLinks)
            0.0
        )
    )
)


(= (preallocationSpace)
  (let* 
     (
        ($allAtoms (getAllAtomsWithBins))
        ($totalAtoms (size-atom $allAtoms))
        ($totalSti (getTotalSti $allAtoms 0))
        ($probabilities (if (> $totalSti 0)
            (map-atom $allAtoms $atom (/ (getSti $atom) $totalSti))
            ()
        ))
        ($entropyTerms (map-atom $probabilities $p (entropyTerm $p)))
        ($sumTerms (foldl-atom $entropyTerms 0 $acc $x (+ $acc $x)))
        ($entropy (* -1.0 $sumTerms))
        ($maxEntropy (if (> $totalAtoms 1) (log2-math $totalAtoms) 0.0))
      )

        (if (> $maxEntropy 0)
            (/ $entropy $maxEntropy)
            0.0
        )
    )
)

(= (cognitiveMaintenance $oldState $newState $oldMean $oldCount)
    (let*
        (
            ($retention (contextRetention $oldState $newState))
            ($newCount (+ $oldCount 1.0))
            ($weightOld (* $oldMean (/ $oldCount $newCount)))
            ($weightNew (/ $retention $newCount))
            ($newMean (+ $weightOld $weightNew))
        )
        $newMean
    )
)


(= (getStiSeries $atom)
    (py-call (history_tracker.get_sti_series $atom))
)

(= (filterLinksByFlag () ()) ())
(= (filterLinksByFlag (cons $link $ltail) (cons $flag $ftail))
    (if (== $flag 1)
        (cons $link (filterLinksByFlag $ltail $ftail))
        (filterLinksByFlag $ltail $ftail)
    )
)

(= (isSameModule $src $tgt $module)
    (let* (
        ($hasSrc (size-atom (intersection-atom $module (cons $src ()))))
        ($hasTgt (size-atom (intersection-atom $module (cons $tgt ()))))
    )
    (if (and (> $hasSrc 0) (> $hasTgt 0)) 1 0)
    )
)

(= (getLinkSource (ASYMMETRIC_HEBBIAN_LINK $src $tgt)) $src)

(= (isExternalLink $link $modules)
    (let* (
        ($src (getLinkSource $link))
        ($tgt (getLinkTarget $link))
        ($internalCount (foldl-atom (map-atom $modules $mod (isSameModule $src $tgt $mod)) 0 $acc $x (+ $acc $x)))
    )
    (if (== $internalCount 0) 1 0) 
    )
)

(= (zipMultiply () ()) ())
(= (zipMultiply (cons $h1 $t1) (cons $h2 $t2))
   (cons (* $h1 $h2) (zipMultiply $t1 $t2))
)

(= (pearsonCorrelationLists $listX $listY)
    (let* (
        ($sizeX (size-atom $listX))
        ($sizeY (size-atom $listY))
    )
    (if (or (== $sizeX 0) (== $sizeY 0)) 
        0.0
        (let* (
            ($meanX (averageList $listX))
            ($meanY (averageList $listY))
            
            ($diffX (map-atom $listX $x (- $x $meanX)))
            ($diffY (map-atom $listY $y (- $y $meanY)))
            
            ($covarTerms (zipMultiply $diffX $diffY))
            ($covar (foldl-atom $covarTerms 0.0 $a $b (+ $a $b)))

            ($varXTerms (map-atom $diffX $dx (* $dx $dx)))
            ($varYTerms (map-atom $diffY $dy (* $dy $dy)))
            ($varX (foldl-atom $varXTerms 0.0 $a $b (+ $a $b)))
            ($varY (foldl-atom $varYTerms 0.0 $a $b (+ $a $b)))
            ($varProd (* $varX $varY))
            ($denominator (if (> $varProd 0) (sqrt-math $varProd) 0.0))
        )
        (if (> $denominator 0) (/ $covar $denominator) 0.0)
        )
    ))
)

;(= (temporalConjunction $atomI $atomJ)
;    (let* 
;        (
;            ($stiI (getStiSeries $atomI))
;            ($stiJ (getStiSeries $atomJ))
;            ($multiplied (zipMultiply $stiI $stiJ))
;         )
;         (averageList $multiplied)
;    )
;)

(= (temporalConjunction $atomI $atomJ)
    (py-call (history_tracker.temporal_conjunction $atomI $atomJ))
)

(= (temporalConjunctionLink $link) 
    (temporalConjunction (getLinkSource $link) (getLinkTarget $link))
)

(= (getProbability $link)
    (let $meanSet (collapse (getMean $link))
        (if (== $meanSet ())
            0.5               
            (car-atom $meanSet) 
        )
    )
)

(= (moduleInternalCoherence $moduleAtoms)
    (let*
      (
        ($allLinks (getHebLinks $moduleAtoms ()))
        ($internalFlags (map-atom $allLinks $link (isInternalLink $link $moduleAtoms)))
        ($internalLinks (filterLinksByFlag $allLinks $internalFlags))

        ($linksProbs (map-atom $internalLinks getProbability))
        ($conjunctions (map-atom $internalLinks temporalConjunctionLink))
      )
      (pearsonCorrelationLists $linksProbs $conjunctions)
    )

)

(= (globalCoordination $state)
    (let*
        (
            ($afLinks (getHebLinks $state ()))
            ($modules (identifyModules $state $afLinks))

            ($localCoherences (map-atom $modules $mod (moduleInternalCoherence $mod)))
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