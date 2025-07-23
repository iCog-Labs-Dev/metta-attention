!(bind! &removeSpace (new-space)) ; a new space to store removed atoms

(: RemoveSpace (-> Grounding::space))
(= (RemoveSpace)
	&removeSpace
)

(= (forgetThreshold) 5) ; constant set in line 57 opencog/attention/ForgettingAgent.cc
(= (maxSize) 2) ; constant set in line 63 opencog/attention/ForgettingAgent.cc
(= (accDivSize) 1) ;  constant set in line 64 opencog/attention/ForgettingAgent.cc

; Description: a function to remove atoms that have low LTI values from the typeSpace
; params:
;		None
; return: None
; TODO: might need to convert the input from List of atoms to space
(= (forgettingAgent-Run $space)
	(let* 
		(
			($count 0)
			($atoms (collapseBin $space))
			($size (countAtomsInTypeSpace)) 
			($removalAmount (- $size (- (maxSize) (accDivSize))))
			($filteredatom (filterByLti $atoms))
			($sortedatoms (ForgettingLTIThenTVAscendingSort $filteredatom))
				
		)
		(if (< $size (+ (maxSize) (accDivSize)))
			()
			(checkThenRemoveAtom $sortedatoms $removalAmount $count)
		)
	)
)

(= (collapseBin $space)
	(collapse (let $a (match $space ($x $y) $y) (superpose $a)))
)

; Description : a function to filter atoms that are below a the forgetThreshold
; params :
;	$atoms : List of atoms to be filtered
; return: List of atoms that are below threshold
(: filterByLti (-> List List))
(= (filterByLti $atoms)
	(if (== $atoms ())
		()
		(let*
			(
				($head (car-atom $atoms))
				($tail (cdr-atom $atoms))
			)
			(if (or (< (getLti $head) (forgetThreshold)) (== (getLti $head) (forgetThreshold)))
				(if (== (getVlti $head) 0)
					(concatTuple ($head) (filterByLti $tail))
					(filterByLti $tail)
				)
				(filterByLti $tail)
			)
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
			(or (> (getMean $elem) (getMean $pivot)) (== (getMean $elem) (getMean $pivot)))
			(> (getLti $elem) (getLti $pivot))
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
				($iset (incomingSetType $head ASYMMETRIC_HEBBIAN_LINK))
				($niset (incomingSetUntyped $head))
			)
			(if (< $count $removalAmount) 
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
	(if (and (or (< (getLti $head) (forgetThreshold)) (== (getLti $head) (forgetThreshold))) (< $count $removalAmount))
		(if (== (getVlti $head) 0 ) 
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
            (() (refundAV $head))
			(() (add-atom &removeSpace (: $head ((STV 0.0 0.0) (AV 0.0 0.0 0.0)))))
            (() (removeNewAtomAV $head))
			(() (extractAtomRecursive $niset))
			(() (removeAtomAttentionalfocus $head))
			($bin (importanceBin (getSti $head)))
			($a (removeAtom $bin $head))
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
                (() (refundAV $head))
				(() (add-atom &removeSpace (: $head ((STV 0.0 0.0) (AV 0.0 0.0 0.0)))))
				($bin (importanceBin (getSti $head)))
				($a (removeAtom $bin $head))
				(() (removeAtomAttentionalfocus $head))
				(() (removeTypeSpace $head))
                (() (removeNewAtomAV $head))
			)
			(extractAtomRecursive $tail)
		)
	)
)

; Description: a function that sets atoms STI and LTI to zero prior to removal to insure its funds are returned
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
; Description: a wrapper for getRemoveValueType-helper it collapses the result and retunrs undefined or value type
; params:
;	$pattern: an atom whose attention and truth value to be searched
; return: and expresion fo the AV, STV or both values or undefined
(: getRemoveValueType (-> Atom Type))
(= (getRemoveValueType $pattern) 
	(let $a 
		(collapse (getRemoveValueType-helper $pattern))
		(if (== $a ())
			%Undefined%
			(car-atom $a)
		)
	)
)

; Description: get the value of an atom's AV or STV mainly used to remove non-determinism from get-type
; params:
;	$pattern: an atom whose attention and truth value to be searched
; return: an expression for the AV, STV, both values or empty
(: getRemoveValueType-helper (-> Atom Type))
(= (getRemoveValueType-helper $pattern) 
	(let $a 
		(get-type-space &removeSpace $pattern) 
		(unify $a  
			(AV $sti $lti $vlti) 
			(AV $sti $lti $vlti)
			(unify $a
				(STV $mean $conf)
				(STV $mean $conf)
				(unify $a
					((STV $mean $conf) (AV $sti $lti $vlti))
					((STV $mean $conf) (AV $sti $lti $vlti))
					(empty)
				)
			)
		)
	)
)

; Description: get the AV value of a specific atom
; params: 
;	$pattern: an atom whose attention value to be returned
; return: AV value of the atom
(= (getRemoveAV $pattern)
	(let $type (getRemoveValueType $pattern)
		(if (== $type $Undefined$)
			%Undefined%
			(unify $type
				(AV $sti $lit $vlti)
				(AV $sti $lit $vlti)
				(unify $type
					((STV $mean $conf) (AV $sti $lit $vlti))
					(AV $sti $lit $vlti)
					%Undefined%
				)	
			)	

		)
	)
)

; Description: retrive the LTI value of an atom in the removeSpace
; params:
; 	$pattern: atom whos LTI is to be retrieved
; return: Number value of describing the LTI
(: getRemoveLTI ( -> Atom Number))
(= (getRemoveLTI $pattern)
	(let (AV $sti $lti $vlti) (getRemoveAV $pattern) $lti)
)


; Description: retrive the STI value of an atom in the removeSpace
; params:
; 	$pattern: atom whos STI is to be retrieved
; return: Number value of describing the STI
(= (getRemoveSTI $pattern)
	(let (AV $sti $lti $vlti) (getRemoveAV $pattern) $lti)
)

; Description: returns a list of atoms patterns by extracitng the STV and AV values from original atoms
; params:
;	None
; return: list of atoms patterns
(: getAtomsInRemoveSpace-helper (-> List))
(= (getAtomsInRemoveSpace-helper) 
	(let $a 
		(get-atoms &removeSpace)
		(unify $a
			(: $pattern $x)
			$pattern
			(empty)
		)
	)
)

; Description : getAtomsInRemoveSpace is a function that returns a list of patterns in typespace
; params:
;	None
; return: List of patterns in the removeSpace without thier types in and is more deterministic than matching
(: getAtomsInRemoveSpace (-> List))
(= (getAtomsInRemoveSpace) 
	(collapse (getAtomsInRemoveSpace-helper))
)
