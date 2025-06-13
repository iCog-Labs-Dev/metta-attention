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
    (if (== $type UNORDERED_LINK)
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
    (if (== $type UNORDERED_LINK)
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
                (match $space (: ($type $atom $b) $Value) ($type $atom $b))
                (match $space (: ($type $b $atom) $Value) ($type $b $atom))
            )
        )
    )
)