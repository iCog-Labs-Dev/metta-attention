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

(= (localToFarLinks) 1000.0)


; (: HebbianCreationAgent-Run(-> Grounded empty))
(= (HebbianCreationAgent-Run $space)
    ; if the attentional focus is empty no work is done
    (let $afAtoms (getAfAtoms)
        (if (== (size-atom $afAtoms) 0)
        ()
         (let* 
            (
                ($source (superpose $afAtoms))
                ($existingAsSourceHS  (getTargetNeighbors $source ASYMMETRIC_HEBBIAN_LINK $space)) ;;need to check if we should use source or sourceAtom
                ($needToBeTarget  (subtraction-atom $afAtoms $existingAsSourceHS))
                ($count (size-atom $needToBeTarget))
                ($farLinks (round-math (/ $count (localToFarLinks))) ) ;round by default
            )
            (
                (addFromOutSideAF $source $farLinks $afAtoms)
                (let $target (superpose $needToBeTarget)
                    (if (not (== $target $source)) 
                        (addHebbian $target $source)
                        (empty)
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
( = (removeLinkRecursively $num $sizeaf $afAtoms)
    (if ( or (== $num 0) (== 0 $sizeaf))
        ()
        (let*
            (
                ($randomAtom (getRandomAtomInAF $afAtoms))
                ($incomingSet (getIncomingSetByType $randomAtom HEBBIAN_LINK)) 
                ; ($p (println! (incoming $incomingSet)))
                ($x (remove-atom &typespace (car-atom $incomingSet)))
            )
            (removeLinkRecursively (- $num 1) (size-atom (getAfAtoms)) $afAtoms)
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
( = (addFromOutSideAF  $source $farLinks $afAtoms)
    (if ( == $farLinks 0)
        ()
         (let $target (generateRandom $farLinks $afAtoms)
            (if (== () $target)
                ()
                (if (and (not (== (getStv (ASYMMETRIC_HEBBIAN_LINK $source $target)) %Undefined%)) (== $target $source)) ;If the link exists dont add it again 
                    ()
                    (addHebbian $source $target)
                )
            )
        )
    )
)

(= (generateRandom $farLinks $afAtoms)
    (if (<= $farLinks 0)
        ()
        (superpose ((getRandomAtomNotInAF $afAtoms) (generateRandom (- $farLinks 1) $afAtoms)))
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
