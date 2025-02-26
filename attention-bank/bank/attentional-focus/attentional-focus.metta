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
(: addAtomToAF (-> Atom Grounded Symbol))
(= (addAtomToAF $atom $space)
   (if (== (getType $space $atom) (%Undefined%))
       ("Atom is not valid")
       (let()
         (add-atom &attentionalFocus $atom) ;TODO: pass &attentionalFocus as parameter to hide implicit dependence and avoid side effects.
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
    (let $atoms (getAtomList)
        (if (== $atoms ())
            0
            (size $atoms)
        )
    )
)

; Helper function for filtering atoms with STI less than the pivot
;(: lessThanSti (-> Expression Symbol Grounded Bool))
(= (lessThanSti $elem $pivot $space)
    (if (or (== $elem ()) (== $pivot ())) 
        False 
        (< (getSTI (getType $space $elem)) (getSTI (getType $space $pivot)))
    )
)

; Helper function for filtering atoms with STI greater than or equal to the pivot
;(: greaterEqualSti (-> Expression Symbol Grounded Bool))
(= (greaterEqualSti $elem $pivot $space)
    (if (or (== $elem ()) (== $pivot ())) 
        False 
        (>= (getSTI (getType $space $elem)) (getSTI (getType $space $pivot)))
    )
)

; Sorts a list of atoms by their STI values in ascending order
(: sortAtomsBySti (-> Symbol Grounded Symbol))
(= (sortAtomsBySti $atoms $space)
    (if (== $atoms ())
        ()
        (let*
           (
               ($pivot (car-atom $atoms))
               ($tail (cdr-atom $atoms))
               ($lesser (binaryFilter lessThanSti $pivot $tail $space))
               ($greater (binaryFilter greaterEqualSti $pivot $tail $space))
               ($sortedLesser (sortAtomsBySti $lesser $space))
               ($sortedGreater (sortAtomsBySti $greater $space))
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
(:getLowestStiAtomInAF (-> Grounded Number))
(=(getLowestStiAtomInAF $space)
    (let $sortedAtoms (sortAtomsBySti  (getAtomList) $space)
        (if (==  $sortedAtoms ())
            ()
            (car-atom  $sortedAtoms)
        )
    )
)

;gets the maximum STI value in the attentional focus
(: getAfMaxSTI (-> Grounded Number))
(= (getAfMaxSTI $space)
    (let $sortedAtoms (sortAtomsByStiDescending (getAtomList))
        (if (==  $sortedAtoms ())
            0
            (let $maxAtom (car-atom $sortedAtoms)
                    (getSTI (getType $space $maxAtom))
            )
        )
    )
)


    

;the function below updates the attentional focus with a new atom
;the RemoveAFSignal() and AddAFSignal() functions have been skiped in this function because it appears to primarily 
;serve logging the additional and removal of an atom as i reviewed in the example/AtomSpaceEventSubscribeExample.cc
;and we may implement it in the future if needed

(: updateAttentionalFocus (-> Atom Grounded empty))
(= (updateAttentionalFocus $atom $space)
   (let*
       (
           ($maxSize (maxAFSize)) 
           ($sti (getSTI (getType $space $atom))) 
           ($currentSize (attentionalFocusSize)) 
           ($lowestAtom (getLowestStiAtomInAF)) 
           ($isInAF (atomIsInAF $atom)) ; Check if atom is already in AF
           ($canAdd (< $currentSize $maxSize)) ; Check if AF is not full
           ($shouldReplace (> $sti (getSTI (getType $space $lowestAtom)))) ; Check if replacement is needed
       )

       (if $isInAF
           ; Case 1: Atom is already in AF, update its value
           (let ()
               (remove-atom &attentionalFocus $atom)
               (addAtomToAF $atom $space)
           )
           (if $canAdd
               ; Case 2: AF is not full, add the new atom
               (addAtomToAF $atom $space)

               (if $shouldReplace
                   ; Case 3: Replace the lowest STI atom with the new atom
                   (let ()
                       (remove-atom &attentionalFocus $lowestAtom)
                       (addAtomToAF $atom $space)
                   )
                   ; Case 4: Atom not added (STI is too low)
                   (empty)
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
    (let* (
          ($linkVariationOne (collapse (match &attentionalFocus ($type $atom $b) ($type $atom $b))))
          ($linkVariationTwo (collapse (match &attentionalFocus ($type $a $atom) ($type $a $atom))))
          )
        (concatTuple $linkVariationOne $linkVariationTwo)
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

