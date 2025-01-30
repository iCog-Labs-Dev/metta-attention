
; this function take atoms from atombin space and return atoms found inside the largest bin index
; it uses Max helper function to get the largest bin index then it returns the atom found in that bin index
(= (getMaxContent) 
    (let* (
        ($atombin (AtomBin))
        ($numbers (collapse (match $atombin ($y $x) $y)))
        ($max (Max $numbers))
        ($content (match (AtomBin) ($max $x)  $x))
    )
        $content
    )
)
; this function take atoms from atombin space and return atoms found inside the smallest bin index
; it uses Min helper function to get the smallest bin index then it returns the atom found in that bin index
(= (getMinContent)
    (let* (
        ($atombin (AtomBin))
        ($numbers (collapse (match $atombin ($y $x) $y)))
        ($min (Min $numbers))
        ($content (match (AtomBin) ($min $x)  $x))
      )
      $content
    )
)

; this function takes a bin number and return the number of atoms found in that bin
; it used size helper function to count the number of atoms found in the bin
(= (getSize $binNumber)
    (let* (
        ($atoms (match (atombins) ($binNumber $x) $x))
    )
        (size $atoms)
    )
)

; Calculates the total number of atoms across all bins in &atombin
(: binSize (-> Number))
(= (binSize)
   (let* (
      ($atombin (AtomBin))
      ($indices (collapse (match $atombin ($x $y) $x)))
      ($binsSize (sumSizes $indices)) ;cumulative sum of all sizes of bins in atombin
    )
    $binsSize
  )
)

; Recursively sums the sizes of all bins in a list of bins
(: sumSizes (-> Expression Number))
(= (sumSizes $indices)
   (if (== $indices ())
      0
      (let* (
             ($index (car-atom $indices))
             ($rest (cdr-atom $indices))
             ($remainingSize (sumSizes $rest))
            )
        (+ (getSize $index) $remainingSize)
       )
    )
)
