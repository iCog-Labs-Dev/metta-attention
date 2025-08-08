
; this function take atoms from typespace and return atoms found inside the largest bin index
; it uses Max helper function to get the largest bin index then it returns the atom found in that bin index

(: getMaxContent (-> List))
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

(: getMinContent (-> List))
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

;setBin accepts a pattern and bin number and sets bin number
; mainly for testing purpose
(: setBin (-> Atom Number Expression))
(= (setBin $pattern $Bin)
    (let $res (if (== (getValueType $pattern) %Undefined%)
                (atom-not-exist)   
                   (let* 
                        (
                           ($stv (getStv $pattern))
                           ($value (match (typespace) ($pattern $_) ($pattern $_)))
                           ($av (getAv $pattern))
                           (() (remove-atom (typespace) $value))
                        )
                      (if (== $stv %Undefined%)
                          (add-atom (typespace) ($pattern ($av (Bin $Bin)) ))
                          (add-atom (typespace) ($pattern ($stv $av (Bin $Bin)) )))
                   )
                )
                ()
           )
)
