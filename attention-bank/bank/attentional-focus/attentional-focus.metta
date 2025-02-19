!(bind! &attentionalFocus (new-space))

(= (maxAFSize) 100)

;checks if an atom is in attentional focus

(: atomIsInAF (-> Atom Bool))
(= (atomIsInAF $atom)
   (if  (== (collapse (match &attentionalFocus $atom $atom)) ())
        False
        True
    )
)

;checks if an atom is in attentional focus

(: atomIsNotInAF (-> Atom Bool))
(= (atomIsNotInAF $atom)
   (not (atomIsInAF $atom))
)

;adds an atom to the attentional focus if it is valid

(: addAtomToAF (-> Atom Symbol))
(= (addAtomToAF $atom)
   (if (== (getType $atom) %Undefined%)
       ("Atom is not valid")
       (let()
         (add-atom &attentionalFocus $atom)
         ("Atom Added")
       )
   )
)

; Collapse space to list of atoms

(: getAtomList(->Symbol))
(= (getAtomList)
   (collapse (get-atoms &attentionalFocus))
)

;it returns the total number of atoms in the attentional focus

(: attentionalFocusSize (-> Number))
(= (attentionalFocusSize)
   (let $atomList (getAtomList)
    (size-atom $atomList)
   )
)


; Helper function for filtering atoms with STI less than the pivot

(: lessThanSti (-> Atom Atom Bool))
(= (lessThanSti $elem $pivot)
    (if (or (== $elem ()) (== $pivot ())) 
        False 
        (< (getSTI $elem) (getSTI $pivot))
    )
)

; Helper function for filtering atoms with STI greater than or equal to the pivot

(: greaterEqualSti (-> Atom Atom Bool))
(= (greaterEqualSti $elem $pivot)
    (if (or (== $elem ()) (== $pivot ())) 
        False 
        (>= (getSTI $elem) (getSTI $pivot))
    )
)

; Sorts a list of atoms by their STI values in ascending order

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

; Sorts a list of atoms by their STI values in descending order

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

;gets the atom with the lowest STI value in the attentional focus

;(: getLowestStiAtomInAFHelper (-> List Atom Number Atom))
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

;(: getAfMaxSTIHelper (-> List Atom Number Atom))
(= (getAfMaxSTIHelper $atoms $maxAtom $maxSTI)
    (if (== $atoms ())
        $maxSTI
        (let* (
            ($current (car-atom $atoms))
            ($sti (getSTI $current))
            ($newMaxAtom (if (> $sti $maxSTI) $current $maxAtom))
            ($newMaxSTI (if (> $sti $maxSTI) $sti $maxSTI))
        )
        (getAfMaxSTIHelper (cdr-atom $atoms) $newMaxAtom $newMaxSTI))
    )
)

(: getAfMaxSTI (-> Number))
(= (getAfMaxSTI)
    (let $atoms (getAtomList)
        (if (== $atoms ())
            0.0
            (getAfMaxSTIHelper $atoms (car-atom $atoms) (getSTI (car-atom $atoms)))
        )
    )
)

;the function below updates the attentional focus with a new atom
;the RemoveAFSignal() and AddAFSignal() functions have been skipped in this function because it appears to primarily 
;serve logging the additional and removal of an atom as i reviewed in the example/AtomSpaceEventSubscribeExample.cc
;and we may implement it in the future if needed

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
                        (empty) ; Case 4: Atom not added
                    )
               )
           )
       )
   )
)

; Function to retrieve a random atom not in attentional focus

(: getRandomAtomNotInAF (-> Atom))
(= (getRandomAtomNotInAF)
   (let*
       (

           ($allAtoms  (getAtomBinList))
           ($filteredAtoms (filter $allAtoms atomIsNotInAF))
       )
       (if (== $filteredAtoms ())
           %Undefined 
           (let*
               (

                   ($res (py-list $filteredAtoms))
                   ($randomAtom ((py-atom random.choice) $res))
               )
               $randomAtom 
           )
       )
   )
)

;;; Function: getIncomingSet
;;; Description: Retrieves the set of incoming links of a specific type for a given atom,
;;;              filtering out links not in the active frame (AF).
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
;;; Description: Filters a list of links, returning only those that are in the active frame (AF).
;;; Parameters:
;;;   $incoming_set: A list of incoming links to filter.
;;; Returns: A new list containing only the links that are in the AF.

(: filterLinksInAF (-> List List))
(= (filterLinksInAF $incoming_set)
    (if (== $incoming_set ())
        ()
        (let* (
              ($head (car-atom $incoming_set))
              ($tail (cdr-atom $incoming_set))
              ($filtered_head 
                    (if (atomIsInAF $head)
                        $head
                        ()
                    ))
               )
               
            (concatTuple ($filtered_head) (filterLinksInAF $tail))
        )
    )
)

;;; Function: getIncomingSetByType
;;; Description: Retrieves the set of incoming links of a specific type for a given atom
;;;              without filtering based on the active frame.
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


(= (getArity Nil ) 0 )
(= (getArity $pattern)
    (- (tupleCount $pattern) 1) )

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



