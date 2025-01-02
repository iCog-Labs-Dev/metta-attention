

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

!(bind! &atombin (new-space))

!(add-atom &atombin (1 (a)))
!(add-atom &atombin (2 (d)))
!(add-atom &atombin (3 (c)))
!(add-atom &atombin (17 (s c)))
!(add-atom &atombin (18 (g j)))
!(add-atom &atombin (37 (f h j k)))

; implement insert, remove, size, getRandomatom, 

; Function to insert atom into the space
(: insert-atom (-> Number Atom))
(= (insert-atom $sti $atom)
    (add-atom &atombin ($key $atom))
)
; Function to remove atom from the space
(: remove-atom (-> Number Atom))
(= (remove-atom $sti $atom)
    (remove-atom &atombin ($key $atom))
)

