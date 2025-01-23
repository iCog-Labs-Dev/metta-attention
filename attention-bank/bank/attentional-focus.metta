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
(= (atomIsNotInAF $atom)
   (if  (== (collapse (match &attentionalFocus $atom $atom)) ())
        True
        False
    )
)

;adds an atom to the attentional focus if it is valid
(: addAtomToAF (-> Atom Symbol))
(= (addAtomToAF $atom)
   (if (== (getType $atom) %Undefined%)
       (Atom is not valid)
       (add-atom &attentionalFocus $atom)
   )
)

; Helper function for filtering atoms with STI less than the pivot
(: lessThanSti (-> Atom Atom Bool))
(= (lessThanSti $pivot $elem)
    (if (or  (== $elem ())  (== $pivot())) 
        False 
        (< (getSTI $elem) (getSTI $pivot))
    )
)

; Helper function for filtering atoms with STI greater than or equal to the pivot
(: greaterEqualSti (-> Atom Atom Bool))
(= (greaterEqualSti $pivot $elem)
    (if (or  (== $elem ())  (== $pivot()))
        False 
        (>= (getSTI $elem) (getSTI $pivot))
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
               ($sorted_lesser (sortAtomsBySti $lesser))
               ($sorted_greater (sortAtomsBySti $greater))
           )

           (concatTuple $sorted_lesser (cons-atom $pivot $sorted_greater))
        )
    )
)

;gets the atom with the lowest STI value in the attentional focus
(:getLowestStiAtomInAF (-> Number))
(=(getLowestStiAtomInAF)
    (let $sortedAtoms (sortAtomsBySti  (getAtomList))
        (if (==  $sortedAtoms ())
            ()
            (car-atom  $sortedAtoms)
        )
    )
)





;the function below updates the attentional focus with a new atom
;the RemoveAFSignal() and AddAFSignal() functions have been skiped in this function because it appears to primarily 
;serve logging the additional and removal of an atom as i reviewed in the example/AtomSpaceEventSubscribeExample.cc
;and we may implement it in the future if needed

(: updateAttentionalFocus (-> Atom empty))
(= (updateAttentionalFocus $atom)
   (let*
       (
           ($max_size (maxAFSize)) 
           ($sti (getSTI $atom)) 
           ($current_size (attentionalFocusSize)) 
           ($lowest_atom (getLowestStiAtomInAF)) 
       )

       (if (atomIsInAF $atom)
           ; Case 1: Atom is already in AF, update its value
           (let ()
               (remove-atom &attentionalFocus $atom)
               (addAtomToAF $atom)
           )

           (if (< $current_size $max_size)
               ; Case 2: AF is not full, add the new atom
               (addAtomToAF $atom)


               (if (> $sti (getSTI $lowest_atom))
                   ; Case 3: Replace the lowest STI atom with the new atom
                   (let ()
                       (remove-atom &attentionalFocus $lowest_atom)
                       (addAtomToAF $atom)
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








