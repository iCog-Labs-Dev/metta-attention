!(import! &self "../../experiments/utils/community_detector.py")
!(bind! &stiSeries (new-space))


; ## Time Series

(= (generate-zeros $count)
     (if (<= $count 0)
          ()
          (cons-atom 0.0 (generate-zeros (- $count 1)))
     )
)

(= (padExistingHistory $list $count)
    (if (<= $count 0)
        $list
        (cons-atom 0.0 (padExistingHistory $list (- $count 1)))
    )
)

(= (updateAtomHistory $atom $newSti $currentSnapshot)
    (let $oldHist (collapse (match &stiSeries ($atom $hist) $hist))
        (if (== $oldHist ())
            (let $paddedHistory (cons-atom $newSti (generate-zeros (- $currentSnapshot 1)))
               (add-atom &stiSeries ($atom $paddedHistory))
            )
            (let* (
                    ($historyTuple (car-atom $oldHist))
                    ($oldSize (size-atom $historyTuple))
                    ($missingZeros (- (- $currentSnapshot 1) $oldSize))
                    ($paddedOldHistory (padExistingHistory $historyTuple $missingZeros))
                    ($newHistory (cons-atom $newSti $paddedOldHistory))
                )
                (let $rem_atom (remove-atom &stiSeries ($atom $historyTuple))
                    (add-atom &stiSeries ($atom $newHistory))
                )
            )
        )
    )
)

; this function should be alligned with abel implementation
(= (get-sti-series $atom)
    (let $res (collapse (match &stiSeries ($atom $hist) $hist))
        (if (== $res ())
            (0.0)
            (car-atom $res)
        )
    )
)

(= (recordCipSeries)
    (let* 
        (
            ($indexMatch (collapse (match &cipspace (maxIndex $i) $i))) ;; not using get-lattest-cip-index to prevent circular dependency with ratio
            ($safeIndex (if (== $indexMatch ()) 0 (car-atom $indexMatch)))
            ($currentSnapShot (+ $safeIndex 1))
        )
        (map-atom 
            (getAllAtomsWithBins) 
            $atom 
            (updateAtomHistory $atom (getSti $atom) $currentSnapShot)
        )
    )
)

; helps to get the total sti for a collection of atoms
(= (getTotalSti () $out) $out)
(= (getTotalSti (cons $head $tail) $out)
    (getTotalSti $tail (+ $out (getSti $head)))
)

; helps to get the hebbian link for a collection/list of atom
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
  (if (> (size-atom $size) 0)
    (let*
        (
            ($max (max-atom $size))
            ($min (min-atom $size))
        )

        (/ (pow-math (- $max $min) 2) 12)
    )
        0.0
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

; helps to measure the linear relation between two continues value
; helps to know if two value have posetive or negative relation
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


(= (temporalConjunction $atomI $atomJ)
    (let* (
        ($stiI (get-sti-series $atomI))
        ($stiJ (get-sti-series $atomJ))
        ($multiplied (zipMultiply $stiI $stiJ))
    )
    (if (== $multiplied ())
        0.0
        (averageList $multiplied)
    )
    )
)

(= (temporalConjunctionLink $link)
    (temporalConjunction (getLinkSource $link) (getLinkTarget $link))
)


; this measures internal coherence for list of atoms
(= (measureCoherence $atoms)
    (let*
      (
        ($allLinks (getHebLinks $atoms ()))
        ($internalFlags (map-atom $allLinks $link (isInternalLink $link $atoms)))
        ($internalLinks (filterLinksByFlag $allLinks $internalFlags))

        ($linksProbs (map-atom $internalLinks getProbability))
        ($conjunctions (map-atom $internalLinks temporalConjunctionLink))
      )
      (pearsonCorrelationLists $linksProbs $conjunctions)
    )

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
        ($hasSrc (size-atom (intersection-atom $module ($src))))
        ($hasTgt (size-atom (intersection-atom $module ($tgt))))
    )
    (if (and (> $hasSrc 0) (> $hasTgt 0)) 1 0)
    )
)

(= (getLinkSource (ASYMMETRIC_HEBBIAN_LINK $src $tgt)) $src)
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
(= (isExternalLink $link $modules)
    (let* (
        ($src (getLinkSource $link))
        ($tgt (getLinkTarget $link))
        ($internalCount (foldl-atom (map-atom $modules $mod (isSameModule $src $tgt $mod)) 0 $acc $x (+ $acc $x))) ; TODO a function that takes an atom and retun its module can simplify this
    )
    (if (== $internalCount 0) 1 0)
    )
)



(= (zipMultiply $list1 $list2)
    (if (or (== $list1 ()) (== $list2 ()))
        ()
        (let* (
            ($h1 (car-atom $list1))
            ($t1 (cdr-atom $list1))
            ($h2 (car-atom $list2))
            ($t2 (cdr-atom $list2))
        )
        (cons-atom (* $h1 $h2) (zipMultiply $t1 $t2))
        )
    )
)

(= (getProbability $link)
    (getMean $link)
)


(= (pearsonCorrelationLists $listX $listY)
    (let* 
        (
            ($sizeX (size-atom $listX))
            ($sizeY (size-atom $listY))
        )
        (if (or (== $sizeX 0) (== $sizeY 0))
            0.0
            (let* 
                (
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
        )
    )
)

(= (stiProbablity $atomSti $allSti)
    (let*
        (
            ($stiCount (car-atom (intersection-atom $allSti $atomSti)))
            ($ratio (/ $stiCount (size-atom $allSti)))
        )
        $ratio
    )
)

(= (shanon-entropy $stiDistribution)
    (let*
        (
            ($probabilities
                (map-atom $stiDistribution $atom (stiProbablity ($atom) $stiDistribution))
            )
            ($entropyTerms (map-atom $probabilities $p (entropyTerm $p)))
            ($sumTerms (foldl-atom $entropyTerms 0 $acc $x (+ $acc $x)))
        )
        (* -1.0 $sumTerms)
    )
)
