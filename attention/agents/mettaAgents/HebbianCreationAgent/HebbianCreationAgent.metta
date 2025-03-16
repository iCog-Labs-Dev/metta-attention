!(bind! maxLinkNum 0) ; The maximum amount of links that can be created from a single atom
!(bind! localToFarLinks 2) ; Ratio of local links to far links


; Function: HebbianCreationAgent-Run
; Description: This function creates Hebbian links between atoms in the attentional focus.
; It also creates links between atoms in the attentional focus and atoms outside the attentional focus.
; The function removes excess links if the number exceeds maxLinkNum.

(:HebbianCreationAgent-Run (-> empty))
( = (HebbianCreationAgent-Run)
    (if ( == (attentionalFocusSize) 0)
        ("Empty Attentional Focus")
        (let* (($source (getRandomAtomInAF)))
            (if (match $source (ASYMMETRIC_HEBBIAN_LINK $x $y))
                (empty)  ; Change: Instead of checking at line 23, we return empty here to reduce unnecessary function calls.
                (let* (
                    ($sourceAtom (getSourceAtom $source))
                    (remove-atom (attentionalFocus) $source) ; to minimize self connection
                    ($existingAsSourceHS (getTargetNeighbors $sourceAtom ASYMMETRIC_HEBBIAN_LINK True))
                    ($existingAsTarget (getSourceNeighbors $sourceAtom ASYMMETRIC_HEBBIAN_LINK True))
                    ($needToBeSource (setDifference $existingAsSourceHS))
                    ($needToBeTarget (setDifference $existingAsTarget))
                    ($count (size-atom $needToBeTarget))
                    ($farLinks (/ $count localToFarLinks)) ; round by default
                    ($incomingSet (getIncomingSetByType $source ASYMMETRIC_HEBBIAN_LINK))
                    )
                    (
                    (addHebbian $source (superpose $needToBeSource))  ; Change: Used superpose instead of recursion for optimization.
                    (addHebbian $source (superpose $needToBeTarget))
                    (addFromOutSideAF $source $farLinks)
                    (if (> (size-atom $incomingSet) maxLinkNum)
                        (removeLinkRecursively (- (size-atom $incomingSet) maxLinkNum))
                        (empty)
                    )
                    )
                )
            )
        )
    )
)

; Function: getSourceAtom
; Description: Returns the source atom of a link
(:getSourceAtom (-> Atom Atom))
( = (getSourceAtom $source)
    (if (== (size-atom $source) 3) ; if source is a link
        (let* (
            ($sourceAndTarget (cdr-atom $source))
            ($sourceAtom (car-atom $sourceAndTarget))
            )
            $sourceAtom
        )
        $source ; source is just a single atom
    )
)

; Function: removeLinkRecursively
; Description: Removes links from the attentional focus a given number of times
(:removeLinkRecursively (-> Number empty))
( = (removeLinkRecursively $num)
    (if (or (== $num 0) (== 0 (attentionalFocusSize)))
        (empty)
        (let ($randomAtom (getRandomAtomInAF))
            (
                (remove-atom (attentionalFocus) $randomAtom) ; Change: Fixed typo by wrapping attentionalFocus in brackets.
                (removeLinkRecursively (- $num 1))
            )
        )
    )
)

; Function: setDifference
; Description: Returns the atoms that are in the attentional focus but not in the given list
(:setDifference (-> List List))
( = (setDifference $IncomingList)
    (let $atomList (getAtomList)
        (subtraction-atom $atomList $incomingList)
    )
)

; Function: addFromOutSideAF
; Description: Adds Hebbian links from the source atom to atoms outside the attentional focus
(:addFromOutSideAF (-> Atom Number empty))
( = (addFromOutSideAF $source $farLinks)
    (if ( == $farLinks 0 )
        (empty)
        (let ($target (getRandomAtomNotInAF))
            (if (or (== $target ()) (match $target (ASYMMETRIC_HEBBIAN_LINK $x $y)))
                (empty)
                (
                    (addHebbian $source $target)
                    (addFromOutSideAF $source (- $farLinks 1))
                )
            )
        )
    )
)

; Function: addHebbian
; Description: Adds a Hebbian link between two atoms
(:addHebbian (-> Atom Atom empty))
( = (addHebbian $source $target)
    (let ($link (ASYMMETRIC_HEBBIAN_LINK $source $target))
        (
        (add-atom (attentionalFocus) $link)
        (setStv $link (0.5 0.1)) ; Change: Removed createTv function and directly used setStv.
        )
    )
)
