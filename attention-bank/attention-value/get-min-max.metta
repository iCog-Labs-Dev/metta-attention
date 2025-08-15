
; this function take atoms from typespace and return atoms found inside the largest bin index
; it uses Max helper function to get the largest bin index then it returns the atom found in that bin index

(: getMaxContent (-> Expression))
(= (getMaxContent)
    (let* (
        ($atoms (getAllAtomsWithBins))
        ($bins (collapse (getBin (superpose $atoms))))
        
        )
    (if (== $atoms ()) $atoms (
        let* (
        ($max (max-atom $bins))
        ($content (getAtomsByBin $max))
        )

        $content
    )
    )
    )
)


; this function take atoms from typespace space and return atoms found inside the smallest bin index

(: getMinContent (-> Expression))
(= (getMinContent)
    (let* (
        ($atoms (getAllAtomsWithBins))
        ($bins (collapse (getBin (superpose $atoms))))
        
        )
    (if (== $atoms ()) $atoms (
        let* (
        ($max (min-atom $bins))
        ($content (getAtomsByBin $max))
        )

        $content
    )
    )
    )
)
; this function takes a bin number and return the number of atoms found in that bin
(: getSize (-> Number Number))
(= (getSize $binNumber)
    (let 
        $atoms 
        (getAtomsByBin $binNumber)
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
      ($typespace (typespace))
      ($indices ())
      ($binsSize (getAllAtomsWithBins))
    )
    (size-atom $binsSize)
  )
)
