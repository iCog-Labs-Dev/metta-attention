
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

; this function takes a bin number and return the number of atoms found in that bin
; it used length helper function to count the number of atoms found in the bin
(= (getSize $binNumber)
    (let* (
        ($atoms (match &atombin ($binNumber $x) $x))
    )
        (length $atoms)
    )
)
