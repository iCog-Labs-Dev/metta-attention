
!(bind! &atombin (new-space))

!(add-atom &atombin (1 (a)))
!(add-atom &atombin (2 (d)))
!(add-atom &atombin (3 (c)))
!(add-atom &atombin (17 (s c)))
!(add-atom &atombin (18 (g j)))
!(add-atom &atombin (37 (f h j k)))


; this function take atoms from atombin space and return atoms found inside the largest bin index
; it uses Max helper function to get the largest bin index then it returns the atom found in that bin index
(= (getMaxContent) 
    (let* (
        ($numbers (collapse (match &atombin ($y $x) $y)))
        ($max (Max $numbers))
        ($content (match &atombin ($max $x)  $x))
    )
        $content
    )
)
; this function take atoms from atombin space and return atoms found inside the smallest bin index
; it uses Min helper function to get the smallest bin index then it returns the atom found in that bin index
(= (getMinContent)
    (let* (
        ($numbers (collapse (match &atombin ($y $x) $y)))
        ($min (Min $numbers))
        ($content (match &atombin ($min $x)  $x))
    )
        $content
    )
)
