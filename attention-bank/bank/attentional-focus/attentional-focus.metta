!(bind! &attentionalFocus (new-space))
!(bind! &newAtomInAV (new-space))
(= (AttentionalFocus) &attentionalFocus)
(= (newAtomInAV) &newAtomInAV)

(= (maxAFSize) 6)

;Function: atomIsInAF
;Description: Checks if a given atom is in the attentional focus space.
;Parameters:
;         $atom: The atom to check.
;Returns: True if the atom is in attentional focus space, otherwise False.

(: atomIsInAF (-> Atom Bool))
(= (atomIsInAF $atom)
   (if  (== (collapse (match &attentionalFocus $atom $atom)) ())
        False
        True
    )
)

;Function: atomIsNotInAF
;Description: Checks if a given atom is NOT in the attentional focus.
;Parameters:
;          $atom: The atom to check.
;Returns: True if the atom is not in attentional focus, otherwise False.

(: atomIsNotInAF (-> Atom Bool))
(= (atomIsNotInAF $atom)
   (not (atomIsInAF $atom))
)


;Function: addAtomToAF
;Description:
;           if the atom has neither AV nor STV,it returns an error message
;           if an atom is valid,it will add it to the attentional focus space. 
;Parameters:
;          $atom: The atom to add.
;Returns: A message indicating success or failure.
(: addAtomToAF (-> Atom Symbol))
(= (addAtomToAF $atom)
   (if (== (getValueType $atom) %Undefined%)
       ("Atom is not valid")
       (let* 
            (
                (() (add-atom &attentionalFocus $atom))
                (() (add-atom &newAtomInAV $atom))
            )
            ("Atom Added")
        )
   )
)

;Function: getAtomList
;Description: Retrieves a list of all atoms currently in attentional focus space.
;Parameters: None.
;Returns: A list of atoms in attentional focus space.
(: getAtomList(-> Symbol))
(= (getAtomList)
   (collapse (get-atoms &attentionalFocus))
)

;Function: getNewAtomInAVList
;Description: Retrieves a list of all atoms currently in the newAtomInAV space.
;Parameters: None.
;Returns: A list of atoms in newAtomInAV space.
(: getNewAtomInAVList(-> Symbol))
(= (getNewAtomInAVList)
   (collapse (get-atoms &newAtomInAV))
)

;Function: attentionalFocusSize
;Description: Returns the total number of atoms in the attentional focus space
;Parameters: None
;Returns: The number of atoms in attentional focus space
(: attentionalFocusSize (-> Number))
(= (attentionalFocusSize)
   (let $atomList (getAtomList)
    (size-atom $atomList)
   )
)

;Function: lessThanSti
;Description: Helper function that checks if the STI of $elem is less than the STI of $pivot.
;Parameters:
;         $elem: The first atom.
;         $pivot: The atom to compare against.
;Returns: True if $elem has a lower STI than $pivot, otherwise False.
(: lessThanSti (-> Atom Atom Bool))
(= (lessThanSti $elem $pivot)
    (if (or (== $elem ()) (== $pivot ())) 
        False 
        (< (getSTI $elem) (getSTI $pivot))
    )
)

;Function: greaterEqualSti
;Description: Helper function that checks if the STI of $elem is greater than or equal to the STI of $pivot.
;Parameters:
;        $elem: The first atom.
;        $pivot: The atom to compare against.
;Returns: True if $elem has an equal or higher STI than $pivot, otherwise False.


(: greaterEqualSti (-> Atom Atom Bool))
(= (greaterEqualSti $elem $pivot)
    (if (or (== $elem ()) (== $pivot ())) 
        False 
        (>= (getSTI $elem) (getSTI $pivot))
    )
)

;Function: sortAtomsBySti
;Description: Sorts a list of atoms by their STI values in ascending order using recursive filtering.
;Parameters:
;         $atoms: A list of atoms.
;Returns: A sorted list of atoms in ascending order of STI.

(: sortAtomsBySti (-> Symbol Symbol))
(= (sortAtomsBySti $atoms)
    (if (== $atoms ())
        ()
        (let*
           (
               ($pivot (car-atom $atoms))
               ($tail (cdr-atom $atoms))
               ($lesser (binaryFilter lessThanSti $pivot $tail))
               ($greater (binaryFilter greaterEqualSti $pivot $tail))
               ($sortedLesser (sortAtomsBySti $lesser))
               ($sortedGreater (sortAtomsBySti $greater))
           )
           (concatTuple $sortedLesser (cons-atom $pivot $sortedGreater))
        )
    )
)

;Function: sortAtomsByStiDescending
;Description:Sorts a list of atoms by their STI values in descending order using recursive filtering.
;Parameters:
;         $atoms: A list of atoms.
;Returns: A sorted list of atoms in descending order of STI.
(: sortAtomsByStiDescending (-> Symbol Symbol))
(= (sortAtomsByStiDescending $atoms)
    (if (== $atoms ())
        ()
        (let*
           (
               ($pivot (car-atom $atoms))
               ($tail (cdr-atom $atoms))
               ($greater (binaryFilter greaterEqualSti $pivot $tail))
               ($lesser (binaryFilter lessThanSti $pivot $tail))
               ($sortedGreater (sortAtomsByStiDescending $greater))
               ($sortedLesser (sortAtomsByStiDescending $lesser))
           )
           (concatTuple $sortedGreater (cons-atom $pivot $sortedLesser))
        )
    )
)


(= (getLowestStiAtomInAFHelper $atoms $minAtom $minSTI)
    (if (== $atoms ())
        $minAtom
        (let* (
            ($current (car-atom $atoms))
            ($sti (getSTI $current))
            ($newMinAtom (if (< $sti $minSTI) $current $minAtom))
            ($newMinSTI (if (< $sti $minSTI) $sti $minSTI))
        )
        (getLowestStiAtomInAFHelper (cdr-atom $atoms) $newMinAtom $newMinSTI))
    )
)

;Function: getLowestStiAtomInAF
;Description: Goes through the AF and returns the Atom with the lowest Sti
;Parameters: None
;Returns: An Atom that has the lowerst sti in attentional focus.

(: getLowestStiAtomInAF (-> Atom))
(= (getLowestStiAtomInAF)
    (let $atoms (getAtomList)
        (if (== $atoms ())
            ()
            (getLowestStiAtomInAFHelper $atoms (car-atom $atoms) (getSTI (car-atom $atoms)))
        )
    )
)

;gets the maximum STI value in the attentional focus

(: getAfMaxSTIHelper (-> Expression Expression))
(= (getAfMaxSTIHelper $atoms)
    (let* (
        ($vals (getSTI (superpose $atoms)))
    )
    $vals
    )
)

;Function: getAfMaxSTI
;Description: Goes through the AF and returns the highest Sti
;Parameters: None
;Returns: An Atom that has the highest sti in attentional focus.

(: getAfMaxSTI (-> Number))
(= (getAfMaxSTI)
    (let $atoms (getAtomList)
        (if (== $atoms ())
            0.0
            (let* (
                ($stiValues (collapse (getAfMaxSTIHelper $atoms)))
                ($maxSTI (max-atom $stiValues))
            )
            $maxSTI
            )
        )
    )
)

;the function below updates the attentional focus with a new atom
;the RemoveAFSignal() and AddAFSignal() functions have been skipped in this function because it appears to primarily 
;serve logging the additional and removal of an atom as i reviewed in the example/AtomSpaceEventSubscribeExample.cc
;and we may implement it in the future if needed

;Function: updateAttentionalFocus
;Description: Updates the attentional focus by adding a new atom, 
;             or replacing the lowest STI atom if the attentional focus is full.
;Parameters:
;          $atom: The atom to be added or updated.
;Returns: Nothing if no update occurs, otherwise the atom is added.
(: updateAttentionalFocus (-> Atom empty))
(= (updateAttentionalFocus $atom)
   (let*
       (
           ($maxSize (maxAFSize)) 
           ($sti (getSTI $atom)) 
           ($currentSize (attentionalFocusSize)) 
           ($isInAF (atomIsInAF $atom)) ; Check if atom is already in AF
       )

       (if $isInAF
           ; Case 1: Atom is already in AF, update its value
           (let ()
               (remove-atom &attentionalFocus $atom)
               (addAtomToAF $atom)
           )
           (if (< $currentSize $maxSize)
               ; Case 2: AF is not full, add the new atom
               (addAtomToAF $atom)
               (let $lowestAtom (getLowestStiAtomInAF) ; Only compute if needed
                    (if (> $sti (getSTI $lowestAtom))  ; Case 3: Replace if better
                        (let ()
                            (remove-atom &attentionalFocus $lowestAtom)
                            (addAtomToAF $atom)
                        )
                        () ; Case 4: Atom not added
                    )
               )
           )
       )
   )
)

;Function: getRandomAtomNotInAF
;Description: Retrieves a random atom that is not in attentional focus.
;Parameters: None.
;Returns: A randomly selected atom from outside attentional focus.
(: getRandomAtomNotInAF (-> Symbol))
(= (getRandomAtomNotInAF)
   (let*
       (
           ($allAtoms  (getAtomsInBins))
           ($filteredAtoms (filter $allAtoms atomIsNotInAF))
       )
       (if (== $filteredAtoms ())
           %Undefined%
        (let*
               (
                   ($randInt (random-int 0 (size-atom $filteredAtoms)))
                   ($randomAtom (index-atom $filteredAtoms $randInt))
               )
             $randomAtom
           )
       )
   )
)


;;; Function: getIncomingSet
;;; Description: Retrieves the set of incoming links of a specific type for a given atom,
;;;              filtering out links not in the attentional focus (AF).
;;; Parameters:
;;;   $atom: The atom for which to find incoming links.
;;;   $type: The type of link to consider.
;;; Returns: A list of incoming links that are in the AF.

(: getIncomingSet (-> Atom Type List))
(= (getIncomingSet $atom $type)
    (let* (
          ($incoming_set (getIncomingSetByType $atom $type))
          ($filtered_set (filterLinksInAF $incoming_set))
           )
        $filtered_set
    )
)
;!!!the filtered set needs sorting by STI value

;;; Function: filterLinksInAF
;;; Description: Filters a list of links, returning only those that are in the attentional focus (AF).
;;; Parameters:
;;;   $incoming_set: A list of incoming links to filter.
;;; Returns: A new list containing only the links that are in the AF.
(: filterLinksInAF (-> List List))
(= (filterLinksInAF $incoming_set)
    (let $atoms (collapse (filterLinksInAFHelper $incoming_set))
        $atoms
    )
)
; function filterLinksInAFHelper
; return list of atom that is not in AF
(: filterLinksInAFHelper (-> List List))
(= (filterLinksInAFHelper $incoming_set)
    (let $atom (superpose $incoming_set)
        (if (atomIsInAF $atom)
            $atom
            (emtpy)
        )
    )
)

;;; Function: getIncomingSetByType
;;; Description: Retrieves the set of incoming links of a specific type for a given atom
;;;              without filtering based on the attentional focus.
;;; Parameters:
;;;   $atom: The atom for which to find incoming links.
;;;   $type: The type of link to consider.
;;; Returns: A list of incoming links of the specified type.

(: getIncomingSetByType (-> Atom Type List))
(= (getIncomingSetByType $atom $type)
    (collapse 
        (superpose   
            (
                (match &attentionalFocus ($type $atom $b) ($type $atom $b))
                (match &attentionalFocus ($type $b $atom) ($type $b $atom))
            )
        )  
    )
)


;This function simply matches if two nodes are equal and they are in AF
(:nodeMatch (-> Atom Atom Bool))
(= (nodeMatch $node1 $node2)
    (if (and (== $node1 $node2) (atomIsInAF $node2))
        True
        False
    )
)





; Function: tuple-count
 ; Description: Calculates the tuple-count of a tuple.
 ; Parameters:
 ;   - $tuple: The tuple whose tuple-count is to be calculated.
 ; Returns:
 ;   - The tuple-count of the tuple as an integer.
 ;; Count the number elements in an expression

 ;; this Function is copied from the pattern minor project found at https://github.com/iCog-Labs-Dev/hyperon-miner/blob/experiments/experiments/utils/common-utils.metta

   (: tupleCount (-> %Undefined% Number))
   (= (tupleCount $atom) (if (== $atom ()) 0 (+ 1 (tupleCount (cdr-atom $atom)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;;(: getArity (-> $pattern) Number)
 ;; we substruct 1 since the getArity count the all tuple and we don't want to count
 ;; the "AND LINK" as a part of the arity

 ;; this Function is copied from the pattern minor project found at https://github.com/iCog-Labs-Dev/hyperon-miner/blob/experiments/experiments/utils/common-utils.metta


(= (getArity $pattern)
	(if (== $pattern ())
		0
	    (- (tupleCount $pattern) 1)
	) 
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ; Function: getVariables
 ; This function extracts all the variables from a given pattern (Expression).
 ; It works recursively by checking each element of the pattern to see if it is of the metatype "Variable".
; this funtion is required because it is called by the termMatchMixinLinkMatch function
 ; Parameters:
 ;   - $pattern: The pattern from which to extract the variables.
 ; Returns:
 ;   - A list of all the variables in the pattern.

(= (getVariables $pattern)
    (if (== $pattern ())
        ()
        (if (== (let* (
                        ($var (car-atom $pattern)))
                    (get-metatype $var)) Variable)
            ( (car-atom $pattern) (getVariables (cdr-atom $pattern)))
            (getVariables (cdr-atom $pattern))
        ))
)


(: termMatchMixinLinkMatch ( -> Atom Atom Bool))

(= (termMatchMixinLinkMatch $ptm $lsoln)
    (if (== $ptm $lsoln)
        True
        (if (== (car-atom $ptm) CHOICE_LINK)  
            True
            (if (not (== (car-atom $ptm) (car-atom $lsoln)))
                False
                ;else
                (let* (( $ptmArity (getArity $ptm))
                       ( $lsolnArity (getArity $lsoln)))
                    (if (not (== $ptmArity $lsolnArity))
                        False
                        ;else
                        (if (== (car-atom $ptm) SCOPE_LINK)
                            (if (not (== (getVariables $ptm) (getVariables $lsoln)))
                                False
                                True)
                            True)
                    )
                )
            )
        )
    )
)






; This function matches if the link matches the TermMatchMixin condition and is in The attentional focus.It is a function that is currently found in the opencog atomspace repository(https://github.com/opencog/atomspace/blob/master/opencog/query/TermMatchMixin.cc).

( :linkMatch(-> Atom Atom Bool))
( = (linkMatch $ptm $lsoln)
    (if (and (termMatchMixinLinkMatch $ptm $lsoln) (atomIsInAF $lsoln))
    True
    False
    )
)


;;; Function: getIncomingSetwithoutType
;;; Description: Retrieves the set of incoming links for a given atom,
;;;              without filtering out links not in the attentional focus (AF).
;;; Parameters:
;;;   $atom: The atom for which to find incoming links.
;;; Returns: A list of incoming links.
(: getIncomingSetwithoutType (-> Atom List))
(= (getIncomingSetwithoutType $atom)
    (collapse
        (superpose
            (
                (match &attentionalFocus ($type $atom $b) ($type $atom $b))
                (match &attentionalFocus  ($type $b $atom) ($type $b $atom))
            )
        )  
    )
)



( = (getRandomAtomInAF)
    (if  (== (attentionalFocusSize) 0)
        ("AF is Empty")
        ;else
        ( let*( ($randomNumber (random-int 0 (attentionalFocusSize) ))
            ($atoms (getAtomList))
            ($randomAtom (index-atom $atoms $randomNumber))
            )
        $randomAtom
        )
    )
)


(= (attentionalFocus)
    &attentionalFocus
)


(: removeAtomAttentionalfocus (-> atom empty))
(= (removeAtomAttentionalfocus $atom)
	(if (atomIsInAF $atom)
		(remove-atom &attentionalFocus $atom)
		()
	)
)


