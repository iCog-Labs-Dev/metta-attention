!(bind! maxSpreadPercentage 0.4)
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
        (if (== $atomToReceive ())
            ()
            (tradeSti $atom $atomToReceive $stiGiven)
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
            ($resultone (extractMap $hebbianProportionSTI))
            ($hebbianDiffusionUsed (hebbianDiffusionUsed $hebbianProportionSTI))
            ($resulttwo (collapse (incidentProportionSTI $incidentVector $hebbianDiffusionUsed)))
            ($finalResult (concatTuple $resultone $resulttwo))
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
        ($habbeanDiffusionUsed $resultone)
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
        (+ (let $t (car-atom $expr) (car-atom $t)) (hebbianDiffusionUsed (cdr-atom $expr)))
    )
)

;; This function will extract the map from the hebbian proportion of the STI
;; Parameters $expr: The expression that will be used to extract the map
;; Return : The map from the hebbian proportion of the STI

(: extractMap (-> Atom Atom))
(= (extractMap $expr)
    (if (== $expr ())
        ()
        (concatTuple (let $t (car-atom $expr) (cdr-atom $t)) (extractMap (cdr-atom $expr)))
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

;; This function will return the diffusion source vector (atoms that can be diffused) from AF
;; Parameters $space: The space that will be used to find the diffusion source vector
;; Return : The diffusion source vector

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

;; This function will return the diffusion source vector (atoms that can be diffused) from WA
;; Parameters $space: The space that will be used to find the diffusion source vector
;; Return : The diffusion source vector

(: diffusionSourceVectorWA (-> Atom))
(= (diffusionSourceVectorWA)
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

;;This function will retrieve the diffusion source vector from AF and then call the diffuseAtom function to diffuse the atoms
;; Parameters $space: The space that will be used to find the diffusion source vector
;;            $space2: The space that will be used to find incomingSets
;; Return : The diffusion get called

(: spreadImportance (-> Grounded Grounded Empty))
(= (spreadImportance $space $space2)
    (let $diffusionSourceVector (diffusionSourceVector $space)
        (diffuseAtom (superpose $diffusionSourceVector) $space2 AF)
    )
)

;;This function will retrieve the diffusion source vector from WA and then call the diffuseAtom function to diffuse the atoms
;; Parameters $space: The space that will be used to find the diffusion source vector
;; Return : The diffusion get called

(: spreadImportanceWA (-> Grounded Empty))
(= (spreadImportanceWA $space)
    (let $diffusionSourceVector (collapse (diffusionSourceVectorWA))
        (if (== (size-atom $diffusionSourceVector) 0)
            ()
            (let $target (index-atom $diffusionSourceVector 0)
                (diffuseAtom $target $space WA)
            )
        )
    )
)

;; This function will calculate the diffusion amount
;; Parameters $atom: The atom that will be used to calculate the diffusion amount
;; Return : The diffusion amount

(: calculateDiffusionAmount (-> Atom Number))
(= (calculateDiffusionAmount $atom)
    (* (getSTI $atom) maxSpreadPercentage)
)

;; This function will calculate the diffusion amount for WA
;; Parameters $atom: The atom that will be used to calculate the diffusion amount
;; Return : The diffusion amount

(: calculateDiffusionAmountWA (-> Atom Number))
(= (calculateDiffusionAmountWA $atom)
    (let*
        (
            ($currentEstiate (diffusedValue $atom maxSpreadPercentage))
            ($diffusionAmount (- (getSTI $atom) $currentEstiate))
        )
        $diffusionAmount
    )
)

;; This function will trade STI between source and starget, deducting the value from source and adding it to target
;; Parameters $source: The source atom that will will be used to trade STI
;;            $target: The target atom that will will be used to trade STI
;;            $value: The value that will be used to trade STI
;; Return : The STI value of source and target

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

;; This function is the entry point to the AFImportance Diffusion Agent
;; Parameters $space: The space that will be used to find the diffusion source vector
;;            $space2: The space that will be used to find incomingSets
;; Return : The spreadImportance function is called

(: AFImportanceDiffusionAgent-Run (-> Grounded Grounded Empty))
(= (AFImportanceDiffusionAgent-Run $space $space2)
    (spreadImportance $space $space2)
)

;; This function is the entry point to the WAImportance Diffusion Agent
;; Parameters $space: The space that will be used to find the diffusion source vector
;; Return : The spreadImportanceWA function is called

(: WAImportanceDiffusionAgent-Run (-> Grounded Empty))
(= (WAImportanceDiffusionAgent-Run $space)
    (spreadImportanceWA $space)
)