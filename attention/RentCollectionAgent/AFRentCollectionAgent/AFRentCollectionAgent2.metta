; AFRentCollectionAgent2
; Cycle-based rent prototype with a dynamic STI floor.
;
; This version removes wall-clock elapsed time from AF rent collection.
; It collects rent only when FUNDS_STI is below TARGET_STI.
;
; fundGap = max(0, TARGET_STI - FUNDS_STI)
; desiredCollection = AFRentCoverageRatio * fundGap
;
; The floor is not a fixed STI parameter. It is the current minimum STI among
; the AF atoms being charged. Rent is only collected from the capacity above
; that floor, so the weakest atom(s) are preserved instead of being drained.
;
; floorSti = min(STI_i for i in AF)
; capacity_i = max(0, STI_i - floorSti)
; totalCapacity = sum(capacity_i)
; collectionBudget = min(desiredCollection,
;                        AFRentMaxCollectionRate * totalCapacity)
; rent_i = collectionBudget * capacity_i / totalCapacity

(= (selectAFTargets2)
    (getAfAtoms)
)

(= (afRentFundGap2)
    (let*
        (
            ($funds (getAttentionParam FUNDS_STI))
            ($target (getAttentionParam TARGET_STI))
        )
        (max-atom (0.0 (- $target $funds)))
    )
)

(= (afRentDesiredCollection2 $fundGap)
    (* (getAttentionParam AFRentCoverageRatio) $fundGap)
)

(= (afRentStis2 $targetSet)
    (collapse
        (let $atom (superpose $targetSet)
            (getSti $atom)
        )
    )
)

(= (afRentMinSti2 $targetSet)
    (min-atom (afRentStis2 $targetSet))
)

(= (afRentCapacity2 $atom $floorSti)
    (max-atom (0.0 (- (getSti $atom) $floorSti)))
)

(= (afRentTotalCapacity2 () $floorSti) 0.0)
(= (afRentTotalCapacity2 (cons $head $tail) $floorSti)
    (+ (afRentCapacity2 $head $floorSti) (afRentTotalCapacity2 $tail $floorSti))
)

(= (afRentCollectionBudget2 $desiredCollection $totalCapacity)
    (min-atom
        (
            $desiredCollection
            (* (getAttentionParam AFRentMaxCollectionRate) $totalCapacity)
        )
    )
)

(= (afRentAtomRent2 $atom $floorSti $collectionBudget $totalCapacity)
    (if (<= $totalCapacity 0.0)
        0.0
        (* $collectionBudget (/ (afRentCapacity2 $atom $floorSti) $totalCapacity))
    )
)

(= (applyAFRent2 $atom $floorSti $collectionBudget $totalCapacity)
    (let*
        (
            ($sti (getSti $atom))
            ($lti (getLti $atom))
            ($vlti (getVlti $atom))
            ($rent (min-atom ($sti (afRentAtomRent2 $atom $floorSti $collectionBudget $totalCapacity))))
            ($newSti (- $sti $rent))
        )
        (setAv $atom ($newSti $lti $vlti))
    )
)

(= (collectAFRent2 $targetSet)
    (let*
        (
            ($fundGap (afRentFundGap2))
            ($desiredCollection (afRentDesiredCollection2 $fundGap))
        )
        (if (or (== $targetSet ()) (<= $fundGap 0.0))
            (empty)
            (let*
                (
                    ($floorSti (afRentMinSti2 $targetSet))  
                    ($totalCapacity (afRentTotalCapacity2 $targetSet $floorSti))
                    ($collectionBudget (afRentCollectionBudget2 $desiredCollection $totalCapacity))
                    ($_apply
                        (collapse
                            (let $atom (superpose $targetSet)
                                (applyAFRent2 $atom $floorSti $collectionBudget $totalCapacity)
                            )
                        )
                    )
                )
                (AFRent2Stats
                    (fundGap $fundGap)
                    (desiredCollection $desiredCollection)
                    (floorSti $floorSti)
                    (totalCapacity $totalCapacity)
                    (collectionBudget $collectionBudget)
                    (totalCollected $collectionBudget)
                )
            )
        )
    )
)

(= (AFRentCollectionAgent2-run)
    (with_mutex afrmutex2 
        (let $targets 
            (getAfAtoms) 
            (if (== $targets ()) 
                (empty) 
                (let $_stats
                    (collectAFRent2 $targets)
                    ()
                )
            )
        )
))
