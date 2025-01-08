

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
; Function to insert an atom into the correct bin
!(bind! &atom-bin (new-space))
(: insertAtom (-> Symbol empty))
(= (insertAtom $pattern)
   (get-type  $pattern)
)


; Function to remove an atom from a specific bin

(= (removeAtom  ($bin_index $atom))
   (let $bin_contents (collapse (match &atom-bin ($bin_index $contents) $contents))
      (if(== $bin_contents ())
         (Bin is empty)
         (let $updated_contents (remove_atom_helper $atom (car-atom $bin_contents))
            (if (== $updated_contents ())
               (remove-atom &atom-bin  ($bin_index $x))
               (match  &atom-bin  ($bin_index $x)
                  (let ()
                     (remove-atom &atom-bin ($bin_index $x))
                     (add-atom &atom-bin ($bin_index  $updated_contents))
                  )
               )
            )
         )
      )
   )
)

; Helper function to remove an atom from a list of contents
(: remove_atom_helper (-> Symbol List List))
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

