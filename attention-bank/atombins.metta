
; load this atoms into specif space

!(bind! &space (new-space))

!(add-atom &space (1 (a)))
!(add-atom &space (2 (d)))
!(add-atom &space (3 (c)))
!(add-atom &space (17 (s c)))
!(add-atom &space (18 (g j)))
!(add-atom &space (37 (f h j k)))

; implement insert, remove, size, getRandomatom, 

; Function to insert atom into the space
(: insert-atom (-> Number Atom))
(= (insert-atom $sti $atom)
    (add-atom &space ($key $atom))
)
; Function to remove atom from the space
(: remove-atom (-> Number Atom))
(= (remove-atom $sti $atom)
    (remove-atom &space ($key $atom))
)

