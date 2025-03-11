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

( = (getTargetNeighbors $atom $type $matchSubType)
     (collapse (getTargetNeighborsHelper $atom $type $matchSubType))
     (collapse (getTargetNeighborsHelper $atom $type $matchSubType))
)

( = (getSourceNeighbors $atom $type $matchSubType)
    (let $ans (collapse (getSourceNeighborsHelper $atom $type $matchSubType))
        $ans
    )

)
(: getTargetNeighborsHelper (-> Atom Atom Bool Atom))
(= (getTargetNeighborsHelper $atom $type $match-subtype)
    (if (== $type UNORDERED_LINK)
        ()
        (let*
            (
                (($link $source $target) (let $tmp (getIncomingSet $atom $type) (superpose $tmp)))
                ($answer
                    (if (== $link $type)
                        (if (== $source $atom)
                            $target
                            (empty)
                        )
                        (empty)
                    )
                )
            )
            $answer
        )
    )
)

(: getSourceNeighborsHelper (-> Atom Atom Bool Atom))
(= (getSourceNeighborsHelper $atom $type $match-subtype)
    (if (== $type UNORDERED_LINK)
        ()
        (let*
            (
                (($link $source $target) (let $tmp (getIncomingSet $atom $type) (superpose $tmp)))
                ( $answer
                    (if (== $link $type)
                        (if (not (== $source $atom))
                            $source
                            (empty)
                        )
                        (empty)
                    )
                )
            )
             $answer
        )
    )
)