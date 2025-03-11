


!(bind! maxLinkNum 0)
!(bind! localToFarLinks 2) ;This is to be fetched 




( = (HebbianCreationAgent-Run)
    ; if the attentional focus is empty no work is done
    (if ( == (attentionalFocusSize)  0)
        ("Empty Attentional Focus")
        (let $source (getRandomAtomInAF)
            (if  (==  HEBBIAN_LINK (car-atom $source))
                (empty) ; if already hebbian_link nothing is done
                (
                    ( let* (

                        ($handleSet (getAtomList))
                        (remove-atom (attentionalFocus) $source) ; to minimize self connection
                        ($sourceAndTarget (cdr-atom $source))
                        ($sourceAtom (car-atom $sourceAndTarget))
                        ($existingAsSourceHS (collapse (getTargetNeighbors $sourceAtom ASYMMETRIC_HEBBIAN_LINK True)))
                        ($existingAsTarget (collapse (getSourceNeighbors $sourceAtom ASYMMETRIC_HEBBIAN_LINK True)))
                        ($needToBeSource ( setDifference (attentionalFocus) $existingAsSourceHS) )
                        ($needToBeTarget  (setDifference (attentionalFocus) $existingAsTarget))
                        ($count (size-atom $needToBeTarget ))
                        ($farLinks (/ $count localToFarLinks ))
                        ( $incomingSet (incomingHebbianLinks $source))
                        )

                        (
                        (addHebbian $source (superpose $needToBeSource))
                        (addHebbian $source (superpose $needToBeTarget))
                        (addFromOutSideAF $source $farLinks)
                        (if (> (size-atom $incomingSet) maxLinkNum )
                            (removeLinkRecursively (- (size-atom $incomingSet) maxLinkNum))
                            (empty)
                        )
                        )
                    )
                )
            )
        )
    )
)


( = (removeLinkRecursively $num)
    (if ( (or (== $num 0) (== 0 (attentionalFocusSize))))
        (empty)
        (let ($randomAtom (getRandomAtomInAf))
            (
                (remove-atom (attentionalFocus) $randomAtom)
                (removeLinkRecursively (- $num 1))

            )
        )
        )
)






; return the atoms that are in the attentional focus but not in the list 
( = (setDifference  $IncomingList)
    (let $atomList (getAtomList)
        (subtraction-atom $atomList $incomingList )
    )
)






( = (addFromOutSideAF  $source $farLinks)
    (if ( == $farLinks 0 )
        (empty)
        (let ($target getRandomAtomNotInAF)
            (if ( (or (== () $target) ( == (car-atom $target) HEBBIAN_LINK)))
                (empty)
                (
                    (if atomIsInAF (ASYMMETRIC_HEBBIAN_LINK $source $target) ;If the link exists dont add it again 
                        (empty)
                        (
                            (addHebbian $source $target )
                        )
                    )
                )
            )
        )
    )
)





(= (incomingHebbianLinks $source)
    (let* (
        ($hebbianLinkType (getIncomingSetByType $source  HEBBIAN_LINK ))
        ($asymmetricHebbianLinkType (getIncomingSetByType $source ASYMMETRIC_HEBBIAN_LINK) )
        )
        (
            (concatTuple $hebbianLinkType $asymmetricHebbianLinkType)
        )
    )
)

(: addHebbian (-> Atom Atom empty ))
( = (addHebbian $source $target)
    (let ($link (ASYMMETRIC_HEBBIAN_LINK $source $target) )
        (
        (add-atom (attentionalFocus) $link)
        (setStv $link 0.5 0.1)
        )
    )

)
