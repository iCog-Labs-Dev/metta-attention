; AFRentCollectionAgent2
; Cycle-based STI rent collection.
;
; Rent is collected only when FUNDS_STI is below TARGET_STI.
;
; fundGap = max(0, TARGET_STI - FUNDS_STI)
; bufferGap = max(0, STARTING_FUNDS_STI - TARGET_STI)
; desiredCollection = fundGap + AFRentCoverageRatio * bufferGap
;
; The desired collection is split between atoms in attentional focus and atoms
; outside attentional focus according to each group's STI at the start of the
; cycle. Inside each group, rent is charged equally per atom and capped by the
; atom's current STI, so atoms can reach 0.0 STI but never go negative.

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

(= (afRentBufferGap2)
    (let*
        (
            ($startingFunds (getAttentionParam STARTING_FUNDS_STI))
            ($target (getAttentionParam TARGET_STI))
        )
        (max-atom (0.0 (- $startingFunds $target)))
    )
)

(= (afRentDesiredCollection2 $fundGap $bufferGap)
    (if (<= $fundGap 0.0)
        0.0
        (+ $fundGap (* (getAttentionParam AFRentCoverageRatio) $bufferGap))
    )
)

(= (afRentDesiredCollection2 $fundGap)
    (afRentDesiredCollection2 $fundGap (afRentBufferGap2))
)

(= (afRentStis2 $targetSet)
    (collapse
        (let $atom (superpose $targetSet)
            (getSti $atom)
        )
    )
)

(= (afRentTotalSti2 ()) 0.0)
(= (afRentTotalSti2 (cons $head $tail))
    (+ (getSti $head) (afRentTotalSti2 $tail))
)

(= (afRentGroupShare2 $groupTotalSTI $totalCurrentAtomSTI)
    (if (<= $totalCurrentAtomSTI 0.0)
        0.0
        (/ $groupTotalSTI $totalCurrentAtomSTI)
    )
)

(= (afRentPerAtomRent2 $targetSet $requestedCollection)
    (if (or (== $targetSet ()) (<= $requestedCollection 0.0))
        0.0
        (/ $requestedCollection (size-atom $targetSet))
    )
)

(= (afRentAtomRent2 $atom $perAtomRent)
    (min-atom ((getSti $atom) $perAtomRent))
)

(= (afRentGroupCollected2 () $perAtomRent) 0.0)
(= (afRentGroupCollected2 (cons $head $tail) $perAtomRent)
    (+ (afRentAtomRent2 $head $perAtomRent) (afRentGroupCollected2 $tail $perAtomRent))
)

(= (applyAFRent2 $atom $perAtomRent)
    (let*
        (
            ($sti (getSti $atom))
            ($lti (getLti $atom))
            ($vlti (getVlti $atom))
            ($rent (afRentAtomRent2 $atom $perAtomRent))
            ($newSti (- $sti $rent))
        )
        (setAv $atom ($newSti $lti $vlti))
    )
)

(= (applyAFRentGroup2 $targetSet $perAtomRent)
    (if (or (== $targetSet ()) (<= $perAtomRent 0.0))
        ()
        (collapse
            (let $atom (superpose $targetSet)
                (applyAFRent2 $atom $perAtomRent)
            )
        )
    )
)

(= (afRentWATargets2 $afAtoms)
    (subtraction-atom (getAllAtomsWithBins) $afAtoms)
)

(= (collectAFRent2ForGroups $afAtoms $waAtoms)
    (let*
        (
            ($fundGap (afRentFundGap2))
            ($bufferGap (afRentBufferGap2))
            ($desiredCollection (afRentDesiredCollection2 $fundGap $bufferGap))
        )
        (if (== $fundGap 0.0)
            ()
            (let*
                (
                    ($afTotalSTI (afRentTotalSti2 $afAtoms))
                    ($waTotalSTI (afRentTotalSti2 $waAtoms))
                    ($totalCurrentAtomSTI (+ $afTotalSTI $waTotalSTI))
                )
                (if (<= $totalCurrentAtomSTI 0.0)
                    ()
                    (let*
                        (
                            ($afShare (afRentGroupShare2 $afTotalSTI $totalCurrentAtomSTI))
                            ($waShare (afRentGroupShare2 $waTotalSTI $totalCurrentAtomSTI))
                            ($afRequested (* $desiredCollection $afShare))
                            ($waRequested (* $desiredCollection $waShare))
                            ($afPerAtomRent (afRentPerAtomRent2 $afAtoms $afRequested))
                            ($waPerAtomRent (afRentPerAtomRent2 $waAtoms $waRequested))
                            ($afCollected (afRentGroupCollected2 $afAtoms $afPerAtomRent))
                            ($waCollected (afRentGroupCollected2 $waAtoms $waPerAtomRent))
                            ($totalCollected (+ $afCollected $waCollected))
                            ($_waApply (applyAFRentGroup2 $waAtoms $waPerAtomRent))
                            ($_afApply (applyAFRentGroup2 $afAtoms $afPerAtomRent))
                        )
                        (AFRent2Stats
                            (fundGap $fundGap)
                            (bufferGap $bufferGap)
                            (desiredCollection $desiredCollection)
                            (afTotalSTI $afTotalSTI)
                            (waTotalSTI $waTotalSTI)
                            (totalCurrentAtomSTI $totalCurrentAtomSTI)
                            (afShare $afShare)
                            (waShare $waShare)
                            (afRequested $afRequested)
                            (waRequested $waRequested)
                            (afCollected $afCollected)
                            (waCollected $waCollected)
                            (totalCollected $totalCollected)
                        )
                    )
                )
            )
        )
    )
)

(= (collectAFRent2 $targetSet)
    (let $waAtoms
        (afRentWATargets2 $targetSet)
        (collectAFRent2ForGroups $targetSet $waAtoms)
    )
)

(= (AFRentCollectionAgent2-run)
    (with_mutex afrmutex2
        (let $_stats
            (collectAFRent2 (getAfAtoms))
            ()
        )
    )
)
