
; this file contain metta code for AtomBins class. here atom bin is a space where atoms are stored in a key value pair.
; key is the index of the atom and value is the collections of atom itself.
; this class contain functions to insert, remove, size, getRandomatom, etc and can be implemented here in this file.
 

; functions like the following


; - insert atom - it recives bin numebr and the atom
; - remove atom - it recive bin number and the atom
; - size - it recive bin number return the number of atom found inside that bin 
; - getRandomAtom - it returns random atom from that space
; - getcontent - it recives bin number and returns atom found in that bin index
; - getcontentif - it recives bin number, predicate and returns the atoms based on that predicat


; implement insert, remove, size, getRandomatom, 
; Function to insert an atom into the specifc bin
!(bind! &atombin (new-space))

;Function: insertAtom
;Description: Inserts an atom into the specified bin index within &atombin space.
;             If the atom's type is undefined(ifthe atom has neither AV nor STV)
;             , it returns an error message.
;             If the bin(the index of the bin in which the atom is to be inserted to)is empty, 
;             it creates a new bin and adds the atom.
;             Otherwise, it updates the existing bin by adding the new atom.
;Parameters:
;         $bin_index: The index of the bin where the atom should be inserted.
;         $pattern: The atom to be inserted.
;Returns: A confirmation message ("Atom Inserted") if successful, 
;         or an error message if the atom is invalid.
(: insertAtom (-> Number Atom Bool))
(= (insertAtom $bin_index $pattern)
  (if (== (collapse (match &atombin ($bin_index $x) $x)) ())
           (let ()
               (add-atom &atombin ($bin_index ($pattern))) ; Insert new bin
               True
           )
           (match &atombin ($bin_index $x)
               (if (contains $x $pattern)   ; Check for duplicates
                   False ; Do not insert duplicate
                   (let* (
                        ($atomremove (remove-atom &atombin ($bin_index $x)))  ; Remove old bin
                        ($updated (cons-atom $pattern $x))  ; Add new atom
                        ($atomadded (add-atom &atombin ($bin_index $updated))) ; Update bin
                    )
                    True
                   )
               )
           )
   )
)


;Function: removeAtom
;Description: Removes a specified atom from a given bin from &atombin space.
;            If the atom's type is undefined (if the atom has neither AV nor STV), 
;            it returns an error message.
;            If the bin is empty, it returns a message indicating that there is nothing to remove.
;            Otherwise, it updates the bin by removing the specified atom.
;Parameters:
;          $bin_index: The index of the bin from which the atom should be removed.
;          $atom: The atom to be removed.
;Returns: A confirmation message ("Atom Removed") if successful, 
;         or an error message if the atom is invalid or the bin is empty.

(: removeAtom (-> Number Atom Bool))
(= (removeAtom $bin_index $atom)
   (if (== (getValueType $atom) %Undefined%)
      False ; Validate type
      (let $bin_contents (collapse (match &atombin ($bin_index $contents) $contents))
         (if(== $bin_contents ())
            False ; Bin is empty, nothing to remove
            (let $updated_contents (removeAtomHelper $atom (car-atom $bin_contents))
                  (match &atombin ($bin_index $x)
                     (let*
                       (
                          ($atomremove (remove-atom &atombin ($bin_index $x)))
                          ($atomadded 
                            (if (== $updated_contents ())
                                ()
                                (add-atom &atombin ($bin_index $updated_contents))
                            )
                          )
                        )
                     True
                     )
                  )
            )
         )
      )
   )
)

;Function: removeAtomHelper
;Description: removes a specified atom from a list of contents.
;             If the atom is found, it is skipped in the resulting list.
;Parameters:
;          $atom: The atom to be removed.
;          $contents: The list of atoms from which to remove the specified atom.
;Returns: A new list with all occurrences of the specified atom removed.
(: removeAtomHelper (-> Atom List List))
(= (removeAtomHelper  $atom $list)

   (collapse 
        (let $x (superpose $list)
            (if (== $x $atom) 
                (empty) 
                $x
            )
        ) 
   )
)



;An abstraction that simplifies quering an atomspace.
;Usage: simply pass the identifier of the atomspace you want.
(: collapseAtomBin (-> Grounded Expression))
(= (collapseAtomBin $space) (collapse (get-atoms $space)))




(= (atomBin)
   &atombin
)

(: getContent (-> Number Number Expression))
(= (getContent $lower $higher)
  (if (> $lower $higher)
    ()  
    (let*
      (
        ($vals (collapse (match (atomBin) ($lower $content) $content)))

        ($rest (getContent (+ $lower 1) $higher))

        ($result (collectContents $vals $rest))
      )
      $result
    )
  )
)





(= (getAllAtomsInBins)
	( let* 
		(
			($vals (collapse (match (atomBin) ($x $y) $y)))
         ($filteredVals (filter $vals notEmpty))
         ($collectedContents (collectContents $filteredVals ()))
		)
        $collectedContents
        
        
	)
)
