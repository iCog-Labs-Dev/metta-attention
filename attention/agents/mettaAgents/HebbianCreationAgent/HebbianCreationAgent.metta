


!(bind! maxLinkNum 0)
!(bind! localToFarLinks 1) 




( = (HebbianCreationAgent-Run)
    ; if the attentional focus is empty no work is done
    (if ( == (attentionalFocusSize)  0)
        ("Empty Attentional Focus")
        ( let* (($source (getRandomAtomInAF)) 
                ($handleSet (getAtomList))
                (remove-atom (attentionalFocus) $source) ; to minimize self connection
                ($sourceAtom (car-atom (cdr-atom $source)))
                ($existingAsSourceHS (collapse (getSourceNeighbors $sourceAtom ASYMMETRIC_HEBBIAN_LINK True)))
                ($existingAsTarget (collapse (getTargetNeighbors $sourceAtom ASYMMETRIC_HEBBIAN_LINK True)))
                ($needToBeSource (getNeedToBeSource $existingAsSourceHS))
                ($needToBeTarget getNeedToBeTarget  $existingAsTarget)
        )
            ( if ( (or ( ( > (size-atom $sourceAtom) 1 ) (==  HEBBIAN_LINK (car-atom ($sourceAtom))) )))
                (empty) ; if already hebbian_link nothing is done
                ; else
                    (
                    (addHebbianSourceRecursively $source $needToBeSource )
                    (addHebbianTargetRecursively $source $needToBeTarget )
                    (addFromOutSideAF $source localToFarLinks)
                    ( $incomingSet (incomingHebbianLinks $source) ) ;add let here 
                    (if (> (size-atom $incomingSet) maxLinkNum ) 
                        (removeLinkRecursively (- (size-atom incomingSet) maxLinkNum))
                        ()
                    )
                    )
            )
    )    )
)

( = (removeLinkRecursively $num)
    (if ( == $num 0)
        (empty)
        (let ($randomAtom (getRandomAtomInAf))
            (
                (remove-atom attentionalFocus $randomAtom)
                (removeLinkRecursively (- $num 1))

            )
        )


    )
)




( = (getNeedToBeSource $list)
    (setDifference (attentionalFocus) $list)


)

( = (getNeedToBeTarget  $list)

    (setDifference  (attentionalFocus) $list)
)


; return the atoms that are in the attentional focus but not in the list 
( = (setDifference  $IncomingList)
   
    (let $atomList getAtomList 
        (subtraction-atom $atomList $incomingList )
    )
)



( = (addHebbianSourceRecursively $source  $needToBeSource)
    (if ( == $needToBeSource ())
        (empty)
        (
            (addHebbian $source (car-atom $needToBeSource))
            (addHebbianSourceRecursively $source (cdr-atom $needToBeSource))

        )
    )

)

( = (addHebbianTargetRecursively $source $needToBeTarget)
    (if (== $needToBeTarget ())
    (empty)
    (addHebbian $source (car-atom $needToBeTarget)
    (addHebbianTargetRecursively $source (cdr-atom $needToBeTarget))
    )
    )

)





( = (addFromOutSideAF  $source $localToFarLinks)
    (if ( == $localToFarLinks 0 )
        ()
        (let ($target getRandomAtomNotInAF)
            (if ( == (car-atom $target) ASYMMETRIC_HEBBIAN_LINK)
                (addHebbian $source $target )
                 ()
            )
        )
    )

)


( = (incomingHebbianLinks $source )
    (let $atomList (getAtomList)
        (filterHibbianLinks $atomList)

    )


)



(= (filterHebbianLinks $list)
    (if (== $list ())
        ()  ; Base case: return empty list if input is empty
        (let (($head (car-atom $list))
              ($tail (cdr-atom $list)))
            (if (match &attentionalFocus (ASYMMETRIC_HEBBIAN_LINK $source $target) $source) ;this will return non-deterministic many values right? 
                ( (list $source $target) (filterHebbianLinks $tail)) ; Keep valid links. use concat tuple
                (filterHebbianLinks $tail)  ; Skip invalid links
            )
        )
    )
)

(: addHebbian (-> Atom Atom empty ))
( = (addHebbian $source $target)
    (let ($link (ASYMMETRIC_HEBBIAN_LINK $source $target) )
        (
        (addLink $link)
        (createTv $link 0.5 0.1)

        )
    )

)

( = (addLink $link)
    (add-atom (attentionalFocus) $atom)
)

( = (createTv $link $v1 $v2)
    (setStv $link $v1 $v2 )

)
