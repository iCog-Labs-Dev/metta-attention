!(bind! maxSpreadPercentage 0.1)
!(bind! hebbianMaxAllocationPercentage 1)

(= (diffuseAtom $atom $space)
    (let*
        (
            ($incidentAtoms (collapse (incidentAtoms $atom $space)))
            ($filtered (collapse (filteredIncidentAtoms (superpose $incidentAtoms))))
            ($iset (getIncomingSet $atom ASYMMETRIC_HEBBIAN_LINK) )
            ($hebbianAdjacentAtoms (collapse (hebbianAdjacentAtoms $iset $atom)))
            ($probabilityVectorIncident (collapse (probabilityVectorIncident $incidentAtoms)))
            ($probabilityVectorHebbianAjacent (collapse (probabilityVectorHebbianAjacent $atom $hebbianAdjacentAtoms)))
            ($combProbabilityVector (combineIncidentAdjacentVectors $probabilityVectorIncident $probabilityVectorHebbianAjacent))
            ($totaldiffusionAmount (calculateDiffusionAmount $atom)) ; Why shouldn't this be at the top weird
            (($atomToReceive $stiGiven)
                    (if (== $totaldiffusionAmount 0)
                        (() 0)
                        (let*
                            (
                                (($first $second) (superpose $combProbabilityVector))
                                ($diffusionAmount  (* $totaldiffusionAmount $second))
                            )
                            ($first $diffusionAmount)
                        )
                    )
            )
        )
        (if (== $atomToReceive ())
            ()
            (tradeSti $atom $atomToReceive $stiGiven)
        )
    )
)

(: incidentAtoms (-> Atom Grounded Atom))
(= (incidentAtoms $atom $space)
    (let*
        (
            ($incomingSet (getAllIncomingSets $atom $space))
            ($outgoingSet
                (unify $atom ($link $source $target)
                    (getOutGoingAtoms $atom)
                    ()
                )
            )
            ($joinSet (concatTuple $incomingSet $outgoingSet))
            ($decomposed (superpose $joinSet))
        )
        $decomposed
    )
)

(: filteredIncidentAtoms (-> Atom Atom))
(= (filteredIncidentAtoms $atom)
    (if (== (get-metatype $atom) Expression)
        (if (== (car-atom $atom) ASYMMETRIC_HEBBIAN_LINK)
            ()
            $atom
        )
        $atom
    )
)

(: hebbianAdjacentAtoms (-> Atom Atom Atom))
(= (hebbianAdjacentAtoms $iset $atom)
    (getTargetNeighborsAFI (superpose $iset) $atom ASYMMETRIC_HEBBIAN_LINK True)
)

(: probabilityVectorIncident (-> Atom Atom))
(= (probabilityVectorIncident $incidentAtoms)
    (let*
        (
            ($diffusionAmount (/ 1.0 (size-atom $incidentAtoms)))
            ($result ((superpose $incidentAtoms) $diffusionAmount))
        )
        $result
    )
)

(: probabilityVectorHebbianAjacent (-> Atom Atom Atom))
(= (probabilityVectorHebbianAjacent $atom $hebbianAdjacentAtoms)
    (let*
        (
            ($diffusionAvailable 1.0)
            ($atomCount (size-atom $hebbianAdjacentAtoms))
            ($maxAllocation (/ $diffusionAvailable $atomCount))
            ($target (superpose $hebbianAdjacentAtoms))
            ($diffusionAmount (* $maxAllocation (calculateHebbianDiffusionPercentation (ASYMMETRIC_HEBBIAN_LINK $atom $target))))
        )
        ($target $diffusionAmount)
    )
)

(: combineIncidentAdjacentVectors (-> Atom Atom Atom))
(= (combineIncidentAdjacentVectors $incidentVector $adjacentVector)
    (let*
        (
            ($diffusionAvailable 1.0)
            ($hebbianDiffusionAvailable (* hebbianMaxAllocationPercentage $diffusionAvailable))
            ($hebbianMaximumLinkAllocation (/ $hebbianDiffusionAvailable (size-atom $adjacentVector)))
            ($hebbianProportionSTI (collapse (hebbianProportionSTI $adjacentVector $hebbianMaximumLinkAllocation)))
            ($resultone (extractMap $hebbianProportionSTI))
            ($hebbianDiffusionUsed (hebbianDiffusionUsed $hebbianProportionSTI))
            ($resulttwo (collapse (incidentProportionSTI $incidentVector $hebbianDiffusionUsed)))
            ($finalResult (concatTuple $resultone $resulttwo))
        )
        $finalResult
    )
)

(: hebbianProportionSTI (-> Atom Number Atom))
(= (hebbianProportionSTI $adjacentVector $hebbianMaximumLinkAllocation)
    (let*
        (
            ($decomposedAdjacentVector (superpose $adjacentVector))
            (($firstA $secondA) $decomposedAdjacentVector)
            ($resultone (let $diffusionAmountA (* $hebbianMaximumLinkAllocation $secondA) ($firstA $diffusionAmountA)))
            ($habbeanDiffusionUsed $secondA)

        )
            ($habbeanDiffusionUsed $resultone)
    )
)

(: incidentProportionSTI (-> Atom Number Atom))
(= (incidentProportionSTI $incidentVector $hebbianDiffusionUsed )
    (let*
        (
            ($decomposedIncidentVector (superpose $incidentVector))
            (($firstI $secondI) $decomposedIncidentVector)
            ($resulttwo (let $diffusionAmountI (* (- 1.0 $hebbianDiffusionUsed) $secondI) ($firstI $diffusionAmountI)))
        )
        $resulttwo
    )
)

(= (hebbianDiffusionUsed $expr)
    (if (== $expr ())
        0
        (+ (let $t (car-atom $expr) (car-atom $t)) (hebbianDiffusionUsed (cdr-atom $expr)))
    )
)

(= (extractMap $expr)
    (if (== $expr ())
        ()
        (concatTuple (let $t (car-atom $expr) (cdr-atom $t)) (extractMap (cdr-atom $expr)))
    )
)

(: calculateHebbianDiffusionPercentation (-> Atom Number))
(= (calculateHebbianDiffusionPercentation $link)
    (let*
        (
            ($strength (getMean $link))
            ($confident (getConfidence $link))
        )
        (* $strength $confident)
    )
)

(: diffusionSourceVector (-> Grounded Atom))
(= (diffusionSourceVector $space)
    (let*
        (
            ($atoms (match $space $x $x))
            ($result
                    (unify $atoms (ASYMMETRIC_HEBBIAN_LINK $a $b) (empty) $atoms))
        )
        $result
    )
)

; (= (diffusionSourceVectorWA $space)
;     (let*
;         (
;             ($atoms (getRandomAtomNotInAF))
;             ($result
;                     (unify $atoms (ASYMMETRIC_HEBBIAN_LINK $a $b) (empty) $atoms))
;         )
;         $result
;     )
; )

(: getOutGoingAtoms (-> Atom Atom))
(= (getOutGoingAtoms $link)
    (if (== (size-atom $link) 3)
        (cdr-atom $link)
        "No outgoing atoms"
    )
)

(: getAllIncomingSets (-> Atom Grounded List))
(= (getAllIncomingSets $atom $space)
    (collapse
        (superpose
            (
                (match $space ($type $atom $b) ($type $atom $b))
                (match $space ($type $b $atom) ($type $b $atom))
            )
        )
    )
)

(: spreadImportance (-> Grounded Empty))
(= (spreadImportance $space)
    (let $diffusionSourceVector (collapse (diffusionSourceVector $space))
        (helper-loop $diffusionSourceVector $space)
    )
)

(= (helper-loop $diffusionSourceVector $space)
    (if (== $diffusionSourceVector ())
        ()
        ((diffuseAtom (car-atom $diffusionSourceVector) $space) (helper-loop (cdr-atom $diffusionSourceVector) $space))
    )
)

(: calculateDiffusionAmount (-> Atom Number))
(= (calculateDiffusionAmount $atom)
    (* (getSTI $atom) maxSpreadPercentage)
)

; (= (calculateDiffusionAmountWA $atom)
;     ("To be implemented")
; )


(: tradeSti (-> Atom Atom Number %Undefined%))
(= (tradeSti $source $target $value)
      (let*
            (
                ($sourceSTI (getSTI $source))
                ($targetSTI (getSTI $target))
                ($newSourceSTI (- $sourceSTI $value))
                ($newTargetSTI (+ $targetSTI $value))
                (() (setSTI $target $newTargetSTI))
                (() (setSTI $source $newSourceSTI))
            )
        ()
    )
)

(: AFImportanceDiffusionAgent-Run (-> Grounded Empty))
(= (AFImportanceDiffusionAgent-Run $space)
    (spreadImportance $space)
)

(= (WAImportanceDiffusionAgent-Run $space)
    ("To be implemented")
)