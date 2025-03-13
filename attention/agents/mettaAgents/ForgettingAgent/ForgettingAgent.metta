!(bind! &removeSpace (new-space)) ; a new space to store removed atoms

(= (forgetThreshold) 5) ; constant set in line 57 opencog/attention/ForgettingAgent.cc
(= (maxSize) 2) ; constant set in line 63 opencog/attention/ForgettingAgent.cc
(= (accDivSize) 1) ;  constant set in line 64 opencog/attention/ForgettingAgent.cc

; Description: a function to remove atoms that have low LTI values from the typeSpace
; params:
;		None
; return: None
; TODO: might need to convert the input from List of atoms to space
(= (forgettingAgent-Run)
	(let* 
		(
			($atoms (getAtomsInTypeSpace))
			($count 0)
			($size (size-atom $atoms)) 
			($removalAmount (- $size (- (maxSize) (accDivSize))))
			($sortedatoms (ForgettingLTIThenTVAscendingSort $atoms))
				
		)
		(if (< $size (+ (maxSize) (accDivSize)))
			()
			(checkThenRemoveAtom $sortedatoms $removalAmount $count)
		)
	)
)

; Description: the function is responsible to sort a List of atmos based on thier LTI values
;			   if the LTI are small it will make the descion based on the TruthValue (STV.mean)
;			   and sort them in descending order.
; params:
;       $atoms: a List of unsorted atoms
; return: List of sorted atoms
(: ForgettingLTIThenTVAscendingSort (-> List List))
(= (ForgettingLTIThenTVAscendingSort $atoms)
	(if (== $atoms ())
		()
		(let*
			(
				($pivot (car-atom $atoms))
				($tail (cdr-atom $atoms))
				($lesser (binaryFilter lessThanLtiThenTV $pivot $tail))
				($greater (binaryFilter greaterThanLtiThenTV $pivot $tail))
                ($sortedLesser (ForgettingLTIThenTVAscendingSort $lesser))
                ($sortedGreater (ForgettingLTIThenTVAscendingSort $greater))
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
		(if (== (getLTI $elem) (getLTI $pivot))
			(< (getMean $elem) (getMean $pivot))
			(< (getLTI $elem) (getLTI $pivot))
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
		(if (== (getLTI $elem) (getLTI $pivot))
			(>= (getMean $elem) (getMean $pivot))
			(> (getLTI $elem) (getLTI $pivot))
		)
	)
)

; Description: a function responsible to recursivly check a List of sorted atoms
;			   and remove atoms that return true from atomBelowForgetThreshold and 
;			   its incoming set does not contatin and ASYMMETRIC_HEBBIAN_LINK
; params:
; 		 $$sortedatoms: a List of sorted atoms sorted in accordance with ForgettingLTIThenTVAscendingSort
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
				($isValid (atomBelowForgetThreshold $head $removalAmount $count))
				($iset (incomingSetType $head ASYMMETRIC_HEBBIAN_LINK))
				($niset (incomingSetUntyped $head))
			)
			(if $isValid
				(if (== (size-atom $iset) (size-atom $niset))
					(let*
						(
							($size (size-atom $niset))
							(() (globalRemoveAtom $head $niset))
							($newCount (+ (+ 1 $count ) $size))
						)
						(checkThenRemoveAtom $tail $removalAmount $newCount)
					)
					(checkThenRemoveAtom $tail $removalAmount $count)
				)
				()
			)
		)
	)
)

; Description: a function to check if the an an atom has an LTI lower than treshold
;			   and we have not removed atoms above the calculated removal amount
; parmas: 
; 		 $head: an atom to be checked
;        $removalAmount: the amount of atoms to be removed
;		 $count: the amount of atoms that have been removed
; return: True if atom can be removed else False
(: atomBelowForgetThreshold (-> Atom Number Number Bool))
(= (atomBelowForgetThreshold $head $removalAmount $count) 
	(if (and (<= (getLTI $head) (forgetThreshold)) (< $count $removalAmount))
		(if (== (getVLTI $head) 0 ) 
			True
			False
		)
		False
	)
)

: Description: a function to find incoming set from both attentioanl focus and typeSpace.
; params:
;		$atom: atom whose incoming set is to be searched
;		$type: type of the link of the returned incoming set
; return: all set of incoiming sets with matching types
(: incomingSetType (-> Atom Atom List))
(= (incomingSetType $atom $type)
	(let* 
		(
			($selfiset (globalIncomingSetByType $atom $type))
			($attiset (getIncomingSetByType $atom $type))
			($union (union-atom $selfiset $attiset))
		)
		(unique-atom $union)
	)
)

: Description: a function to find incoming set from both attentioanl focus and self typeSpace.
; params:
;		$atom: atom whose incoming set is to be searched
; return: all set of incoiming sets not specifc of types
(: incomingSetType (-> Atom Atom List))
(= (incomingSetUntyped $atom)
	(let* 
		(
			($selfiset (globalIncomingSetwithoutType $atom))
			($attiset (getIncomingSetwithoutType $atom))
			($union (union-atom $selfiset $attiset))
		)
		(unique-atom $union)
	)
)

; Description: a function to set Av to Zero and remove an atom and its incoming sets from all the spaces
; params:
; 	$head: an atom that needs to be removed
;	$nsiet: all incoming sets of the atom
; return: None
(: globalRemoveAtom (-> Atom List empty))
(= (globalRemoveAtom $head $niset) 
	(let*
		(
			(() (setAv $head (0.0 0.0 0.0)))
			(() (add-atom &removeSpace $head))
			(() (extractAtomRecursive $niset))
			(() (removeAtomAttentionalfocus $head))
			($bin (importanceBin (getSTI $head)))
			($_ (removeAtom $bin $head))
			(() (removeTypeSpace $head))

		)
		()
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
				(() (add-atom &removeSpace $head))
				($bin (importanceBin (getSTI $head)))
				($_ (removeAtom $bin $head))
				(() (removeAtomAttentionalfocus $head))
				(() (removeTypeSpace $head))
			)
			(extractAtomRecursive $tail)
		)
	)
)
