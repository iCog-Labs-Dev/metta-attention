(: hebbianMaxAllocationPercentage (-> Number))
(= (hebbianMaxAllocationPercentage) 0.05)
;function incidentAtoms
;param: Atom
;return Expression
;get incoming atom to the target atom

(: incidentAtoms (-> Atom Expression))
(= (incidentAtoms $atom )
    (let* (
        ($incomingSet (getIncomingSetAllType $atom))
        ($incoming (incidentAtomsHelper $incomingSet $atom))
       
        )
        $incoming
    )


)
;function incidentAtomsHelper
;param Expression Atom
;retunr Expression
;remove hebian link from the incoming set also remove asymmetric hebbian link
(: incidentAtomsHelper (-> Expression Atom Expression))
(= (incidentAtomsHelper $incommingSet $atom)
    (if (== $incommingSet ())
        ()
        (let* (
            ($head (car-atom $incommingSet))
            ($tail (cdr-atom $incommingSet))
            ($link (car-atom $head))
            ($atoms (cdr-atom $head))
            ($source (car-atom $atoms))
            ($target (cdr-atom $atoms))
            ($targetValue (car-atom $target))
            ($recursive (incidentAtomsHelper $tail $atom))
            )
            (if (or (== habbianlink $link) (== ASYMMETRIC_HEBBIAN_LINK $link))
                $recursive
                (if (== $source $atom)
                    (cons-atom $targetValue $recursive )
                    (cons-atom $source $recursive)
                )
            )
        )
    )
)

;function hebbianAdjacentAtoms
;return Expression
;param Atom

(: hebbianAdjacentAtoms (-> Atom Expression))
(= (hebbianAdjacentAtoms $atom)
    (let $resultSet (getIncomingSetByType $atom ASYMMETRIC_HEBBIAN_LINK) ;this function is not write function but it return similar result if the nighbour is implimented we will change it
        (incidentAtomsHelper $resultSet $atom)
    ) 
)

;function probabilityVectorIncident
;param Expression
;return Expression

(: probabilityVectorIncident (-> Expression Expression))
(= (probabilityVectorIncident $atoms)
    (let $diffusionAmount (/ 1.0 (size-atom $atoms))
        (probabilityVectorHebbianHelper $atoms $diffusionAmount)

    )
)
;function probabilityVectorHebbianHelper
;param Expression, Number
;return Expression
(: probabilityVectorHebbianHelper (-> Expression Number Expression))
(= (probabilityVectorHebbianHelper $atoms $diffusionAmount)
    (if (== $atoms ())
        ()
        (let* (
            ($head (car-atom $atoms))
            ($tail (cdr-atom $atoms))
            ($recursive (probabilityVectorHebbianHelper $tail $diffusionAmount))
            ($diffused ($head $diffusionAmount))
            )
            (cons-atom $diffused $recursive)
        )
    )
)
;function calculateHebbianDiffusionPercentage
;param Atom
;return Number
(: calculateHebbianDiffusionPercentage (-> Atom Number))
(= (calculateHebbianDiffusionPercentage $atom)
    (let* (
        ($strength (getMean $atom))
        ($confidence (getConfidence $atom))
        ($diffused (* $strength $confidence))
        )
        $diffused
    )
)

;function probabilityVectorHebbianAdjacent
;param atom, Expression
;return Expression
(: probabilityVectorHebbianAdjacent (-> Atom Expression Expression))
(= (probabilityVectorHebbianAdjacent $source $targets)
    (let* (
        ($diffusionAvailable 1.0)
        ($atomCount (size-atom $targets))
        ($maxAllocation (/ $diffusionAvailable $atomCount))
        ($result (probabilityVectorHebbianAdjacentHelper $targets $maxAllocation $source))
                
        )
        $result
    )
)

;function probabilityVectorHebbianAdjacentHelper
;param Expression, Number, Atom
;return Expression
(: probabilityVectorHebbianAdjacentHelper (-> Expression Number Atom Number))
(= (probabilityVectorHebbianAdjacentHelper $targets $maxAllocation $source)
    (if (== $targets ())
        ()
        (let* (
            ($head (car-atom $targets))
            ($tail (cdr-atom $targets))
            ($recursive (probabilityVectorHebbianAdjacentHelper $tail $maxAllocation $source))
            ($diffusionAmount (* $maxAllocation  (calculateHebbianDiffusionPercentage $head)) )
            )
            (cons-atom ($head $diffusionAmount) $recursive)
        )
    )
)

;function combineIncidentAdjacentVectorsHelper
;param Expression, Number
;return Expression
(: combineIncidentAdjacentVectorsHelper (-> Expression Number Expression))
(= (combineIncidentAdjacentVectorsHelper $atoms $hebbianMaximumLinkAllocation)
    (if (== $atoms ())
        ()
        (let* (
                ($head (car-atom $atoms))
                ($atom-head (car-atom $head))
                ($tail-head (cdr-atom $head))
                ($val (car-atom $tail-head))
                ($tail (cdr-atom $atoms))
                ($diffusionAmount (* $hebbianMaximumLinkAllocation $val))
                ($recursive (combineIncidentAdjacentVectorsHelper $tail $hebbianMaximumLinkAllocation))
                ($map ($atom-head $diffusionAmount))
                
                
            )
            (cons-atom $map $recursive)
        )
    )
)
;function findHebbianDiffusionUsed
;param Expression Number Number
;return Number
(: findHebbianDiffusionUsed (-> Expression Number Number ))
(= (findHebbianDiffusionUsed $atoms $hebbianMaximumLinkAllocation )
    (if (== $atoms ())
        0.0
        (let* (
            ($head (car-atom $atoms))
            ($tail-head (cdr-atom $head))
            ($val (car-atom $tail-head))
            ($tail (cdr-atom $atoms))
            ($diffusionAmount (* $hebbianMaximumLinkAllocation $val))
            ($recursive (findHebbianDiffusionUsed $tail $hebbianMaximumLinkAllocation))
            )
            (+ $diffusionAmount $recursive)
        )
    )
)
;function combineIncidentAdjacentVectors
;param Expression, Expression
;return Expression

(:combineIncidentAdjacentVectors (-> Expression Expression Expression))
(= (combineIncidentAdjacentVectors $incidentVector $adjacentVector)
    (let* (
        ($diffusionAvailable 1.0)
        ($hebbianMaxAllocationPercentage 0.05) ;constant ECAN Variable
        ($hebbianDiffusionAvailable (* $hebbianMaxAllocationPercentage $diffusionAvailable))
        ($hebbianMaximumLinkAllocation (/ $hebbianDiffusionAvailable (size-atom $adjacentVector)))
        ($adjacentTarget (combineIncidentAdjacentVectorsHelper $adjacentVector $hebbianMaximumLinkAllocation))
        ($hebbianDiffusionUsed (findHebbianDiffusionUsed $adjacentVector $hebbianMaximumLinkAllocation))
        ($remainingDiffusionAvailable (- $diffusionAvailable $hebbianDiffusionUsed))
        ($incidentTarget (combineIncidentAdjacentVectorsHelper $incidentVector $remainingDiffusionAvailable))
        ($result (concatTuple $incidentTarget $adjacentTarget))

        )
        $result
    )
)
