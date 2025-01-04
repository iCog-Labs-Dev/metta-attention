

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
   (let $sti (getSTI $pattern)
      (let $bin_index (importanceBin $sti)
         (if (== (collapse(match &atom-bin  ($bin_index $x) $x)) ())
            (add-atom &atom-bin ($bin_index $pattern))
            (match  &atom-bin  ($bin_index $x)
               (let ()
                  (remove-atom  &atom-bin  ($bin_index $x))
                  (add-atom  &atom-bin ($bin_index ($pattern $x)))
               )
            )
         )
      )
   )
          
)


