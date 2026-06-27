
; Description : a function to filter atoms that are below a the forgetThreshold
; params :
;	$atoms : List of atoms to be filtered
; return: List of atoms that are below threshold
; (: filterByLti (-> List Number List))
(= (filterByLti $atoms $forgetThreshold)
	(println! (entering-filterByLti))
		(if (== $atoms ())
			()
			(let*
				(
					($head (car-atom $atoms))
					($tail (cdr-atom $atoms))
				)
				(if (<= (getLti $head) $forgetThreshold)
					(if (== (getVlti $head) 0.0)
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
		(if (== (getLti $elem) (getLti $pivot))
			(< (getMean $elem) (getMean $pivot))
			(< (getLti $elem) (getLti $pivot))
		)
	)
)

; (: greaterThanLtiThenTV (-> Atom Atom Bool))
(= (greaterThanLtiThenTV $elem $pivot)
	(if (or (== $elem ()) (== $pivot ()))
		False
		(if (== (getLti $elem)(getLti $pivot))
			(>=(getMean $elem) (getMean $pivot))
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
	(if (and (<= (getLti $head) (forgetThreshold)) (< $count $removalAmount))
		(if (== (getVlti $head) 0.0)
			True
			False
		)
		False
	)
)

(= (refundAV $atom)
	let $xav((getAv $atom)
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
		(importanceBin (getSti $head))
		(let*
			(
				
				(() (refundAV $head))
				
				(() (extractAtomRecursive $niset))
				
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
				
				($iset (let $xiset (globalIncomingSetByType $head ASYMMETRIC_HEBBIAN_LINK) $xiset))
				
				($niset (let $xniset (globalIncomingSetwithoutType $head) $xniset))
				
				
				
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
			($maxSize (getAttentionParam MAX_SIZE))
			($accDivSize (getAttentionParam ACC_DIV_SIZE) $xacc)
			
			($forgetThreshold (getAttentionParam FORGET_THRESHOLD))
			($atoms (getAllAtomsWithBins))
			($size (countAtomsInTypeSpace))
			($removalAmount (- $size (- $maxSize $accDivSize)))
		
			($filteredatom (let $xfilte (filterByLti $atoms $forgetThreshold) $xfilte))
			
			($sortedatoms (ForgettingLtiThenTVAscendingSort $filteredatom))
			
		)
		(if (< $size (+ $maxSize $accDivSize))
			()
			(checkThenRemoveAtom $sortedatoms $removalAmount $count)
		)
	)
)