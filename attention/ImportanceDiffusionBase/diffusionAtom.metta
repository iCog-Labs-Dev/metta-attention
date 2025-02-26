!(bind! &diffusedAtomSpace (new-space))

;function diffuseAtom
;param atom
;return None
(: diffuseAtom (-> Atom empty))
(= (diffuseAtom $source)
    (let* (
        ($incidentAtoms (incidentAtoms $source))
        ($hebbianAdjacentAtoms (hebbianAdjacentAtoms $source))
        ($probabilityVectorIncident (probabilityVectorIncident $incidentAtoms))
        ($probabilityVectorHebbianAdjacent (probabilityVectorHebbianAdjacent $source $hebbianAdjacentAtoms))
        ($probabilityVector (combineIncidentAdjacentVectors $probabilityVectorIncident $probabilityVectorHebbianAdjacent))
        ($totalDiffusionAmount (calculateDiffusionAmount $source))
        )
        (if (== $totalDiffusionAmount 0)
            (empty)
            (diffuseAtomHelper $probabilityVector $totalDiffusionAmount $source)
            )
    )
)

;function diffuseAtomHelper
;param Expression Number Atom
;return empty
(: diffuseAtomHelper (-> Expression Number Atom empty))
(= (diffuseAtomHelper $probabilityVector $totalDiffusionAmount $source)
    (if (== $probabilityVector ())
        (emtpy)
        (let* (
            ($head (car-atom $probabilityVector))
            ($target (car-atom $head))
            ($head-probability (cdr-atom $head))
            ($head-val (car-atom $head-probability))
            ($amount (* $head-val $totalDiffusionAmount))
            ($tail (cdr-atom $probabilityVector))
            ($recursive (diffuseAtomHelper $tail $totalDiffusionAmount $source))
            ($diffusionEvent (collapse (match &diffusedAtomSpace ($source $target $x) ($x))))
            )
            (if (== $diffusionEvent ())
                (let* (
                    ($_ (add-atom &diffusedAtomSpace ($source $target $amount)))
                )
                (emtpy)
                )
                (let* (
                    ($val (car-atom $diffusionEvent))
                    ($_ (atom-remove &diffusedAtomSpace ($source $target $val)))
                    ($_ (add-atom &diffusedAtomSpace ($source $target $amount)))
                )
                (emtpy)
                )
                )
        )
    )
)
;function processDiffusionStack
;param None
;return None
(: processDiffusionStack (-> empty))
(= (processDiffusionStack)
    (let $totalAmountTraded 0
        (match &diffusedAtomSpace ($source $target $value)
            (let* (
                ($_ (remove-atom &diffusedAtomSpace ($source $target $value)))
                ($tradeSTI (tradeSTI $source $target $value))
                
                )
                (empty)
            )
        )
    )
)