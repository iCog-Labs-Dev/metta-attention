!(bind! maxSpreadPercentage 0.4)
!(bind! hebbianMaxAllocationPercentage 0.05)

(= (diffuseAtom $atom $space $AForWA)
    (let*
        (
            ($incidentAtoms (collapse (incidentAtoms $atom $space)))
            ($oset (if (== (get-metatype $atom) Expression)
                        (getOutGoingAtoms $atom)
                        ()
                    )
            )
            ($incidentAndoset (concatTuple $incidentAtoms $oset))
            ($iset (getIncomingSet $atom ASYMMETRIC_HEBBIAN_LINK) )
            ($hebbianAdjacentAtoms (collapse (hebbianAdjacentAtoms $iset $atom)))
            ($probabilityVectorIncident (collapse (probabilityVectorIncident $incidentAndoset)))
            ($probabilityVectorHebbianAjacent (collapse (probabilityVectorHebbianAjacent $atom $hebbianAdjacentAtoms)))
            ($combProbabilityVector (combineIncidentAdjacentVectors $probabilityVectorIncident $probabilityVectorHebbianAjacent))
            ($totaldiffusionAmount (if (== $AForWA AF)
                                       (calculateDiffusionAmount $atom)
                                       (calculateDiffusionAmountWA $atom)
                                    )
            ) ; Why shouldn't this be at the top weird
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
            ($filtered
                (if (== (car-atom $incomingSet) ASYMMETRIC_HEBBIAN_LINK)
                    (empty)
                    (if (== (car-atom $incomingSet) HEBBIAN_LINK)
                        (empty)
                        $incomingSet
                    )
                )
            )
        )
        $filtered
    )
)

(: removeHebbianLinks (-> Atom Atom))
(= (removeHebbianLinks $atom)
    (if (== (get-metatype $atom) Expression)
        (if (== (car-atom $atom) ASYMMETRIC_HEBBIAN_LINK)
            (empty)
            (if (== (car-atom $atom) HEBBIAN_LINK)
                (empty)
               (wth $atom)
            )
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
            ($atoms (collapse (let $temp (match $space $x $x)
                (if (== (get-metatype $temp) Expression)
                    (if (== (car-atom $temp) ASYMMETRIC_HEBBIAN_LINK) 
                        (empty)
                        (if (== (car-atom $temp) HEBBIAN_LINK)
                            (empty)
                            $temp
                        )
                    )
                    $temp
                ))))
            ($sorted (sortAtomsBySti $atoms))
        )
        $sorted
    )
)

(= (diffusionSourceVectorWA $space)
    (let*
        (
            ($atoms (getRandomAtomNotInAF))
            ($result
                (if (== $atoms ())
                    ()
                    (if (== (get-metatype $atoms) Expression)
                            (if (== (car-atom $atoms) ASYMMETRIC_HEBBIAN_LINK)
                                (empty)
                                (if (== (car-atom $atoms) HEBBIAN_LINK)
                                    (empty)
                                    $atoms
                                )
                            )
                            $atoms
                    )
                )
            )
        )
        $result
    )
)

(: getOutGoingAtoms (-> Atom Atom))
(= (getOutGoingAtoms $link)
    (if (== (size-atom $link) 3)
        (cdr-atom $link)
        "No outgoing atoms"
    )
)

;; This should be the correct logic getALlIncomingSets not from AF

; (: getAllIncomingSets (-> Atom Grounded List))
; (= (getAllIncomingSets $atom $space)
;     (let*
;         (
;             ($allAtoms (superpose (getAtomsInBins)))
;             ($filtered
;                 (if (or (unify ($type $atom $target) $allAtoms True False) (unify ($type $source $atom) $allAtoms True False))
;                     $filtered
;                     (empty)
;                 )
;             )
;         )
;         $filtered
;     )
; )

;Simulation Temporary
(: getAllIncomingSets (-> Atom Grounded List))
(= (getAllIncomingSets $atom $space)
    (superpose
        (
            (match $space ($type $atom $x) ($type $atom $x))
            (match $space ($type $x $atom) ($type $x $atom))
        )
    )
)

(: spreadImportance (-> Grounded Empty))
(= (spreadImportance $space)
    (let $diffusionSourceVector (diffusionSourceVector $space)
        (diffuseAtom (superpose $diffusionSourceVector) $space AF)
    )
)

(: spreadImportanceWA (-> Grounded Empty))
(= (spreadImportanceWA $space)
    (let $diffusionSourceVector (collapse (diffusionSourceVectorWA $space))
        (if (== (size-atom $diffusionSourceVector) 0)
            ()
            (let $target (index-atom $diffusionSourceVector 0)
                (diffuseAtom $target $space WA)
            )
        )
    )
)

(: calculateDiffusionAmount (-> Atom Number))
(= (calculateDiffusionAmount $atom)
    (* (getSTI $atom) maxSpreadPercentage)
)

(= (calculateDiffusionAmountWA $atom)
    (let*
        (
            ($currentEstiate (diffusedValue $atom maxSpreadPercentage))
            ($diffusionAmount (- (getSTI $atom) $currentEstiate))
        )
        $diffusionAmount
    )
)


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

(: WAImportanceDiffusionAgent (-> Grounded Empty))
(= (WAImportanceDiffusionAgent-Run $space)
    (spreadImportanceWA $space)
)