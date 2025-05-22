!(bind! hebbianMaxAllocationPercentage 0.05)

;; This function is the main function that will be called to start the diffusion process
;; It will get the diffusion source vector and then call the diffuseAtom function
;; Parameters $atom: The atom that will be diffused
;;            $space: The space that incomingSets will be taken from
;;            $AForWA: a flag if the calculation to use is for AF or WA
;; Return : trades sti value from source to target

; (: diffuseAtom (-> Atom Grounded Symbol Atom))
(= (diffuseAtom $atom $space $AForWA)
    (let*
        (
            ($incidentAtoms (collapse (incidentAtoms $atom $space)))
            ($foset (if (== (get-metatype $atom) Expression)
                        (getOutGoingAtoms $atom)
                        ()
                    )
            )
            ($oset (filteroset $foset))
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
            )
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
        ($atom $atomToReceive $stiGiven)
    )
)
(= (filteroset $oset) 
    (let* 
        (
            ($tail (cdr-atom $oset))
            ($vals (superpose $tail))
            ($type (if (== (get-metatype $vals) Expression)
                        (car-atom $vals)
                        $vals
                    )
            )
        )
        (if (== $type ASYMMETRIC_HEBBIAN_LINK)
            ()
            $type
        )
    )
)

;; This function will return the incident atoms of a given atom
;; Parameters $atom: The atom that will be used to find incident atoms
;;            $space: The space that incomingSets will be taken from
;; Return : The incident atoms of the given atom

(: incidentAtoms (-> Atom Grounded Atom))
(= (incidentAtoms $atom $space)
    (let*
        (
            ($incomingSet (getAllIncomingSets $atom $space))
            ($filtered
                (if (== (car-atom $incomingSet) ASYMMETRIC_HEBBIAN_LINK) ;; Need to be Removed
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

;; This function will return the hebbian adjacent atoms of a given atom
;; Parameters $iset: The incoming set that will be used to find hebbian adjacent atoms
;;            $atom: The atom that will be used to find hebbian adjacent atoms
;; Return : The hebbian adjacent atoms of the given atom

(: hebbianAdjacentAtoms (-> Atom Atom Atom))
(= (hebbianAdjacentAtoms $iset $atom)
    (getTargetNeighborsAFI (superpose $iset) $atom ASYMMETRIC_HEBBIAN_LINK True)
)

;; This function will return the probability vector(tuple) of the incident atoms
;; Parameters $incidentAtoms: The incident atoms that will be used to find the probability vector(tuple)
;; Return : The probability vector(tuple) of the incident atoms

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

;; This function will return the probability vector(tuple) of the hebbian adjacent atoms
;; Parameters $atom: The atom that will be used to find the probability vector(tuple)
;;            $hebbianAdjacentAtoms: The hebbian adjacent atoms that will be used to find the probability vector(tuple)
;; Return : The probability vector(tuple) of the hebbian adjacent atoms

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

;; This function will combine the incident and hebbian adjacent vectors(tuple)
;; Parameters $incidentVector: The incident vector that will be used to combine
;;            $adjacentVector: The adjacent vector that will be used to combine
;; Return : The combined vector(tuple)

(: combineIncidentAdjacentVectors (-> Atom Atom Atom))
(= (combineIncidentAdjacentVectors $incidentVector $adjacentVector)
    (let*
        (
            ($diffusionAvailable 1.0)
            ($hebbianDiffusionAvailable (* hebbianMaxAllocationPercentage $diffusionAvailable))
            ($hebbianMaximumLinkAllocation (/ $hebbianDiffusionAvailable (size-atom $adjacentVector)))
            ($hebbianProportionSTI (collapse (hebbianProportionSTI $adjacentVector $hebbianMaximumLinkAllocation)))
            ($hebbianDiffusionUsed (hebbianDiffusionUsed $hebbianProportionSTI))
            ($resulttwo (collapse (incidentProportionSTI $incidentVector $hebbianDiffusionUsed)))
            ($finalResult (concatTuple $hebbianProportionSTI $resulttwo))
        )
        $finalResult
    )
)

;; This function will return the hebbian proportion of the STI
;; Parameters $adjacentVector: The hebbian adjacent vector that will be used to find the hebbian proportion of the STI
;;            $hebbianMaximumLinkAllocation: The maximum link allocation
;; Return : The hebbian proportion of the STI

(: hebbianProportionSTI (-> Atom Number Atom))
(= (hebbianProportionSTI $adjacentVector $hebbianMaximumLinkAllocation)
    (let*
        (
            ($decomposedAdjacentVector (superpose $adjacentVector))
            (($firstA $secondA) $decomposedAdjacentVector)
            ($resultone (let $diffusionAmountA (* $hebbianMaximumLinkAllocation $secondA) ($firstA $diffusionAmountA)))
            ($habbeanDiffusionUsed $secondA)

        )
        $resultone
    )
)

;; This function will return the incident proportion of the STI
;; Parameters $incidentVector: The incident vector that will be used to find the incident proportion of the STI
;;            $hebbianDiffusionUsed: The hebbian diffusion used sofar
;; Return : The incident proportion of the STI

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

;; This function will return the hebbian diffusion used sofar
;; Parameters $expr: The expression that will be used to find the hebbian diffusion used sofar
;; Return : The hebbian diffusion used sofar

(: hebbianDiffusionUsed (-> Atom Number))
(= (hebbianDiffusionUsed $expr)
    (if (== $expr ())
        0
        (let* 
            (
                ($atom (car-atom $expr))
                (($head $amount) $atom)
                ($tail (cdr-atom $expr))
            ) 
            (+ $amount (hebbianDiffusionUsed $tail))
        )
    )
)

;; This function will extract the map from the hebbian proportion of the STI
;; Parameters $expr: The expression that will be used to extract the map
;; Return : The map from the hebbian proportion of the STI

(: extractMap (-> Atom Atom))
(= (extractMap $expr)
    (if (== $expr ())
        ()
        (let*
            (
                (() (println! ($expr)))
                ($vals (superpose $expr))
                (($first $second) $vals)
            )
            $second
        )
    )
)

;; This function will calculate the hebbian diffusion percentation of link
;; Parameters $link: The link that will be used to calculate the hebbian diffusion percentation
;; Return : The hebbian diffusion percentation of the link

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

;; This function will return the outgoing atoms of Link
;; Parameters $link: The link that will be used to find the outgoing atoms
;; Return : The outgoing atoms of the link

(: getOutGoingAtoms (-> Atom Atom))
(= (getOutGoingAtoms $link)
    (if (== (size-atom $link) 3)
        (cdr-atom $link)
        "No outgoing atoms"
    )
)

;; This function will return the incoming set of an atom
;; Parameters $atom: The atom that will be used to find the incoming set
;;            $type: The type that will be used to find the incoming set
;; Return : The incoming set of the atom

(: getAllIncomingSets (-> Atom Grounded List))
(= (getAllIncomingSets $atom $space)
    (superpose
        (
            (match $space (: ($type $atom $x) $AV) ($type $atom $x))
            (match $space (: ($type $x $atom) $AV) ($type $x $atom))
        )
    )
)

;; This function will trade STI between source and starget, deducting the value from source and adding it to target
;; Parameters $source: The source atom that will will be used to trade STI
;;            $target: The target atom that will will be used to trade STI
;;            $value: The value that will be used to trade STI
;; Return : The STI value of source and target

(: tradeSti (-> Atom Atom Number %Undefined%))
(= (tradeSti $source $target $value)
    (if (or (== $source ()) (== $target ()))
        ()
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
)
