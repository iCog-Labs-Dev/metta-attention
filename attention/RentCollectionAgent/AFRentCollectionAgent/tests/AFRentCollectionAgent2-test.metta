!(import! &self (library lib_he))
!(import! &self (library lib_spaces))

!(import! &self ../../../AttentionParam)
!(import! &self ../../../../attention-bank/utilities/helper-functions)
!(import! &self ../../../../attention-bank/attention-value/getter-and-setter)
!(import! &self ../../../../attention-bank/bank/attention-bank)
!(import! &self ../../../../attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../../../attention-bank/bank/importance-index/importance-index)
!(import! &self ../AFRentCollectionAgent2)

(= (setupAFRent2DiscoveryParams $fund $target $startingFunds $coverage)
    (let*
        (
            ($_maxAf (updateAttentionParam MAX_AF_SIZE 5.0))
            ($_fundSti (updateAttentionParam FUNDS_STI $fund))
            ($_targetSti (updateAttentionParam TARGET_STI $target))
            ($_startingSti (updateAttentionParam STARTING_FUNDS_STI $startingFunds))
            ($_bufferSti (updateAttentionParam STI_FUNDS_BUFFER 1000.0))
            ($_stiWage (updateAttentionParam STI_ATOM_WAGE 10.0))
            ($_coverage (updateAttentionParam AFRentCoverageRatio $coverage))
        )
        ()
    )
)

(= (rent2ExpectedStats $afAtoms $waAtoms)
    (let*
        (
            ($fundGap (afRentFundGap2))
            ($bufferGap (afRentBufferGap2))
            ($desiredCollection (afRentDesiredCollection2 $fundGap $bufferGap))
            ($afTotalSTI (afRentTotalSti2 $afAtoms))
            ($waTotalSTI (afRentTotalSti2 $waAtoms))
            ($totalCurrentAtomSTI (+ $afTotalSTI $waTotalSTI))
            ($afShare (afRentGroupShare2 $afTotalSTI $totalCurrentAtomSTI))
            ($waShare (afRentGroupShare2 $waTotalSTI $totalCurrentAtomSTI))
            ($afRequested (* $desiredCollection $afShare))
            ($waRequested (* $desiredCollection $waShare))
            ($afPerAtomRent (afRentPerAtomRent2 $afAtoms $afRequested))
            ($waPerAtomRent (afRentPerAtomRent2 $waAtoms $waRequested))
            ($afCollected (afRentGroupCollected2 $afAtoms $afPerAtomRent))
            ($waCollected (afRentGroupCollected2 $waAtoms $waPerAtomRent))
            ($totalCollected (+ $afCollected $waCollected))
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

(= (rent2StatsAfCollected
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
        (totalCollected $totalCollected)))
    $afCollected
)

(= (rent2StatsWaCollected
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
        (totalCollected $totalCollected)))
    $waCollected
)

(= (rent2StatsTotalCollected
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
        (totalCollected $totalCollected)))
    $totalCollected
)

(= (rent2AllNonNegative ()) True)
(= (rent2AllNonNegative (cons $head $tail))
    (and (>= (getSti $head) 0.0) (rent2AllNonNegative $tail))
)





(= (assertAgentCollectsDesiredRent2
        $expectedPreFund
        $expectedFundGap
        $expectedBufferGap
        $expectedDesiredCollection
        $expectedAfTotalSTI
        $expectedWaTotalSTI
        $expectedAfShare
        $expectedWaShare
        $expectedAfCollected
        $expectedWaCollected
        $expectedPostFund)
    (let*
        (
            ($preFund (getAttentionParam FUNDS_STI))
            ($fundGap (afRentFundGap2))
            ($bufferGap (afRentBufferGap2))
            ($desiredCollection (afRentDesiredCollection2 $fundGap $bufferGap))
            ($afAtoms (getAfAtoms))
            ($waAtoms (afRentWATargets2 $afAtoms))
            ($afTotalSTI (afRentTotalSti2 $afAtoms))
            ($waTotalSTI (afRentTotalSti2 $waAtoms))
            ($totalCurrentAtomSTI (+ $afTotalSTI $waTotalSTI))
            ($afShare (afRentGroupShare2 $afTotalSTI $totalCurrentAtomSTI))
            ($waShare (afRentGroupShare2 $waTotalSTI $totalCurrentAtomSTI))
            ($afRequested (* $desiredCollection $afShare))
            ($waRequested (* $desiredCollection $waShare))
            ($afPerAtomRent (afRentPerAtomRent2 $afAtoms $afRequested))
            ($waPerAtomRent (afRentPerAtomRent2 $waAtoms $waRequested))
            ($afCollected (afRentGroupCollected2 $afAtoms $afPerAtomRent))
            ($waCollected (afRentGroupCollected2 $waAtoms $waPerAtomRent))
            ($totalCollected (+ $afCollected $waCollected))
            ($_preFund (test (approxEqual $preFund $expectedPreFund 0.1) True))
            ($_fundGap (test (approxEqual $fundGap $expectedFundGap 0.1) True))
            ($_bufferGap (test (approxEqual $bufferGap $expectedBufferGap 0.1) True))
            ($_desiredCollection (test (approxEqual $desiredCollection $expectedDesiredCollection 0.1) True))
            ($_afSize (test (size-atom $afAtoms) 5))
            ($_waSize (test (size-atom $waAtoms) 6))
            ($_afTotal (test (approxEqual $afTotalSTI $expectedAfTotalSTI 0.1) True))
            ($_waTotal (test (approxEqual $waTotalSTI $expectedWaTotalSTI 0.1) True))
            ($_afShare (test (approxEqual $afShare $expectedAfShare 0.001) True))
            ($_waShare (test (approxEqual $waShare $expectedWaShare 0.001) True))
            ($_afCollected (test (approxEqual $afCollected $expectedAfCollected 0.1) True))
            ($_waCollected (test (approxEqual $waCollected $expectedWaCollected 0.1) True))
            ($_totalCollected (test (approxEqual $totalCollected $desiredCollection 0.1) True))
            ($_run (AFRentCollectionAgent2-run))
            ($postFund (getAttentionParam FUNDS_STI))
            ($_delta (test (approxEqual (- $postFund $preFund) $desiredCollection 0.1) True))
            ($_postFund (test (approxEqual $postFund $expectedPostFund 0.1) True))
            ($_nonNegative (test (rent2AllNonNegative (getAllAtomsWithBins)) True))
        )
        ()
    )
)

!(setupAFRent2DiscoveryParams 10000.0 5000.0 10000.0 0.10)

; Stimulate atoms with different strengths and call the rent agent after each
; stimulation, as in the dynamicity flow. The first nine calls should not
; collect rent because the fund is still above the target.
!(stimulate rent2_e2e_a 32.0) ; 640
!(AFRentCollectionAgent2-run)
!(test (approxEqual (getAttentionParam FUNDS_STI) 9360.0 0.1) True)
!(stimulate rent2_e2e_b 30.0) ; 600
!(AFRentCollectionAgent2-run)
!(test (approxEqual (getAttentionParam FUNDS_STI) 8760.0 0.1) True)
!(stimulate rent2_e2e_c 28.0) ; 560
!(AFRentCollectionAgent2-run)
!(test (approxEqual (getAttentionParam FUNDS_STI) 8200.0 0.1) True)
!(stimulate rent2_e2e_d 26.0) ; 520
!(AFRentCollectionAgent2-run)
!(test (approxEqual (getAttentionParam FUNDS_STI) 7680.0 0.1) True)
!(stimulate rent2_e2e_e 24.0) ; 480
!(AFRentCollectionAgent2-run)
!(test (approxEqual (getAttentionParam FUNDS_STI) 7200.0 0.1) True)
!(stimulate rent2_e2e_f 22.0) ; 440
!(AFRentCollectionAgent2-run)
!(test (approxEqual (getAttentionParam FUNDS_STI) 6760.0 0.1) True)
!(stimulate rent2_e2e_g 21.0) ; 420
!(AFRentCollectionAgent2-run)
!(test (approxEqual (getAttentionParam FUNDS_STI) 6340.0 0.1) True)
!(stimulate rent2_e2e_h 21.0) ; 420
!(AFRentCollectionAgent2-run)
!(test (approxEqual (getAttentionParam FUNDS_STI) 5920.0 0.1) True)
!(stimulate rent2_e2e_i 21.0) ; 403.2
!(test (approxEqual (getSti rent2_e2e_i) 403.2 0.1) True)
!(test (approxEqual (getAttentionParam FUNDS_STI) 5516.8 0.1) True)
!(AFRentCollectionAgent2-run)
!(test (approxEqual (getAttentionParam FUNDS_STI) 5516.8 0.1) True)

!(stimulate rent2_e2e_j 21.0) ; 318.528
!(test (approxEqual (getSti rent2_e2e_j) 318.528 0.1) True)
!(test (approxEqual (getAttentionParam FUNDS_STI) 5198.272 0.1) True)

!(stimulate rent2_e2e_k 21.0) ; 251.63712
!(test (approxEqual (getSti rent2_e2e_k) 251.63712 0.1) True)


!(assertAgentCollectsDesiredRent2
    4946.63488
    53.36512
    5000.0
    553.36512
    2800.0
    2253.36512
    0.5540862
    0.4459138
    306.61199
    246.75313
    5500.0)


