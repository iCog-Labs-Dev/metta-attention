


!(bind! maxLinkNum 0) ; The maximum amount of links that can be created from a single atom
!(bind! localToFarLinks 2) ;Ratio of local links to far links



;Function: HebbianCreationAgent-Run
;Description: This function creates hebbian links between atoms in the attentional focus. It also creates links between atoms in the attentional focus and atoms outside the attentional focus. The number of links created between atoms in the attentional focus and atoms outside the attentional focus is determined by the localToFarLinks ratio. The function also removes links from the attentional focus if the number of incoming links exceeds the maxLinkNum.
;Parameters: None.
;Returns: empty
(:HebbianCreationAgent-Run(-> empty))
( = (HebbianCreationAgent-Run)
    ; if the attentional focus is empty no work is done
    (if ( == (attentionalFocusSize)  0)
        ("Empty Attentional Focus")
        (let $source (getRandomAtomInAF)
            (if  (==  HEBBIAN_LINK (car-atom $source))
                ("source is a hebbian link") ; if already hebbian_link nothing is done
                (
                    ( let* (
                        ($sourceAtom (getSourceAtom $source))
                        ( remove-atom (attentionalFocus) $source) ; to minimize self connection
                        ($existingAsSourceHS  (getTargetNeighbors $sourceAtom ASYMMETRIC_HEBBIAN_LINK True))
                        ($existingAsTarget  (getSourceNeighbors $sourceAtom ASYMMETRIC_HEBBIAN_LINK True))
                        ($needToBeSource ( setDifference (attentionalFocus) $existingAsSourceHS) )
                        ($needToBeTarget  (setDifference (attentionalFocus) $existingAsTarget))
                        ($count (size-atom $needToBeTarget ))
                        ($farLinks (/ $count localToFarLinks )) ;round by default
                        ( $incomingSet (getIncomingSetByType $source ASYMMETRIC_HEBBIAN_LINK)) ;should I add other types of hebbian links?
                        )
                        (
                        (addHebbian $source (superpose $needToBeSource)) ;add  links to all atoms that need to be source
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

;Function: getSourceAtom
;Description: returns the source atom of a link 
;Parameters: Atom
;Returns: Atom
(:getSourceAtom(-> Atom Atom))
( = (getSourceAtom $source)
    (if (== (size-atom $source) 3) ;if source is a link
        (let* (
            ($sourceAndTarget (cdr-atom $source))
            ($sourceAtom (car-atom $sourceAndTarget))
            )
            $sourceAtom
        )
        ;else
         $source ;source is just a single atom
    )
)



;Function: removeLinkRecursively
;Description: removes links from the attentional focus a given number of times 
;Parameters: $number- Number of times to remove links
;Returns: empty

(:removeLinkRecursively(-> Number empty))
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
;Function: setDifference
;Description: returns the atoms that are in the attentional focus but not in the list
;Parameters: $incomingList- List of atoms
;Returns: List of atoms
(:setDifference (-> List List))
( = (setDifference  $IncomingList)
    (let $atomList (getAtomList)
        (subtraction-atom $atomList $incomingList )
    )
)




;Function: addFromOutSideAF
;Description: adds hebbian links from the source atom to atoms outside the attentional focus
;Parameters: $source- Atom, $farLinks- Number of links to be created
;Returns: empty
(:addFromOutSideAF(-> Atom Number empty))
( = (addFromOutSideAF  $source $farLinks)
    (if ( == $farLinks 0 )
        (empty)
        (let ($target (getRandomAtomNotInAF))
            (if ( (or (== () $target) ( == (car-atom $target) HEBBIAN_LINK)))
                (empty)
                (
                    (if atomIsInAF (ASYMMETRIC_HEBBIAN_LINK $source $target) ;If the link exists dont add it again 
                        (empty)
                        (
                            (addHebbian $source $target )
                            (addFromOutSideAF $source (- $farLinks 1))
                        )
                    )
                )
            )
        )
    )
)



;Function: addHebbian
;Description: adds a hebbian link between two atoms
;Parameters: $source- Atom, $target- Atom
;Returns: empty
(: addHebbian (-> Atom Atom empty ))
( = (addHebbian $source $target)
    (let ($link (ASYMMETRIC_HEBBIAN_LINK $source $target) )
        (
        (add-atom (attentionalFocus) $link)
        (setStv $link 0.5 0.1)
        )
    )

)
