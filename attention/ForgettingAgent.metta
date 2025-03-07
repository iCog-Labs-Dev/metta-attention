!(bind! &removeSpace (new-space)) ; a new space to store removed atoms

(= (forgetThreshold) 5) ; constant set in line 57 opencog/attention/ForgettingAgent.cc
(= (maxSize) 2) ; constant set in line 63 opencog/attention/ForgettingAgent.cc
(= (accDivSize) 1) ;  constant set in line 64 opencog/attention/ForgettingAgent.cc

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

; Description: the function is responsible to sort a List of atmos based on thier LTI values
;			   if the LTI are small it will make the descion based on the TruthValue (STV.mean)
;			   and sort them in descending order.
; params:
;       $atoms: a List of unsorted atoms
; return: List of sorted atoms
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

; Description: the function takes a list of atoms and experessions 
;              and returns a new list wich contatins only symobls
; params:
;		$atoms: list of symbols and expressions
; return: list of symbols
(: removeLinksfromList (-> List List))
(= (removeLinksfromList $atoms)
	(if (== $atoms ())
		()
		(let* 
			(
				($head (car-atom $atoms))
				($tail (cdr-atom $atoms))
			)
			(if (== (get-metatype $head) Symbol)
				(concatTuple ($head) (removeLinksfromList $tail))	
				(removeLinksfromList $tail)
			)
		)
	)
)

; Description: a function the will be used to start the forgeting process and intialize a count
; params:
;		$atoms: a List of unsorted atoms
;       $removalAmount: the amount of atoms to be removed
; return: None
(= (forgetHelper $atoms $removalAmount) 
	(if (== $atoms ())
		()
		(let*
			(
				($count 0)
				($sortedatoms (ForgettingLTIThenTVAscendingSort $atoms))
			)
			(checkThenRemoveAtom $sortedatoms $removalAmount $count)
		
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
	(let* 
		(	
			($head (car-atom $sortedatoms))
			($tail (cdr-atom $sortedatoms))
			($isValid (atomBelowForgetThreshold $head $removalAmount $count))
			($iset (getIncomingSetByType $head ASYMMETRIC_HEBBIAN_LINK))
			($niset (getIncomingSetwithoutType $head))
		)
		(if $isValid
			(if (== (size-atom $iset) (size-atom $niset))
				(let*
					(
						($size (size-atom $niset))
						(() (add-atom &removeSpace $head))
						(() (globalRemoveAtom $head $niset))
						($newCount (+ (+ 1 $count ) $size))
					)
					(check_ThenRemoveAtom $tail $removalAmount $newCount)
				)
				(checkThenRemoveAtom $tail $removalAmount $count)
			)
			()
		)
	)

)

(= (globalRemoveAtom $head $niset) 
	(let*
		(
			(() (setAv $head (0.0 0.0 0.0)))
			(() (extractAtomRecursive $niset))
			(() (remove-atom (AttentionalFocus) $head))
			($bin (importanceBin (getSTI $head)))
			($val (removeAtomBin $head $bin))
			(() (remove-atom &self $head))
		)
		()
	)
)

(= (removeAtomBin $head $bin)
	(let*
		(
			($bins (match (AtomBin) ($bin $x) $x))
			($intersection (intersection-atom $bins ($head)))
		)
		(if (== $intersection ())
			()
			(removeAtom $bin $head)
		)
	)
)

; Description: a function to remove atoms that have low LTI values
; params:
;		 $atoms: List of atoms from a space
; return: None
; TODO: might need to convert the input from List of atoms to space
(= (forgetAtoms $atoms)
	(let* 
		(
			($parsedAtoms (removeLinksfromList $atoms))
			($size (size-atom $parsedAtoms)) 
			($removalAmount (- $size (- (maxSize) (accDivSize))))
		)
		(if (< $size (+ (maxSize) (accDivSize)))
			()
			(forgetHelper $parsedAtoms $removalAmount)
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
		(if (== (getVLTI $head) 0 ) ; Assumption that AttentionValue::DISPOSABLE resolves to 0 in attention implementation
			True
			False
		)
		False
	)
)

; Description: a function to recusivly remove atoms and links ther incoming sets
;			   it takes a list of incoming set of an atoms and moves it to a new space
; params:
;		$atoms: List of incoming atoms of an atom
: return: None
(: extractAtomRecursive (-> List empty))
(= (extractAtomRecursive $atoms)
	(if (== $atoms ())
		()
		(let* 
			(
				($head (car-atom $atoms))
				($tail (cdr-atom $atoms))
				(() (remove-atom (AttentionalFocus) $head))
				(() (add-atom &removeSpace $head))

			)
			(extractAtomRecursive $tail)
		)
	)
)

(= (incomingSetType $atom $type)
	(let* 
		(
			($selfiset (globalIncomingSetByType  $atom $type))
			($attiset (getIncomingSetByType $atom $type))
			($union (union-atom $selfiset $attiset))
		)
		(unique-atom $union)
	)
)

(= (getValueTypes $pattern) 
	(if (== (get-metatype $pattern) Expression)
		(let $a 
			(collapse 
				(let $x 
					(let $t
						(getType $pattern)
						(if (== $t %Undefined%)
							(empty)
							$t
						)
					)
					(collapse (superpose $x))
				)
			)
			(index-atom $a 0)
		) 
		(let $t (getType $pattern) (if (== $t %Undefined%) (empty) $t))
    )
)
