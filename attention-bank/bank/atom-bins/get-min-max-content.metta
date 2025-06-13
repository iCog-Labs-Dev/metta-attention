
; this function take atoms from atombin space and return atoms found inside the largest bin index
; it uses Max helper function to get the largest bin index then it returns the atom found in that bin index
(= (getMaxContent) 
    (let* (
        ($atombin (AtomBin))
        ($numbers (collapse (match $atombin ($y $x) $y)))
        ($max (max-atom $numbers))
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
        ($min (min-atom $numbers))
        ($content (match (AtomBin) ($min $x)  $x))
      )
      $content
    )
)

; this function takes a bin number and return the number of atoms found in that bin
; it used size helper function to count the number of atoms found in the bin
(= (getSize $binNumber)
    (let* (
        ($atoms (match (AtomBin) ($binNumber $x) $x))
    )
        (size-atom $atoms)
    )
)

;Function: binSize
;Description: Calculates the total number of atoms across all bins in &atombin space.
;             It retrieves all bin indices and computes the cumulative sum of their sizes.
;Parameters: None.
;Returns: The total number of atoms across all bins.
(: binSize (-> Number))
(= (binSize)
   (let* (
      ($atombin (AtomBin))
      ($indices (collapse (match $atombin ($x $y) $x)))
      ($binsSize (sumSizes $indices)) 
    )
    $binsSize
  )
)

;Function: sumSizes
;Description: Recursively computes the total number of atoms across all bins in a given list of bin indices.
;             It iterates through the list of indices, retrieves the size of each bin, and sums them up.
;Parameters:
;          $indices: A list of bin indices whose sizes should be summed.
;Returns: The cumulative size of all bins in the given list.
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
