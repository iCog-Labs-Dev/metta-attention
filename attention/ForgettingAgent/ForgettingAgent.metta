
; Description : a function to filter atoms that are below a the forgetThreshold
; params :
;	$atoms : List of atoms to be filtered
; return: List of atoms that are below threshold
; (: filterByLti (-> List Number List))
(= (filterByLti $atoms $forgetThreshold)
	(let $xdbgf (println! (entering-filterByLti))
		(if (== $atoms ())
			()
			(let*
				(
					($head (car-atom $atoms))
					($tail (cdr-atom $atoms))
				)
				(if (<= (let $xlti (getLti $head) $xlti) $forgetThreshold)
					(if (== (let $xvlti (getVlti $head) $xvlti) 0.0)
						(concatTuple ($head) (filterByLti $tail $forgetThreshold))
						(filterByLti $tail $forgetThreshold)
					)
					(filterByLti $tail $forgetThreshold)
				)
			)
		)
	)
)

; (: lessThanLtiThenTV (-> Atom Atom Bool))
(= (lessThanLtiThenTV $elem $pivot)
	(if (or (== $elem ()) (== $pivot ()))
		False
		(if (== (let $xless (getLti $elem) $xless) (let $xpiv (getLti $pivot) $xpiv))
			(< (let $xmean (getMean $elem) $xmean) (let $xgpiv (getMean $pivot) $xgpiv))
			(< (let $xel (getLti $elem) $xel) (let $xelp (getLti $pivot) $xelp))
		)
	)
)

; (: greaterThanLtiThenTV (-> Atom Atom Bool))
(= (greaterThanLtiThenTV $elem $pivot)
	(if (or (== $elem ()) (== $pivot ()))
		False
		(if (== (let $xgetltii (getLti $elem) $xgetltii) (let $xgetltipiv (getLti $pivot) $xgetltipiv))
			(>= (let $xelem (getMean $elem) $xelem) (let $xgetmm (getMean $pivot) $xgetmm))
			(> (let $xp (getLti $elem) $xp) (let $xb (getLti $pivot) $xb))
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
				(() (refundAV $head))
				(() (removeTypeSpace $head))
			)
			(extractAtomRecursive $tail)
		)
	)
)

; (: globalRemoveAtom (-> Atom List empty))
(= (globalRemoveAtom $head $niset)
	(let $bin
		(importanceBin (let $xgets (getSti $head) $xgets))
		(let*
			(
				($dbg1 (println! (before-refundAV $head)))
				(() (refundAV $head))
				($dbg2 (println! (after-refundAV)))
				(() (extractAtomRecursive $niset))
				($dbg3 (println! (after-extractAtomRecursive)))
			)
			(removeTypeSpace $head)
		)
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
				; ($1 (println! (checking $head $count $removalAmount (size-atom $iset) (size-atom $niset))))
				; ($iset (globalIncomingSetByType $head ASYMMETRIC_HEBBIAN_LINK))
				($iset (let $xiset (globalIncomingSetByType $head ASYMMETRIC_HEBBIAN_LINK) $xiset))
				; ($1 (println! (checking $head $count $removalAmount (size-atom $iset) (size-atom $niset))))
				; ($niset (globalIncomingSetwithoutType $head))
				($niset (let $xniset (globalIncomingSetwithoutType $head) $xniset))
				($1 (println! (checking $head $count $removalAmount (size-atom $iset) (size-atom $niset))))
				($filteredNiset (filterByLti $niset $forgetThreshold))
				; ($1 (println! (checking $head $count $removalAmount (size-atom $iset) (size-atom $niset))))
				
			)
			(if (< $count $removalAmount)
				(if (== (size-atom $iset) (size-atom $niset))
					(let*
						(
							($size (size-atom $filteredNiset))
							($newCount (+ 1 $count))
						)
						(let*
							(
								(() (globalRemoveAtom $head $filteredNiset))
								($dbg (println! (removed $head newCount $newCount)))
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
			; ($1 (println! (test $count $maxSize $accDivSize $size)))
			($forgetThreshold (let $xthresh (getAttentionParam FORGET_THRESHOLD) $xthresh))
			($atoms (getAllAtomsWithBins))
			($size (let $xsize (countAtomsInTypeSpace) (+ $xsize 0.0)))
			; ($1 (println! (test $count $maxSize $accDivSize $size)))
			($removalAmount (- $size (- $maxSize $accDivSize)))
			; ($1 (println! (test $count $maxSize $accDivSize $size)))
			($filteredatom (let $xfilte (filterByLti $atoms $forgetThreshold) $xfilte))
			; ($1 (println! (test $count $maxSize $accDivSize $size)))
			($sortedatoms (ForgettingLtiThenTVAscendingSort $filteredatom))
			; ($1 (println! (test $count $maxSize $accDivSize $size)))
		)
		(if (< $size (+ $maxSize $accDivSize))
			()
			(checkThenRemoveAtom $sortedatoms $removalAmount $count)
		)
	)
)