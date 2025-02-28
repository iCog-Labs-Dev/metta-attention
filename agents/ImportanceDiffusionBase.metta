!(register-module! ../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &self metta-attention:agents:Neighbors)

!(add-atom &attentionalFocus (UNORDERED_LINK A B))
!(add-atom &attentionalFocus (UNORDERED_LINK B A))
!(add-atom &attentionalFocus (ASYMMETRIC_HEBBIAN_LINK C D))
!(add-atom &attentionalFocus (ASYMMETRIC_HEBBIAN_LINK C F))
!(add-atom &attentionalFocus (INHERITANCE_LINK B C))
!(add-atom &attentionalFocus (HEBBIAN_LINK A C))
!(add-atom &attentionalFocus (HEBBIAN_LINK G H))
!(add-atom &attentionalFocus (HEBBIAN_LINK I J))
!(add-atom &attentionalFocus (HEBBIAN_LINK K L))
!(add-atom &attentionalFocus C)

!(add-atom &attentionalFocus (HEBBIAN_LINK (HEBBIAN_LINK K L) L))
!(add-atom &attentionalFocus (HEBBIAN_LINK G (HEBBIAN_LINK K L)))



!(bind! maxSpreadPercentage 0.1)
!(bind! hebbianMaxAllocationPercentage 1)
; !(bind! spreadHebbianOnly False)

!(setAv C (200 0.5 5))
!(setStv (ASYMMETRIC_HEBBIAN_LINK C D) (1 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK C F) (1 0.9))

; WE NEED SETSTI SETLTI SETVLTI FUNCTIONS
(= (diffuseAtom $atom)
    (let*
        (
            ($incidentAtoms (collapse (incidentAtoms $atom)))
            ($hebbianAdjacentAtoms (collapse (hebbianAdjacentAtoms $atom)))
            ($probabilityVectorIncident (collapse (probabilityVectorIncident $incidentAtoms)))
            ($probabilityVectorHebbianAjacent (collapse (probabilityVectorHebbianAjacent $atom $hebbianAdjacentAtoms)))
            ($combProbabilityVector (combineIncidentAdjacentVectors $probabilityVectorIncident $probabilityVectorHebbianAjacent))
            ($totaldiffusionAmount (calculateDiffusionAmount $atom)) ; Why shouldn't this be at the top weird
            (($atomToReceive $stiGiven)
                    (if (== $totaldiffusionAmount 0)
                        ()
                        (let*
                            (
                                (($first $second) (superpose $combProbabilityVector))
                                ($diffusionAmount  (* $totaldiffusionAmount $second))
                            )
                            ($first $diffusionAmount)
                        )
                    )
            )
            ; (() (setSTI $atomToReceive $stiGiven))
        )
        ;Need SETSTI function
        ; (setSTI $atom (- (getSTI $atom) $totaldiffusionAmount))
        ($atomToReceive $stiGiven)
    )
)

(= (incidentAtoms $atom)
    (let*
        (
            ($incomingSet (getAllIncomingSets $atom))
            ($outgoingSet
                (unify $atom ($link $source $target)
                    (getOutGoingAtoms $atom)
                    ()
                )
            )
            ($joinSet (concatTuple $incomingSet $outgoingSet))
            ($decomposed (superpose $joinSet))
            ($result
                (if (== (get-metatype $decomposed) Expression)
                        (if (== (car-atom $decomposed) ASYMMETRIC_HEBBIAN_LINK)
                            (empty)
                            $decomposed
                        )
                        $decomposed
                )
            )
        )
        $decomposed
    )
)


(= (hebbianAdjacentAtoms $atom)
    (let $resultSet
            (getTargetNeighbors $atom ASYMMETRIC_HEBBIAN_LINK True)
            $resultSet
    )
)

(= (probabilityVectorIncident $incidentAtoms)
    (let*
        (
            ($diffusionAmount (/ 1.0 (size-atom $incidentAtoms)))
            ($result ((superpose $incidentAtoms) $diffusionAmount))
        )
        $result
    )
)

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

(= (calculateHebbianDiffusionPercentation $link)
    (let*
        (
            ($strength (getMean $link))
            ($confident (getConfidence $link))
        )
        (* $strength $confident)
    )
)

(= (diffusionSourceVector)
    (let*
        (
            ($atoms (match &attentionalFocus $x $x))
            ($result
                    (unify $atoms (ASYMMETRIC_HEBBIAN_LINK $a $b) (empty) $atoms))
        )
        $result
    )
)

;##################### Duplicates ##########################
(= (getOutGoingAtoms $link)
    (if (== (size-atom $link) 3)
        (cdr-atom $link)
        "No outgoing atoms"
    )
)

(: getIncomingSetByType (-> Atom List))
(= (getAllIncomingSets $atom)
    (collapse
        (superpose
            (
                (match &attentionalFocus ($type $atom $b) ($type $atom $b))
                (match &attentionalFocus ($type $b $atom) ($type $b $atom))
            )
        )
    )
)

(= (AFImportanceDiffusionAgent-Run)
    (spreadImportance)
)

(= (spreadImportance)
    (let $diffusionSourceVector (collapse (diffusionSourceVector))
        (helper-loop $diffusionSourceVector)
        ; (diffuseAtom (superpose $diffusionSourceVector))
    )
)

(= (helper-loop $diffusionSourceVector)
    (if (== $diffusionSourceVector ())
        ()
        ((collapse (diffuseAtom (car-atom $diffusionSourceVector))) (helper-loop (cdr-atom $diffusionSourceVector)))
    )
)

(= (calculateDiffusionAmount $atom)
    (* (getSTI $atom) maxSpreadPercentage)
)


!(AFImportanceDiffusionAgent-Run)
; ; !(incidentAtoms C)
;  !(diffuseAtom C)
; ;  !(diffusionSourceVector)


; (((H 0.5) (G 0.5)) (((L 0.25) (K 0.25) ((HEBBIAN_LINK G (HEBBIAN_LINK K L)) 0.25) ((HEBBIAN_LINK (HEBBIAN_LINK K L) L) 0.25)) (((C 0.5) (B 0.5)) ((((HEBBIAN_LINK K L) 0.5) (G 0.5)) (((J 0.5) (I 0.5)) (((C 0.5) (A 0.5)) (((B 0.5) (A 0.5)) (((L 0.5) ((HEBBIAN_LINK K L) 0.5)) (((A 0.5) (B 0.5)) (((D 0.025) (F 0.0125) ((INHERITANCE_LINK B C) 0.125) ((HEBBIAN_LINK A C) 0.125)) ()))))))))))