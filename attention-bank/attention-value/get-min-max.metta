; Function: getMaxContent
; Description: this function take atoms from space and find atoms in the largest bin index
; Parameters: $space
; Returns: expression of atoms in largest bin

; (: getMaxContent (-> Grounded Expression))
(= (getMaxContent $space)
    (let $bins 
         (getBinList $space)
         (if (== $bins ()) 
            () 
            (let $max 
                    (max-atom $bins)
                    (getAtomsByBin $max)
            )
        )
    )
)

; Function: getMaxContent
; Description: this function take atoms from space and find atoms in the lowest bin index
; Parameters: $space
; Returns: expression of atoms in lowest bin

; (: getMinContent (-> Grounded Expression))
(= (getMinContent $space)
    (let $bins 
         (getBinList $space)
         (if (== $bins ()) 
            () 
            (let $min 
                    (min-atom $bins)
                    (getAtomsByBin $min)
            )
        )
    )
)

; Function: getSize
; Description: takes a bin number and calculate the size of atoms found in that bin
; Parameters: $binNumber
; Returns: size of atoms

; (: getSize (-> Number Number))
(= (getSize $binNumber)
    (let*(
        ($atoms (getAtomsByBin $binNumber))
        ($size (size-atom $atoms))
    ) 
    $size
    )
)

;Function: binSize
;Description: Calculates the total number of atoms across all bins in typespace space.
;             It retrieves all bin indices and computes the cumulative sum of their sizes.
;Parameters: None.
;Returns: The total number of atoms across all bins.
; (: binSize (-> Number))
(= (binSize)
    (let $x (getAllAtomsWithBins) (size-atom $x))
)
