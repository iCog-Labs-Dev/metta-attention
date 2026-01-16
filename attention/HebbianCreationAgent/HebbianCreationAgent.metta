; !(bind! localToFarLinks 10) ;Ratio of local links to far links

;Function: HebbianCreationAgent-Run
;Description: This function creates hebbian links between atoms in the attentional
;   focus. It also creates links between atoms in the attentional focus and 
;   atoms outside the attentional focus. 
;   The number of links created between atoms in the attentional focus and atoms 
;   outside the attentional focus is determined by the localToFarLinks ratio. 
;   The function also removes links from the attentional focus if the number of 
;   incoming links exceeds the maxLinkNum.
;Parameters:
;   $space: resolves to the typespace where all atoms are stored.
;   $space2: resolves to attentionalFocus where atoms with hight STI are stored
;   $space3: resolves to newAtomInAV where atoms that are new to attentionalFocus are stored
;Returns: empty

(= (localToFarLinks) 10.0)


; (: HebbianCreationAgent-Run(-> Grounded empty))
(= (HebbianCreationAgent-Run $space)
    ; if the attentional focus is empty no work is done
    (let $afAtoms (getAfAtoms)
        (if (== (size-atom $afAtoms)  0.0)
        ()
         (let* (
            ($source (superpose $afAtoms))
            ($flag (if (== (get-metatype $source) Expression) (== HEBBIAN_LINK (car-atom $source)) False)))
            (if  $flag 
                    () ; if already hebbian_link nothing is done
                    (let*
                        (
                            ($existingAsSourceHS  (getTargetNeighbors $source ASYMMETRIC_HEBBIAN_LINK $space)) ;;need to check if we should use source or sourceAtom
                            ($needToBeTarget  (subtraction-atom $afAtoms $existingAsSourceHS))
                            ($count (size-atom $needToBeTarget))
                            ($farLinks (py-call (round (/ $count (localToFarLinks) )))) ;round by default
                            ; ($_ (println! (running for atom $source  $farLinks)))
                            ($incomingSet (getIncomingSetByType $source HEBBIAN_LINK)) ;should I add other types of hebbian links?
                            ($maxLinkNum (getAttentionParam MAX_LINK_NUM))
                        )
                        (
                            (collapse 
                                (let $target (superpose $needToBeTarget)
                                        (if (not (== $target $source)) 
                                            (addHebbian $target $source)
                                            ()
                                        )
                                ) 
                            )
                            (addFromOutSideAF $source $farLinks)
                            ; (if (> (size-atom $incomingSet) $maxLinkNum )
                            ;     (removeLinkRecursively (- (size-atom $incomingSet) $maxLinkNum) (size-atom $afAtoms))
                            ;     ()
                            ; )
                        )
                    )
                
            )
        )
    ))
)

;Function: getSourceAtom
;Description: returns the source atom of a link
;Parameters: Atom
;Returns: Atom

; (:getSourceAtom(-> Atom Atom))
( = (getSourceAtom $source)
    (if (== (size-atom $source) 3.0) ;if source is a link
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

; (: removeLinkRecursively (-> Number Expression))
( = (removeLinkRecursively $num $sizeaf)
    (if ( or (== $num 0) (== 0 $sizeaf))
        ()
        (let*
            (
                ($randomAtom (getRandomAtomInAF))
                ($incomingSet (getIncomingSetByType $randomAtom HEBBIAN_LINK)) 
                ; ($p (println! (incoming $incomingSet)))
                ($x (remove-atom &typespace (car-atom $incomingSet)))
            )
            (removeLinkRecursively (- $num 1) (size-atom (getAfAtoms)))
        )
    )
)

; return the atoms that are in the attentional focus but not in the list 
;Function: setDifference
;Description: returns the atoms that are in the attentional focus but not in the list
;Parameters: $incomingList- List of atoms
;Returns: List of atoms

; (:setDifference (-> List List))
( = (setDifference  $IncomingList)
    (let $atomList (getAfAtoms)
        (subtraction-atom $atomList $IncomingList )
    )
)

;Function: addFromOutSideAF
;Description: adds hebbian links from the source atom to atoms outside the attentional focus
;Parameters: $source- Atom, $farLinks- Number of links to be created
;Returns: empty

; (:addFromOutSideAF(-> Atom Number Empty))
( = (addFromOutSideAF  $source $farLinks)
    (if ( == $farLinks 0)
        ()
        (let $target (getRandomAtomNotInAF)
            (if (== () $target)
                ()
                (
                    (if (== (get-metatype $target) Expression)
                        (if (== (car-atom $target) HEBBIAN_LINK)
                            ()
                            (if (and (not (== (getStv (ASYMMETRIC_HEBBIAN_LINK $source $target)) %Undefined%)) (== $target $source)) ;If the link exists dont add it again 
                                ()
                                (
                                    ; ($insaddF (println! (calling add hebbian it $target is expression, not HEBBIAN_LINK and has stv $source)))
                                    (addHebbian $source $target )
                                    (addFromOutSideAF $source (- $farLinks 1))
                                )
                            )
                        )
                        (if  (and (not (== (getStv (ASYMMETRIC_HEBBIAN_LINK $source $target)) %Undefined%)) (== $target $source)) ;If the link exists dont add it again 
                            ()
                            (
                                ; ($insadF (println! (calling add hebbian it $target is atom, and has stv $source )))
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

; (: addHebbian (-> Atom Atom Empty))
(= (addHebbian $source $target)
    (let*(
        
        ($link (ASYMMETRIC_HEBBIAN_LINK $source $target))
        ; ($crlink (println! ($link created)))
    ) 
        (setStv $link (0.5 0.1))
    )
)

(= (removeAtomFromNewAVList $atom $space)
    (remove-atom $space $atom)
)
