; this function take atoms from space and return atoms found inside the largest bin index

(: getMaxContent (-> Grounded Expression))
(= (getMaxContent $space)
    (let $bins 
         (collapse (match $space ($patt ($val (Bin $binNumber))) $binNumber))
         (if (== $bins ()) 
            () 
            (let $max 
                    (max-atom $bins)
                    (getAtomsByBin $max)
            )
        )
    )
)


; this function take atoms from typespace space and return atoms found inside the smallest bin index

(: getMinContent (-> Grounded Expression))
(= (getMinContent $space)
    (let $bins 
         (collapse (unique (match $space ($patt ($val (Bin $binNumber))) $binNumber)))
         (if (== $bins ()) 
            () 
            (let $min 
                    (min-atom $bins)
                    (getAtomsByBin $min)
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
;Description: Calculates the total number of atoms across all bins in typespace space.
;             It retrieves all bin indices and computes the cumulative sum of their sizes.
;Parameters: None.
;Returns: The total number of atoms across all bins.
(: binSize (-> Number))
(= (binSize)
    (let $x (getAllAtomsWithBins) (size-atom $x))
)