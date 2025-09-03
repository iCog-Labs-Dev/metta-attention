;This is custom to AFImportancediffusion needs
(: getTargetNeighborsAFI (-> Atom Atom Atom Bool Atom))
(= (getTargetNeighborsAFI $iset $atom $type $match-subtype)
    (if (== $type UNORDERED_LINK)
        ()
        (let*
            (
                (($link $source $target) $iset)
                ($answer
                    (if (== $link $type)
                        (if (== $source $atom)
                            $target
                            ()
                        )
                        ()
                    )
                )
            )
            $answer
        )
    )
)

(= (getSourceNeighbors $source $type $space)
    (if (isUnorderLink $type)
        ()
        (let*
            (
                ($incomingSet (getAllIncomingSetsForHCA $source $space))
                ($sourceNeighbors (getSourceNeighborRecursively $incomingSet $source $type))
            )
        $sourceNeighbors
        )
    )
)

(= (getSourceNeighborRecursively $incomingSet $source $type)
    (if (== () $incomingSet)
        ()
        (concatTuple ((getSourceNeighbor  (car-atom $incomingSet) $source $type)) (getSourceNeighborRecursively (cdr-atom $incomingSet) $source $type) )
    )
)

(= (getSourceNeighbor $atom $source $type )
    (let ($link $newSource $target) $atom
        (if (== $link $type)
            (if (not (== $newSource $source))
                $newSource
                ()
            )
            ()
        )
    )
)

(= (getTargetNeighbors $source $type $space)
    (if (isUnorderLink $type)
        ()
        (let*
            (
                ($incomingSet (getAllIncomingSetsForHCA $source $space))
                ($sourceNeighbors (getTargetNeighborRecursively $incomingSet $source $type))
            )
        $sourceNeighbors
        )
    )
)

(= (getTargetNeighborRecursively $incomingSet $source $type)
    (if (== () $incomingSet)
        ()
        (concatTuple ((getTargetNeighbor  (car-atom $incomingSet) $source $type)) (getTargetNeighborRecursively (cdr-atom $incomingSet) $source $type) )
    )
)

(= (getTargetNeighbor $atom $source $type )
    (let ($link $newSource $target) $atom
        (if (== $link $type)
            (if (not (== $target $source))
                $target
                ()
            )
            ()
        )
    )
)


(: getAllIncomingSetsForHCA (-> Atom Grounded List))
(= (getAllIncomingSetsForHCA $atom $space)
    (collapse
        (superpose
            (
                (match $space (($type $atom $b) $Value) ($type $atom $b))
                (match $space (($type $b $atom) $Value) ($type $b $atom))
            )
        )
    )
)

; Function: isUnorderLink
; Description: returns true if an is a type of Unorderlink
; Parameters: 
;   $type: An atom that is expected to describe the type of an expression atom
; Returns: True is an atom is an unorderlink and Fasle if it is not
(: isUnorderLink (-> Atom Bool))
(= (isUnorderLink $type)
    (unify (SYMMETRIC_HEBBIAN_LINK SYMMETRIC_INVERSE_HEBBIAN_LINK HEBBIAN_LINK) $type True False)
)
