
; Description : a function to filter atoms that are below a the forgetThreshold
; params :
;	$atoms : List of atoms to be filtered
; return: List of atoms that are below threshold
; (: filterByLti (-> List Number List))
(= (filterByLti $atoms $forgetThreshold)
		(if (== $atoms ())
			()
			(let*
				(
					($head (car-atom $atoms))
					($tail (cdr-atom $atoms))
                    ($1 (println! (h $head $tail)))
				)
				(if (<= (getLti $head) $forgetThreshold)
					(if (== (getVlti $head) 0.0)
						(cons-atom $head (filterByLti $tail $forgetThreshold))
						(filterByLti $tail $forgetThreshold)
					)
					(filterByLti $tail $forgetThreshold)
				)
			)
		)
	; )
)

; (: lessThanLtiThenTV (-> Atom Atom Bool))
(= (lessThanLtiThenTV $elem $pivot $x)
	(if (or (== $elem ()) (== $pivot ()))
		False
		(if (== (getLti $elem) (getLti $pivot))
			(< (getMean $elem) (getMean $pivot))
			(< (getLti $elem) (getLti $pivot))
		)
	)
)

; (: greaterThanLtiThenTV (-> Atom Atom Bool))
(= (greaterThanLtiThenTV $elem $pivot $x)
	(if (or (== $elem ()) (== $pivot ()))
		False
		(if (== (getLti $elem) (getLti $pivot))
			(>= (getMean $elem) (getMean $pivot))
			(> (getLti $elem) (getLti $pivot))
		)
	)
)

; (: ForgettingLtiThenTVAscendingSort (-> List List))
(= (ForgettingLtiThenTVAscendingSort $atoms)
	(if (== $atoms ())
		()
		(let*
			(
				($pivot (car-atom $atoms))
				($tail (cdr-atom $atoms))
				; ($lesser (binaryFilter lessThanLtiThenTV $pivot $tail))
				; ($greater (binaryFilter greaterThanLtiThenTV $pivot $tail))
				($lesser (binaryFilter lessThanLtiThenTV $pivot $tail ()))
                ($greater (binaryFilter greaterThanLtiThenTV $pivot $tail ()))
				($sortedLesser (ForgettingLtiThenTVAscendingSort $lesser))
				($sortedGreater (ForgettingLtiThenTVAscendingSort $greater))
			)
			(concatTuple $sortedLesser (cons-atom $pivot $sortedGreater))
		)
	)
)

; (: atomBelowForgetThreshold (-> Atom Number Number Bool))
(= (atomBelowForgetThreshold $head $removalAmount $count)
	(if (and (<= (let $xgetlti (getLti $head) $xgetlti) (forgetThreshold)) (< $count $removalAmount))
		(if (== (getVlti $head) 0.0)
			True
			False
		)
		False
	)
)

(= (refundAV $atom)
	(let $xav (getAv $atom)
		(if (== $xav %Undefined%)
			()
			(setAv $atom (0.0 0.0 0.0))
		)
	)
)

; (: extractAtomRecursive (-> List empty))
(= (extractAtomRecursive $atoms)
	(if (== $atoms ())
		()
		(let*
			(
				($head (car-atom $atoms))
				($tail (cdr-atom $atoms))
				($rfnd (refundAV $head))
				($rmts (removeTypeSpace $head))
			)
			(extractAtomRecursive $tail)
		)
	)
)

; (: globalRemoveAtom (-> Atom List empty))
(= (globalRemoveAtom $head $niset)
    (let*
        (
            ($rfnd (refundAV $head))
            ($extr (extractAtomRecursive $niset))
        )
        (removeTypeSpace $head)
    )
)

; (: checkThenRemoveAtom (-> List Number Number empty))
(= (checkThenRemoveAtom $sortedatoms $removalAmount $count)
	(if (== $sortedatoms ())
		()
		(let*
			(
				($forgetThreshold (getAttentionParam FORGET_THRESHOLD))
				
				($head (car-atom $sortedatoms))
				
				($tail (cdr-atom $sortedatoms))
				($iset (globalIncomingSetByType $head ASYMMETRIC_HEBBIAN_LINK))
				; ($iset (let $xiset (globalIncomingSetByType $head ASYMMETRIC_HEBBIAN_LINK) $xiset))
				($niset (globalIncomingSetwithoutType $head))
				; ($niset (let $xniset (globalIncomingSetwithoutType $head) $xniset))
				; ($filteredNiset (filterByLti $niset $forgetThreshold))
				
			)
			(if (< $count $removalAmount)
				(if (== (size-atom $iset) (size-atom $niset))
					(let*
						(
							($size (size-atom $niset))
							($newCount (+ (+ 1 $count) $size))
						)
						(let*
							(
								($rmvd (globalRemoveAtom $head $niset))
							)
							(checkThenRemoveAtom $tail $removalAmount $newCount)
						)
					)
					(checkThenRemoveAtom $tail $removalAmount $count)
				)
				()
			)
		)
	)
)

(= (forgettingAgent-Run $space)
	(let*
		(
			($count 0.0)
			($maxSize (let $xmax (getAttentionParam MAX_SIZE) $xmax))
			($accDivSize (let $xacc (getAttentionParam ACC_DIV_SIZE) $xacc))
			($forgetThreshold (let $xthresh (getAttentionParam FORGET_THRESHOLD) $xthresh))
			($atoms (getAllAtomsWithBins))
			($size (let $xsize (countAtomsInTypeSpace) (+ $xsize 0.0)))
			($removalAmount (- $size (- $maxSize $accDivSize)))
			($filteredatom (let $xfilte (filterByLti $atoms $forgetThreshold) $xfilte))
            ($1 (println! (atoms firlterd $filteredatom)))
			($sortedatoms (ForgettingLtiThenTVAscendingSort $filteredatom))
		)
		(if (< $size (+ $maxSize $accDivSize))
			()
			(checkThenRemoveAtom $sortedatoms $removalAmount $count)
		)
	)
)
