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

(= (getTargetNeighbors $target $type $space)
    (collapse (match $space 
        (($type $x $target) $value) 
        (filterTarget ($type $x $target))
    ))
)

(= (filterTarget $link)
    (let ($type $x $target)
        $link
        (if (== $x $target)
            (empty)
            $x
        )
    )
)
