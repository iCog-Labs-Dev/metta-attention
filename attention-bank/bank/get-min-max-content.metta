!(bind! &atombin (new-space))

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
; Calculates the total number of atoms across all bins in &atombin
(: binSize (-> Number))
(= (binSize)
   (let $bins (collapse (match &atombin ($index $contents) $index))
      (if (== $bins ()) 
          0
          (sumSizes $bins)
      )
   )
) 
; Recursively sums the sizes of all bins in a list of bins
(: sumSizes (-> Expression Number))
(= (sumSizes $bins)
   (if(== $bins ())
      0 
      (let $bin (car-atom $bins)
         (let $rest (cdr-atom $bins)
            (if (== $rest ()) 
                 (getSize $bin) 
                 (+ (getSize $bin) (sumSizes $rest))
            )
         )
      )
   )
)