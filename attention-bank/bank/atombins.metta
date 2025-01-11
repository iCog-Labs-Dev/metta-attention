
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


;!(add-atom &atombin (1 (a)))
;!(add-atom &atombin (2 (d)))
;!(add-atom &atombin (3 (c)))
;!(add-atom &atombin (17 (s c)))
;!(add-atom &atombin (18 (g j)))
;!(add-atom &atombin (37 (f h j k)))

; this file contain metta code for AtomBins class. here atom bin is a space where atoms are stored in a key value pair.
; key is the index of the atom and value is the collections of atom itself.
; this class contain functions to insert, remove, size, getRandomatom, etc and can be implemented here in this file.
; Function to insert an atom into the specifc bin
!(bind! &atombin (new-space))
(: insertAtom (-> Number Atom empty))
(= (insertAtom $bin_index $pattern)
   (if(== (getType $pattern) %Undefined%)
      (Atom is not valid) ; Validate type
      (if (== (collapse (match &atombin ($bin_index $x) $x)) ())
         (add-atom &atombin ($bin_index ($pattern))) ; Insert new bin
         (match &atombin ($bin_index $x)
            (let ()
               (remove-atom &atombin ($bin_index $x)) ; Update bin
               (let $updated (cons-atom $pattern $x)
                  (add-atom &atombin ($bin_index $updated))
               )
            )
         )
      )
   )
)
; Function to remove an atom from a specific bin
(: removeAtom (-> Number Atom empty))
(= (removeAtom $bin_index $atom)
   (if (== (getType $atom) %Undefined%)
      (Atom is not valid) ; Validate type
      (let $bin_contents (collapse (match &atombin ($bin_index $contents) $contents))
         (if(== $bin_contents ())
            (Bin is empty) ; Bin is empty, nothing to remove
            (let $updated_contents (remove_atom_helper $atom (car-atom $bin_contents))
               (if (== $updated_contents ())
                  (remove-atom &atombin ($bin_index $bin_contents)) ; Remove empty bin
                  (match &atombin ($bin_index $x)
                     (let ()
                        (remove-atom &atombin($bin_index $x))
                        (add-atom &atombin ($bin_index $updated_contents))
                     )
                  )
               )
            )
         )
      )
   )
)


; Helper function to remove an atom from a list of contents
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

;This function fetches all the values stored in the &atombin atomspace.
(: getContent (-> Number Expression Expression))
(= (getContent $index $out)
   (let $content (collapseAtomBin &atombin)
    (valuesAtIndex $index $content)
   )
)

;A function to get the values stored in the &atombin atomspace.
;it accepts a predicate function as it's second argument.
;the type of the function should take a generic value and return a Boolean 
(: getContentIf (-> Number (-> $x Boolean)) Expression)
(= (getContentIf $index $predicate $out)
  (
   let*(
        ($handleSetSeq (collapseAtomBin &atombin))
        ($handleSet (valuesAtIndex $index $handleSetSeq))
        ($filteredOutput (filter $handleSet $predicate))
      )
      $filteredOutput
  )
)

