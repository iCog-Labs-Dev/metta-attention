
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
(: insertAtom (-> Number Atom empty))
(= (insertAtom $bin_index $pattern)
  (if (== (collapse (match &atombin ($bin_index $x) $x)) ())
           (let ()
               (add-atom &atombin ($bin_index ($pattern))) ; Insert new bin
               ("Atom Inserted")
           )
           (match &atombin ($bin_index $x)
               (if (== (contains $x $pattern) True)  ; Check for duplicates
                   ("Atom already exists")  ; Do not insert duplicate
                   (let* (
                        ($atomremove (remove-atom &atombin ($bin_index $x)))  ; Remove old bin
                        ($updated (cons-atom $pattern $x))  ; Add new atom
                        ($atomadded (add-atom &atombin ($bin_index $updated))) ; Update bin
                    )
                    ("Atom Inserted")
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

(: removeAtom (-> Number Atom empty))
(= (removeAtom $bin_index $atom)
   (if (== (getValueType $atom) %Undefined%)
      ("Atom is not valid") ; Validate type
      (let $bin_contents (collapse (match &atombin ($bin_index $contents) $contents))
         (if(== $bin_contents ())
            ("Bin is empty") ; Bin is empty, nothing to remove
            (let $updated_contents (removehelp $atom (car-atom $bin_contents))
                  (match &atombin ($bin_index $x)
                     (let*
                       (
                          ($atomremove (remove-atom &atombin ($bin_index $x)))
                          ($atomadded (add-atom &atombin ($bin_index $updated_contents)))
                        )
                     ("Atom Removed")
                     )
                  )
            
            )
         )
      )
   )
)
(= (removehelp  $atom $list)

   (collapse 
        (let $x (superpose $list)
            (if (== $x $atom) 
                (empty) 
                $x
            )
        ) 
   )
)
;Function: remove_atom_helper
;Description: Recursively removes a specified atom from a list of contents.
;             If the atom is found, it is skipped in the resulting list.
;Parameters:
;          $atom: The atom to be removed.
;          $contents: The list of atoms from which to remove the specified atom.
;Returns: A new list with all occurrences of the specified atom removed.

(: remove_atom_helper (-> Atom List List))
(= (remove_atom_helper $atom $contents)
   (if(== $contents ())
      () ; End of list
      (let $head (car-atom $contents)
         (let $tail (cdr-atom $contents)
            (if(== $head $atom)
               $tail ; Skip the matching atom
               (let $rest (remove_atom_helper $atom $tail)
               (cons-atom $head $rest))
            )
         )
      )
   )
)

;An abstraction that simplifies quering an atomspace.
;Usage: simply pass the identifier of the atomspace you want.
(: collapseAtomBin (-> Grounded Expression))
(= (collapseAtomBin $space) (collapse (get-atoms $space)))


;this function randomly selects a bin from atombins and proceeds to randomly choose a single element from selected random bin.
(: getRandomAtom (-> Symbol))
(= (getRandomAtom)
   (
    let*(
         ($handleSetSeq (collapse (match (AtomBin) ($x $y) $y)))
         ($filteredOutput (filter $handleSetSeq notEmpty))
        )
    (if(== $filteredOutput ()) ;check if all bins in atom bins are empty
      empty
      (
       let*(
            ($res (py-list $filteredOutput))
            ($kvPair ((py-atom random.choice) $res)) ;randomly choose a bin
            ($collapsed ($kvPair))
            ($vals ((py-dot $kvPair __getitem__) 1)) ; Access the second element
            ($randomAtom ((py-atom random.choice) $vals)) ;randomly choose a single atom
          )
          $randomAtom
      )
    )
  )
)
;This function fetches all the values stored in &atombin atomspace, which are located at the specified index.
(: getContent (-> Number $list_t $list_t $list_t))
(= (getContent $index $atombins $out)
   (let $vals (valuesAtIndex $index $atombins) 
     (union-atom $out $vals)
   )
)

;A function to get the values stored in the &atombin atomspace, at the specified index.
;it accepts a predicate function as it's second argument.
;the type of the function should take a generic value and return a Boolean 
;(: getContentIf (-> Number (-> Symbol Number Number Bool)) Number Number $list_t $list_t $list_t)
(= (getContentIf $index $predicate $lower $upper $atombins $out)
  (
   let*(
        ($handleSet (valuesAtIndex $index $atombins))
        ($filteredOutput (customFilter $handleSet $predicate $lower $upper))
        ($res (union-atom $out $filteredOutput))
      )
    $res
  )
)

(= (AtomBin)
   &atombin
)

(= (getAtomsInBins)
	(collapse (get-atoms &atombin))
)

(= (getAllAtomsInBins)
	( let* 
		(
			($vals (collapse (match (AtomBin) ($x $y) $y)))
         ($filteredVals (filter $vals notEmpty))
         ($collectedContents (collectContents $filteredVals ()))
		)
        $collectedContents
        
        
	)
)
