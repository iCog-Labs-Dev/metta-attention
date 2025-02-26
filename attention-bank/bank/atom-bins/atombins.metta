
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

(: insertAtom (-> Number Atom Grounded empty))
(= (insertAtom $bin_index $pattern $space)
   (if(== (getType $space $pattern) (%Undefined%))
      ("Atom is not valid") ; Validate type
      (if (== (collapse (match &atombin ($bin_index $x) $x)) ())
         (let () 
              (add-atom &atombin ($bin_index ($pattern)))
              ("Atom Inserted")
           ) ; Insert new bin
         (match &atombin ($bin_index $x)
            (let*(
                ($_ (remove-atom &atombin ($bin_index $x))) ; Update bin
                ($updated (cons-atom $pattern $x))
                ($_ (add-atom &atombin ($bin_index $updated)))
               )
              ("Atom Inserted")
            )
         )
      )
   )
)

;Function to remove an atom from a specific bin
(: removeAtom (-> Number Atom Grounded empty))
(= (removeAtom $bin_index $atom $space)
   (if (== (getType $space $atom) (%Undefined%))
      ("Atom is not valid") ; Validate type
      (let $bin_contents (collapse (match &atombin ($bin_index $contents) $contents))
         (if(== $bin_contents ())
            ("Bin is empty") ; Bin is empty, nothing to remove
            (let $updated_contents (remove_atom_helper $atom (car-atom $bin_contents))
               ;(if (== $updated_contents ())
               ;   (remove-atom &atombin ($bin_index $bin_contents)) ; Remove empty bin
                  (match &atombin ($bin_index $x)
                     (let*
                       (
                          ($_ (remove-atom &atombin ($bin_index $x)))
                          ($_ (add-atom &atombin ($bin_index $updated_contents)))
                        )
                      ("Atom Removed")
                     )
                  )
               ;)
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

;predicate function to check if a list is empty
(: notEmpty (-> Expression Bool))
(= (notEmpty ($x $y)) (> (size $y) 0 ))

;this function randomly selects a bin from atombins and proceeds to randomly choose a single element from selected random bin.
(: getRandomAtom (-> Symbol))
(= (getRandomAtom)
   (
    let*(
         ($handleSetSeq (collapseAtomBin &atombin))
         ($filteredOutput (filter $handleSetSeq notEmpty ()))
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
(: getContent (-> Number Expression Expression))
(= (getContent $index $out)
   (let $content (collapseAtomBin &atombin)
    (concatTuple $out (valuesAtIndex $index $content))
   )
)

;A function to get the values stored in the &atombin atomspace, at the specified index.
;it accepts a predicate function as it's second argument.
;the type of the function should take a generic value and return a Boolean 
(: getContentIf (-> Number (-> Symbol Number Number Bool)) Number Number Expression Grounded Expression)
(= (getContentIf $index $predicate $lower $upper $out $space)
  (
   let*(
        ($handleSetSeq (collapseAtomBin &atombin))
        ($handleSet (valuesAtIndex $index $handleSetSeq))
        ($filteredOutput (customFilter $handleSet $predicate $lower $upper $space))
        ($res (concatTuple $out $filteredOutput))
      )
      $res
  )
)

(= (AtomBin)
   &atombin
)
