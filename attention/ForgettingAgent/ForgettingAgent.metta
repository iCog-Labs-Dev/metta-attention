; Description: a function to remove atoms that have low Lti values from the typeSpace
; params:
;		None
; return: None
; TODO: might need to convert the input from List of atoms to space
(= (forgettingAgent-Run $space)
	(let* 
		(
			($count 0)
            ($maxSize (getAttentionParam MAX_SIZE))
            ($accDivSize (getAttentionParam ACC_DIV_SIZE))
            ($forgetThreshold (getAttentionParam FORGET_THRESHOLD))
			($atoms (getAllAtomsWithBins))
			($size (countAtomsInTypeSpace)) 
			($removalAmount (- $size (- $maxSize $accDivSize)))
			($filteredatom (filterByLti $atoms $forgetThreshold))
			($sortedatoms (ForgettingLtiThenTVAscendingSort $filteredatom))
				
		)
		(if (< $size (+ $maxSize $accDivSize))
			()
			(checkThenRemoveAtom $sortedatoms $removalAmount $count)
		)
	)
)


; Description : a function to filter atoms that are below a the forgetThreshold
; params :
;	$atoms : List of atoms to be filtered
; return: List of atoms that are below threshold
(: filterByLti (-> List Number List))
(= (filterByLti $atoms $forgetThreshold)
	(if (== $atoms ())
		()
		(let*
			(
				($head (car-atom $atoms))
				($tail (cdr-atom $atoms))
			)
			(if (<= (getLti $head) $forgetThreshold)
				(if (== (getVlti $head) 0)
					(concatTuple ($head) (filterByLti $tail $forgetThreshold))
					(filterByLti $tail $forgetThreshold)
				)
				(filterByLti $tail $forgetThreshold)
			)
		)
	)
)

; Description: the function is responsible to sort a List of atmos based on thier Lti values
;			   if the Lti are small it will make the descion based on the TruthValue (STV.mean)
;			   and sort them in descending order.
; params:
;       $atoms: a List of unsorted atoms
; return: List of sorted atoms
(: ForgettingLtiThenTVAscendingSort (-> List List))
(= (ForgettingLtiThenTVAscendingSort $atoms)
	(if (== $atoms ())
		()
		(let*
			(
				($pivot (car-atom $atoms))
				($tail (cdr-atom $atoms))
				($lesser (binaryFilter lessThanLtiThenTV $pivot $tail))
				($greater (binaryFilter greaterThanLtiThenTV $pivot $tail))
                ($sortedLesser (ForgettingLtiThenTVAscendingSort $lesser))
                ($sortedGreater (ForgettingLtiThenTVAscendingSort $greater))
			)	
           (concatTuple $sortedLesser (cons-atom $pivot $sortedGreater))
		)
	)
)

; Description: takes two atoms and return false if either is empty,
;			    if pivot has larger lti, if lit equal return false if pivot has larger mean
; params:
; 		$elem: an atom to be compared
;		$pivot: an atom to be compared
; return: false if any of the condition in the descripton return false
(: lessThanLtiThenTV (-> Atom Atom Bool))
(= (lessThanLtiThenTV $elem $pivot)
    (if (or (== $elem ()) (== $pivot ()))
		False
		(if (== (getLti $elem) (getLti $pivot))
			(< (getMean $elem) (getMean $pivot))
			(< (getLti $elem) (getLti $pivot))
		)
	)
)

; Description: takes two atoms and returns false if either is empty, if pivot has lower lti,
;			   if lit equal return false if pivot has lower mean
; params:
; 		$elem: an atom to be compared
;		$pivot: an atom to be compared
; return: true if all conditions in descripton are fulfilled
(: greaterThanLtiThenTV (-> Atom Atom Bool))
(= (greaterThanLtiThenTV $elem $pivot)
	(if (or (== $elem ()) (== $pivot ()))
		False
		(if (== (getLti $elem) (getLti $pivot))
			(>= (getMean $elem) (getMean $pivot))
			(> (getLti $elem) (getLti $pivot))
		)
	)
)

; Description: a function responsible to recursivly check a List of sorted atoms
;			   and remove atoms that return true from atomBelowForgetThreshold and 
;			   its incoming set does not contatin and ASYMMETRIC_HEBBIAN_LINK
; params:
; 		 $$sortedatoms: a List of sorted atoms sorted in accordance with ForgettingLtiThenTVAscendingSort
;        $removalAmount: the amount of atoms to be removed
;		 $count: the amount of atoms that have been removed
; return: None
(: checkThenRemoveAtom (-> List Number Number empty))
(= (checkThenRemoveAtom $sortedatoms $removalAmount $count)
	(if (== $sortedatoms ())
		()
		(let*
			(
				($head (car-atom $sortedatoms))
				($tail (cdr-atom $sortedatoms))
				($iset (globalIncomingSetByType $head ASYMMETRIC_HEBBIAN_LINK))
				($niset (globalIncomingSetwithoutType $head))
			)
			(if (< $count $removalAmount) 
				(if (== (size-atom $iset) (size-atom $niset))
					(let*
						(
							($size (size-atom $niset))
							($newCount (+ (+ 1 $count ) $size))
						)
                        ( 
                            (globalRemoveAtom $head $niset)
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

; Description: a function to check if the an an atom has an Lti lower than treshold
;			   and we have not removed atoms above the calculated removal amount
; parmas:
; 		 $head: an atom to be checked
;        $removalAmount: the amount of atoms to be removed
;		 $count: the amount of atoms that have been removed
; return: True if atom can be removed else False
(: atomBelowForgetThreshold (-> Atom Number Number Bool))
(= (atomBelowForgetThreshold $head $removalAmount $count) 
	(if (and (<= (getLti $head) (forgetThreshold)) (< $count $removalAmount))
		(if (== (getVlti $head) 0 ) 
			True
			False
		)
		False
	)
)

; Description: a function to set Av to Zero and remove an atom and its incoming sets from all the spaces
; params:
; 	$head: an atom that needs to be removed
;	$nsiet: all incoming sets of the atom
; return: None
(: globalRemoveAtom (-> Atom List empty))
(= (globalRemoveAtom $head $niset) 
	(let $bin 
        (importanceBin (getSti $head))
		(
            (() (refundAV $head))
		)
		(
			(extractAtomRecursive $niset)
			(removeTypeSpace $head)
        )

	)
)

; Description: a function to recusivly remove atoms and links ther incoming sets
;			   it takes a list of incoming set of an atoms and moves it to a new space
; params:
;		$atoms: List of incoming atoms of an atom
; return: None
(: extractAtomRecursive (-> List empty))
(= (extractAtomRecursive $atoms)
	(if (== $atoms ())
		()
		(let*
			(
				($head (car-atom $atoms))
				($tail (cdr-atom $atoms))
        (() (refundAV $head)
			)
      (removeTypeSpace $head)
		)
	)
)

; Description: a function that sets atoms STI and Lti to zero prior to removal to insure its funds are returned
; params:
;   $atom: atom whose value is set to zero
; return: empty
(: refundAV (-> Atom empty))
(= (refundAV $atom)
    (if (== (getAv $atom) %Undefined%)
        ()
        (setAv $atom (0 0 0))
    )
)
