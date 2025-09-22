
; this function take atoms from atombin space and return atoms found inside the largest bin index
; it uses Max helper function to get the largest bin index then it returns the atom found in that bin index

(: getMaxContent (-> List))
(= (getMaxContent)
    (let $numbers 
        (getBinList (TypeSpace))
        (if (== $numbers ()) 
            ()
            (let $max 
                (max-atom $numbers)
                (getAtomsByBin $max)
            )
        )
    )
)


; this function take atoms from atombin space and return atoms found inside the smallest bin index
; it uses Min helper function to get the smallest bin index then it returns the atom found in that bin index

(: getMinContent (-> List))
(= (getMinContent)
    (let $numbers 
        (getBinList (TypeSpace))
        (if (== $numbers ()) 
            ()
            (let $max 
                (min-atom $numbers)
                (getAtomsByBin $max)
            )
        )
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
