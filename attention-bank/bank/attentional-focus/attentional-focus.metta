(= (afAtoms)
    (let*
        (
        ($afSize (getAttentionParam MAX_AF_SIZE))
        ($allAtoms (getAllAtomsWithBins))
        ) ( if (not (< $afSize (size-atom $allAtoms)))
                $allAtoms
                (afAtomsHelper $afSize)
    ))
)

(= (afAtomsHelper $size)
    (let* (
        ($binList (sortDecend (getBinList (TypeSpace))))
        (($min $atomsList) (minBin  $binList $size ()));getting the last bin and atoms in above the min bin
        ($remainSize (- $size (size-atom $atomsList))) ;calculate remaining number of atoms
        ($minAtomsSti (let $m (getAtomsByBin $min) (collapse (unique (getSti (superpose $m))))))
        ($sortedMinList (sortDecend $minAtomsSti))
        ($lastAtoms (getNatoms $sortedMinList $remainSize)); getting the first $size number of atoms
        ) (union-atom $atomsList $lastAtoms)
        )
)

(= (minBin $binList $size $acc)
        (if (== $binList ())
            (-1 $acc)
        (let* (
                (($bin $tail) (decons-atom $binList))
                ($atoms (getAtomsByBin $bin))
                ($atomsList (union-atom $atoms $acc))
                )
            (if (< $size (size-atom $atomsList))
                ($bin $acc)
                (minBin $tail $size $atomsList)
            )
    )   )
)




(= (getRandomAtomNotInAF)
    (let* ( ($afAtoms (afAtoms))
            ($min (getAllMinSTI $afAtoms))
            ($atoms (getAllAtomsWithBins))
            ($filtered (filterContents $atoms 0 (- $min 0.0000001)))
    )   (getRandHelp $filtered)
    )
)

(= (getRandHelp $list)
    (if (== $list ())
        ()
        (let* (
            ($rand (random-int 0 (size-atom $list)))
            ($atom (index-atom $list $rand)))
        (if (== $atom ())
            (getRandHelp $list)
            $atom
        )
    )
    )
    
)
(= (getRandInAf)
    (let $atoms 
            (afAtoms)
            (if (== (size-atom $atoms) 0)
                ()
            (let $rand (random-int 0 (size-atom $atoms))
            (index-atom $atoms $rand)))
    
    )
)

(= (isAtomInAf $atom)
    (let $x (getAllMinSTI (afAtoms)) (< (getSti $x) (getSti $atom)))
)

(= (getIncomingByType $atom $type)
    (let $list (afAtoms)
    (collapse 
    (let*
        (
        ($x (superpose $list))
        ($y (unify ($type $elem $atom) $x ($type $elem $atom) ()))
        ($l (unify ($type $atom $z) $x ($type $atom $z) ()))
        ) 
        (if (and (== $y ()) (== $l ())) Empty (union-atom $y $l))
         
    ))
    )
)

(= (getIncoming $atom)
    (let $list (afAtoms)
    (collapse 
        (let*
            (
            ($x (superpose $list))
            ($y (unify ($type $elem $atom) $x ($type $elem $atom) ()))
            ($l (unify ($type $atom $z) $x ($type $atom $z) ()))
            ) 
            (if (and (== $y ()) (== $l ())) Empty (union-atom $y $l))
        )
    ))
)