!(bind! maxLinkNum 300) ; The maximum amount of links that can be created from a single atom
!(bind! localToFarLinks 10) ;Ratio of local links to far links

;Function: HebbianCreationAgent-Run
;Description: This function creates hebbian links between atoms in the attentional focus. It also creates links between atoms in the attentional focus and atoms outside the attentional focus. The number of links created between atoms in the attentional focus and atoms outside the attentional focus is determined by the localToFarLinks ratio. The function also removes links from the attentional focus if the number of incoming links exceeds the maxLinkNum.
;Parameters: None.
;Returns: empty

(: HebbianCreationAgent-Run(-> Grounded Grounded Grounded empty))
(= (HebbianCreationAgent-Run $space $space2 $space3)
    ; if the attentional focus is empty no work is done
    (if ( == (attentionalFocusSize)  0)
        ("Empty Attentional Focus")
        (let $source 
                    (let*
                        (
                            ($afAtoms (getNewAtomInAVList))
                            ($rm (collapse (removeAtomFromNewAVList (superpose $afAtoms) $space3)))
                        )
                            (superpose $afAtoms)
                    ) 
            (if  (unify (get-metatype $source) Expression (==  HEBBIAN_LINK (car-atom $source)) False)
                ("source is a hebbian link") ; if already hebbian_link nothing is done
                (
                    (let*
                        (
                            ($removeHebbian (let $temp (removeHebbianLinksfromAF (collapse (match $space2 (HEBBIAN_LINK $a $b) (HEBBIAN_LINK $a $b)))) ()))
                            ($removeSource
                                (let $temp2 
                                    (remove-atom (attentionalFocus) $source) ())) ; to minimize self connection I am unsure if this should exist
                            ($existingAsSourceHS  (getTargetNeighbors $source ASYMMETRIC_HEBBIAN_LINK $space)) ;;need to check if we should use source or sourceAtom
                            ($existingAsTarget  (getSourceNeighbors $source ASYMMETRIC_HEBBIAN_LINK $space))
                            ($needToBeSource ( setDifference $existingAsSourceHS) )
                            ($needToBeTarget  (setDifference $existingAsTarget))
                            ($count (size-atom $needToBeTarget ))
                            ($_ (collapse (addHebbian (superpose $needToBeSource) $source )))
                            ($__ (collapse (addHebbian $source (superpose $needToBeTarget))))
                            ($farLinks (/ $count localToFarLinks )) ;round by default
                            ($___ (addFromOutSideAF $source $farLinks))
                            ($incomingSet (getIncomingSetByType $source HEBBIAN_LINK)) ;should I add other types of hebbian links?
                        )
                        (
                            (if (> (size-atom $incomingSet) maxLinkNum )
                                (removeLinkRecursively (- (size-atom $incomingSet) maxLinkNum))
                                ()
                            )
                            (updateAttentionalFocus $source False)
                        )
                    )
                )
            )
        )
    )
)

;;Function: removeHebbianLinksfromAF
;;Description: removes Hebbian Links from the AF
;;Parameters: Atom
;;Return: Empty

; (: removeHebbianLinksfromAF (-> Link Empty))
(= (removeHebbianLinksfromAF $links)
    (if (== $links ())
        ()
        (let $superposed (superpose $links) 
            (remove-atom (attentionalFocus) $superposed))
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

(:removeLinkRecursively(-> Number Empty))
( = (removeLinkRecursively $num)
    (if ( or (== $num 0) (== 0 (attentionalFocusSize)))
        ()
        (let*
            (
                ($randomAtom (getRandomAtomInAF))
                ($x (let $temp (remove-atom (attentionalFocus) $randomAtom) $temp))
            )
            (removeLinkRecursively (- $num 1))
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
        (subtraction-atom $atomList $IncomingList )
    )
)

;Function: addFromOutSideAF
;Description: adds hebbian links from the source atom to atoms outside the attentional focus
;Parameters: $source- Atom, $farLinks- Number of links to be created
;Returns: empty

(:addFromOutSideAF(-> Atom Number Empty))
( = (addFromOutSideAF  $source $farLinks)
    (if ( == $farLinks 0 )
        ()
        (let $target (getRandomAtomNotInAF)
            (if (== %Undefined% $target)
                ()
                (
                    (if (== (get-metatype $target) Expression)
                        (if (== (car-atom $target) HEBBIAN_LINK)
                            ()
                            (if (atomIsInAF (ASYMMETRIC_HEBBIAN_LINK $source $target)) ;If the link exists dont add it again 
                                ()
                                (
                                    (addHebbian $source $target )
                                    (addFromOutSideAF $source (- $farLinks 1))
                                )
                            )
                        )
                        (if (atomIsInAF (ASYMMETRIC_HEBBIAN_LINK $source $target)) ;If the link exists dont add it again 
                            ()
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
)

;Function: addHebbian
;Description: adds a hebbian link between two atoms
;Parameters: $source- Atom, $target- Atom
;Returns: empty

(: addHebbian (-> Atom Atom Empty))
(= (addHebbian $source $target)
    (let $link (ASYMMETRIC_HEBBIAN_LINK $source $target)
        (setStv $link (0.5 0.1))
    )
)

(= (removeAtomFromNewAVList $atom $space)
    (remove-atom $space $atom)
)
