!(bind! &attentionalFocus (new-space))
!(bind! &newAtomInAV (new-space))
(= (attentionalFocus) &attentionalFocus)
(= (newAtomInAV) &newAtomInAV)

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
;Description: gives list of atoms not in the atentional focus.
;Parameters:
;          list of atoms
;Returns: return list of atoms not in the atentional focus


(: atomIsNotInAF (-> Expression Expression))
(= (atomIsNotInAF $list)

   (collapse 
        (let $x (superpose $list)
            (if (atomIsInAF $x) 
                (empty) 
                $x
            )
        ) 
   )
)

;Function: addAtomToAF
;Description:
;           if the atom has neither AV nor STV,it returns an error message
;           if an atom is valid,it will add it to the attentional focus space. 
;           if an atom is new to the AF and isnt in newAtomIAV 
;Parameters:
;          $atom: The atom to add.
;Returns: A message indicating success or failure.
(: addAtomToAF (-> Atom Bool))
(= (addAtomToAF $atom)
   (if (== (getValueType $atom) %Undefined%)
       False
       (let* 
            (
                (() (add-atom &attentionalFocus $atom))
                (() (if (contains (getNewAtomInAVList) $atom)
                        ()
                        (let $wrote
                            (write_csv_wrapper (attentionalFocus))
                            (add-atom &newAtomInAV $atom)
                        )
                    )
                )
            )
            True
        )
   )
)

;Function: getAtomList
;Description: Retrieves a list of all atoms currently in attentional focus space.
;Parameters: None.
;Returns: A list of atoms in attentional focus space.
(: getAtomList (-> Expression))
(= (getAtomList)
   (collapse (get-atoms &attentionalFocus))
)

;Function: getNewAtomInAVList
;Description: Retrieves a list of all atoms currently in the newAtomInAV space.
;Parameters: None.
;Returns: A list of atoms in newAtomInAV space.
(: getNewAtomInAVList (-> Expression))
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


(= (getLowestStiAtomInAFHelper $atoms $minAtom $minSTI)
    (if (== $atoms ())
        $minAtom
        (let* (
            ($current (car-atom $atoms))
            ($sti (getSti $current))
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
            (let $atom (car-atom $atoms) (getLowestStiAtomInAFHelper $atoms (car-atom $atoms) (getSti $atom)))
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
(: updateAttentionalFocus (-> Atom ()))
(= (updateAttentionalFocus $atom)
   (let*
       (
        
           ($maxSize (getAttentionParam MAX_AF_SIZE)) 
           ($sti (getSti $atom)) 
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
                    (if (> $sti (getSti $lowestAtom))  ; Case 3: Replace if better
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
           ($allAtoms  (getAllAtomsInBins))
           ($filteredAtoms (filter $allAtoms atomIsNotInAF))
       )
       (if (== $filteredAtoms ())
          ()
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

;;; Function: getRandomAtomInAF
;;; Descriptions: Retrives at atom at random from the attentionalFocus
;;; Parameters: None
;;; Returns: A unit Atom in Af is empty or a random atom 
(: getRandomAtomInAF (-> Atom))
( = (getRandomAtomInAF)
    (if  (== (attentionalFocusSize) 0)
        ()
        ;else
        ( let*( 
            ($randomNumber (random-int 0 (attentionalFocusSize) ))
            ($atoms (getAtomList))
            ($randomAtom (index-atom $atoms $randomNumber))
            )
        $randomAtom
        )
    )
)


;;; Function: removeAtomAttentionalfocus
;;; Description: removes an atom from the attentionalFocus space
;;; Parameters:
;;;     $atom: The atom to be removed from AF
;;; Returns: A unit-atom
(: removeAtomAttentionalfocus (-> Atom Expression))
(= (removeAtomAttentionalfocus $atom)
	(if (atomIsInAF $atom)
		(remove-atom &attentionalFocus $atom)
		()
	)
)

;;; Function: removeNewAtomAv
;;; Description: removes an atom from the newAtonInAv space
;;; Parameters:
;;;     $atom: The atom to be removed from AF
;;; Returns: A unit-atom
(: removeNewAtomAV (-> Atom Expression))
(= (removeNewAtomAV $head)
    (remove-atom &newAtomInAV $head)
)
