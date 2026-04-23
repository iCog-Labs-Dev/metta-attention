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
