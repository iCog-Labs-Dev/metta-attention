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

(: getTargetNeighbors (-> Atom Atom Bool Atom))
(= (getTargetNeighbors $atom $type $match-subtype)
    (if (== $type UNORDERED_LINK)
        ()
        (let*
            (
                (($link $source $target) (let $tmp (getIncomingSet $atom $type) (superpose $tmp)))
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

(: getSourceNeighbors (-> Atom Atom Bool Atom))
(= (getSourceNeighbors $atom $type $match-subtype)
    (if (== $type UNORDERED_LINK)
        ()
        (let*
            (
                (($link $source $target) (let $tmp (getIncomingSet $atom $type) (superpose $tmp)))
                ($answer
                    (if (== $link $type)
                        (if (not (== $source $atom))
                            $source
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