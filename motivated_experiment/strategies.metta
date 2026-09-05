(= (similarityNeighbor (similarityLink $x $y)) $x)


; --------------------------------------------------
; Community discovery and ranking
; --------------------------------------------------

(= (communityModules)
    (identifyAllHebbianModules)
)

(= (communityScore $module)
    (size-atom (intersection-atom $module (getAfAtoms)))
)

(= (sortedCommunities)
    (sortAtomsDescending (communityModules) communityScore)
)

(= (bestCommunity)
    (let $communities (sortedCommunities)
        (if (== $communities ())
            ()
            (car-atom $communities)
        )
    )
)

(= (leastCommunity)
    (let $communities (reverseExpr (sortedCommunities))
        (if (== $communities ())
            ()
            (car-atom $communities)
        )
    )
)


; --------------------------------------------------
; Basic community atom selection
; --------------------------------------------------

(= (pickCommunityAtom $community)
    (if (== $community ())
        (getRandomAtomInAF)
        (py-call (random.choice $community))
    )
)

(= (pickCommunityOutsideAF $community)
    (let $outside
        (subtraction-atom $community (getAfAtoms))
        (if (== $outside ())
            (pickCommunityAtom $community)
            (py-call (random.choice $outside))
        )
    )
)


; --------------------------------------------------
; Community membership
; --------------------------------------------------

(= (communityContains $atom $community)
    (> (size-atom (intersection-atom ($atom) $community)) 0)
)


; --------------------------------------------------
; Get the other end of a graph link
; --------------------------------------------------

(= (incidentEdgeOtherEnd $atom (($link)))
    (incidentEdgeOtherEnd $atom $link)
)

(= (incidentEdgeOtherEnd $atom $link)
    (let* (
            ($src (car-atom (cdr-atom $link)))
            ($tgt (car-atom (cdr-atom (cdr-atom $link))))
        )
        (if (== $src $atom)
            $tgt
            (if (== $tgt $atom)
                $src
                $tgt
            )
        )
    )
)


; --------------------------------------------------
; Original graph-guided outside-AF exploration
; --------------------------------------------------

(= (pickGraphNeighbor $atom)
    (let*
        (
            ($incidents
                (unify &incident ($atom $incident) $incident ())
            )

            ($outside
                (subtraction-atom $incidents (getAfAtoms))
            )
        )
        (if (== $outside ())
            $atom
            (let $choice (py-call (random.choice $outside))
                (incidentEdgeOtherEnd $atom $choice)
            )
        )
    )
)

(= (pickOutsideAF)
    (pickGraphNeighbor (getRandomAtomInAF))
)


; --------------------------------------------------
; Community-boundary exploration
; --------------------------------------------------

(= (pickCommunityBoundaryAtomHelper $community $attempt)
    (if (>= $attempt 5)
        (pickOutsideAF)

        (let $anchor (pickCommunityAtom $community)
            (if (== $anchor ())
                (pickOutsideAF)

                (let $incidents
                    (unify &incident ($anchor $incident) $incident ())

                    (if (== $incidents ())
                        (pickCommunityBoundaryAtomHelper
                            $community
                            (+ $attempt 1))

                        (let $choice
                            (py-call (random.choice $incidents))

                            (let $candidate
                                (incidentEdgeOtherEnd $anchor $choice)

                                (if
                                    (and
                                        (== (communityContains
                                              $candidate
                                              $community)
                                            False)

                                        (== (size-atom
                                              (intersection-atom
                                                  ($candidate)
                                                  (getAfAtoms)
                                              )
                                            )
                                            0)
                                    )
                                    $candidate
                                    (pickCommunityBoundaryAtomHelper
                                        $community
                                        (+ $attempt 1))
                                )
                            )
                        )
                    )
                )
            )
        )
    )
)

(= (pickCommunityBoundaryAtom $community)
    (pickCommunityBoundaryAtomHelper $community 0)
)


; --------------------------------------------------
; Thompson strategy seed generation
; --------------------------------------------------

(= (applyStrategy narrow-focus)
    (let* (
        ($community (bestCommunity))

        ($a (pickCommunityAtom $community))
        ($b (pickCommunityAtom $community))
        ($c (pickCommunityAtom $community))
        ($d (pickCommunityAtom $community))
    )
        ($a $b $c $d)
    )
)

(= (applyStrategy expand-focus)
    (let* (
        ($community (bestCommunity))

        ($a (pickCommunityAtom $community))
        ($b (pickCommunityAtom $community))
        ($c (pickCommunityBoundaryAtom $community))
        ($d (pickCommunityBoundaryAtom $community))
    )
        ($a $b $c $d)
    )
)

(= (applyStrategy explore-novel)
    (let* (
        ($community (leastCommunity))

        ($a (pickCommunityOutsideAF $community))
        ($b (pickCommunityOutsideAF $community))
        ($c (pickCommunityBoundaryAtom $community))
        ($d (pickCommunityBoundaryAtom $community))
    )
        ($a $b $c $d)
    )
)