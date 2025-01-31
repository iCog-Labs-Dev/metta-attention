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
    (let $atoms (getAtomList)
        (if (== $atoms ())
            0
            (size $atoms)
        )
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

;gets the maximum STI value in the attentional focus
(: getAfMaxSTI (-> Number))
(= (getAfMaxSTI)
    
        (let*
            (
               
               ($sortedAtoms (sortAtomsBySti  (getAtomList)))
               ($reverseSortedAtoms (reverseExpr $sortedAtoms))
              
               
            )

            (if (==  $sortedAtoms ())
                0
                (let $maxAtom (car-atom $reverseSortedAtoms)
                    (getSTI $maxAtom)
                )
              
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
           ($maxSize (maxAFSize)) 
           ($sti (getSTI $atom)) 
           ($currentSize (attentionalFocusSize)) 
           ($lowestAtom (getLowestStiAtomInAF)) 
           ($isInAF (atomIsInAF $atom)) ; Check if atom is already in AF
           ($canAdd (< $currentSize $maxSize)) ; Check if AF is not full
           ($shouldReplace (> $sti (getSTI $lowestAtom))) ; Check if replacement is needed
       )

       (if $isInAF
           ; Case 1: Atom is already in AF, update its value
           (let ()
               (remove-atom &attentionalFocus $atom)
               (addAtomToAF $atom)
           )
           (if $canAdd
               ; Case 2: AF is not full, add the new atom
               (addAtomToAF $atom)

               (if $shouldReplace
                   ; Case 3: Replace the lowest STI atom with the new atom
                   (let ()
                       (remove-atom &attentionalFocus $lowestAtom)
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
