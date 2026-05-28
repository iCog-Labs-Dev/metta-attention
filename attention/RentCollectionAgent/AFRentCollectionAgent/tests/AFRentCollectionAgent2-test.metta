!(import! &self lib/lib_he)
!(import! &self lib/lib_spaces)
!(import! &self ../../../AttentionParam)
!(import! &self ../../../../attention-bank/utilities/helper-functions)
!(import! &self ../../../../attention-bank/attention-value/getter-and-setter)
!(import! &self ../../../../attention-bank/bank/attention-bank)
!(import! &self ../../../../attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../../../attention-bank/bank/importance-index/importance-index)
!(import! &self ../AFRentCollectionAgent2)

(= (setupAFRent2Probe $fund $target $coverage $maxRate $stiA $stiB $stiC)
    (let*
        (
            ($_maxAf (updateAttentionParam MAX_AF_SIZE 20.0))
            ($_a (setAv rent2_a ($stiA 0.0 0.0)))
            ($_b (setAv rent2_b ($stiB 0.0 0.0)))
            ($_c (setAv rent2_c ($stiC 0.0 0.0)))
            ($_fundSti (updateAttentionParam FUNDS_STI $fund))
            ($_targetSti (updateAttentionParam TARGET_STI $target))
            ($_coverage (updateAttentionParam AFRentCoverageRatio $coverage))
            ($_maxRate (updateAttentionParam AFRentMaxCollectionRate $maxRate))
        )
        ()
    )
)

; fundGap=100, desiredCollection=100.
; stis=(20,100,200), floorSti=20.
; rent capacity=(0,80,180), totalCapacity=260.
; rent2_a is the dynamic floor atom, so it pays 0 and stays at 20.
; With maxRate=1.0, collectionBudget=100 and the fund reaches target.
!(setupAFRent2Probe 900.0 1000.0 1.0 1.0 20.0 100.0 200.0)
!(test (collectAFRent2 (rent2_a rent2_b rent2_c))
    (AFRent2Stats
        (fundGap 100.0)
        (desiredCollection 100.0)
        (floorSti 20.0)
        (totalCapacity 260.0)
        (collectionBudget 100.0)
        (totalCollected 100.0)
    )
)
!(test (approxEqual (getAttentionParam FUNDS_STI) 1000.0 0.1) True)
!(test (getSti rent2_a) 20.0)
!(test (approxEqual (getSti rent2_b) 69.2308 0.1) True)
!(test (approxEqual (getSti rent2_c) 130.7692 0.1) True)

; Same setup, but maxRate=0.25 caps collectionBudget at 65.
; The floor atom is still protected, so the fund only improves to 965 this cycle.
!(setupAFRent2Probe 900.0 1000.0 1.0 0.25 20.0 100.0 200.0)
!(test (collectAFRent2 (rent2_a rent2_b rent2_c))
    (AFRent2Stats
        (fundGap 100.0)
        (desiredCollection 100.0)
        (floorSti 20.0)
        (totalCapacity 260.0)
        (collectionBudget 65.0)
        (totalCollected 65.0)
    )
)
!(test (approxEqual (getAttentionParam FUNDS_STI) 965.0 0.1) True)
!(test (getSti rent2_a) 20.0)
!(test (approxEqual (getSti rent2_b) 80.0 0.1) True)
!(test (approxEqual (getSti rent2_c) 155.0 0.1) True)

; Multiple weakest atoms share the floor and both pay 0.
; stis=(20,20,100), floorSti=20, totalCapacity=80.
; Even with maxRate=1.0, only 80 can be collected while preserving the floor.
!(setupAFRent2Probe 900.0 1000.0 1.0 1.0 20.0 20.0 100.0)
!(test (collectAFRent2 (rent2_a rent2_b rent2_c))
    (AFRent2Stats
        (fundGap 100.0)
        (desiredCollection 100.0)
        (floorSti 20.0)
        (totalCapacity 80.0)
        (collectionBudget 80.0)
        (totalCollected 80.0)
    )
)
!(test (approxEqual (getAttentionParam FUNDS_STI) 980.0 0.1) True)
!(test (getSti rent2_a) 20.0)
!(test (getSti rent2_b) 20.0)
!(test (approxEqual (getSti rent2_c) 20.0 0.1) True)

; If every target atom has the same STI, the dynamic floor equals every atom's
; STI, totalCapacity is zero, and no rent can be collected safely.
!(setupAFRent2Probe 900.0 1000.0 1.0 1.0 20.0 20.0 20.0)
!(test (collectAFRent2 (rent2_a rent2_b rent2_c))
    (AFRent2Stats
        (fundGap 100.0)
        (desiredCollection 100.0)
        (floorSti 20.0)
        (totalCapacity 0.0)
        (collectionBudget 0.0)
        (totalCollected 0.0)
    )
)
!(test (approxEqual (getAttentionParam FUNDS_STI) 900.0 0.1) True)
!(test (getSti rent2_a) 20.0)
!(test (getSti rent2_b) 20.0)
!(test (getSti rent2_c) 20.0)

; No deficit: no rent.
!(setupAFRent2Probe 1000.0 1000.0 1.0 1.0 20.0 100.0 200.0)
!(test (collectAFRent2 (rent2_a rent2_b rent2_c)) ())
!(test (getAttentionParam FUNDS_STI) 1000.0)
