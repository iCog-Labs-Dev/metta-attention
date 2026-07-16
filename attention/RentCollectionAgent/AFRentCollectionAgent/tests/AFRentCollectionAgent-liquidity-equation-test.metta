!(import! &self lib/lib_he)
!(import! &self lib/lib_spaces)
!(import! &self ../../../AttentionParam)
!(import! &self ../../../../attention-bank/utilities/helper-functions)
!(import! &self ../../../../attention-bank/attention-value/getter-and-setter)
!(import! &self ../../../../attention-bank/bank/attention-bank)
!(import! &self ../../../../attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../../../attention-bank/bank/importance-index/importance-index)

; Prototype test for a liquidity-style rent equation.
; This does not replace AFRentCollectionAgent yet; it characterizes the proposed
; cycle-based equation before wiring it into the agent.
;
; requiredFund = max(TARGET_STI, coverageRatio * expectedOutflow)
; deficit = max(0, requiredFund - FUNDS_STI)
; capacity_i = max(0, STI_i - STI_floor)
; rentBudget = min(deficit, maxCollectionRate * totalCapacity)
; rent_i = rentBudget * capacity_i / totalCapacity

(= (liquidityRequiredFund $target $coverageRatio $expectedOutflow)
    (max-atom ($target (* $coverageRatio $expectedOutflow)))
)

(= (liquidityDeficit $fund $requiredFund)
    (max-atom (0.0 (- $requiredFund $fund)))
)

(= (liquidityCapacity $sti $stiFloor)
    (max-atom (0.0 (- $sti $stiFloor)))
)

(= (liquidityRentBudget $deficit $maxCollectionRate $totalCapacity)
    (min-atom ($deficit (* $maxCollectionRate $totalCapacity)))
)

(= (liquidityProportionalRent $rentBudget $capacity $totalCapacity)
    (if (<= $totalCapacity 0.0)
        0.0
        (* $rentBudget (/ $capacity $totalCapacity))
    )
)

(= (setupLiquidityProbe3 $fund $stiA $stiB $stiC)
    (let*
        (
            ($_a (setAv liquidity_a ($stiA 0.0 0.0)))
            ($_b (setAv liquidity_b ($stiB 0.0 0.0)))
            ($_c (setAv liquidity_c ($stiC 0.0 0.0)))
            ($_fundSti (updateAttentionParam FUNDS_STI $fund))
            ($_fundLti (updateAttentionParam FUNDS_LTI 1000.0))
        )
        ()
    )
)

(= (applyLiquidityAtomRent $atom $rent)
    (let*
        (
            ($sti (getSti $atom))
            ($lti (getLti $atom))
            ($vlti (getVlti $atom))
            ($paid (min-atom ($rent $sti)))
            ($newSti (- $sti $paid))
        )
        (setAv $atom ($newSti $lti $vlti))
    )
)

(= (applyLiquidityRent3 $requiredFund $stiFloor $maxCollectionRate)
    (let*
        (
            ($fund (getAttentionParam FUNDS_STI))
            ($deficit (liquidityDeficit $fund $requiredFund))
            ($capA (liquidityCapacity (getSti liquidity_a) $stiFloor))
            ($capB (liquidityCapacity (getSti liquidity_b) $stiFloor))
            ($capC (liquidityCapacity (getSti liquidity_c) $stiFloor))
            ($totalCapacity (+ $capA (+ $capB $capC)))
            ($budget (liquidityRentBudget $deficit $maxCollectionRate $totalCapacity))
            ($rentA (liquidityProportionalRent $budget $capA $totalCapacity))
            ($rentB (liquidityProportionalRent $budget $capB $totalCapacity))
            ($rentC (liquidityProportionalRent $budget $capC $totalCapacity))
            ($_a (applyLiquidityAtomRent liquidity_a $rentA))
            ($_b (applyLiquidityAtomRent liquidity_b $rentB))
            ($_c (applyLiquidityAtomRent liquidity_c $rentC))
        )
        ($budget $rentA $rentB $rentC)
    )
)

; =================== required fund and deficit ===================
!(test (liquidityRequiredFund 1000.0 1.2 500.0) 1000.0)
!(test (liquidityRequiredFund 1000.0 1.2 1000.0) 1200.0)
!(test (liquidityDeficit 900.0 1000.0) 100.0)
!(test (liquidityDeficit 1100.0 1000.0) 0.0)

; =================== atom capacity and rent budget ===================
!(test (liquidityCapacity 100.0 50.0) 50.0)
!(test (liquidityCapacity 40.0 50.0) 0.0)
!(test (liquidityRentBudget 100.0 0.5 250.0) 100.0)
!(test (liquidityRentBudget 100.0 0.2 250.0) 50.0)

; =================== fund repair when atoms can afford it ===================
; fund=900, required=1000, deficit=100.
; atoms: 100, 100, 200. floor=50 gives capacities 50, 50, 150.
; totalCapacity=250, maxCollectionRate=0.5, max collectible=125.
; rentBudget=min(100, 125)=100.
; rents: 20, 20, 60.
!(setupLiquidityProbe3 900.0 100.0 100.0 200.0)
!(test (applyLiquidityRent3 1000.0 50.0 0.5) (100.0 20.0 20.0 60.0))
!(test (approxEqual (getAttentionParam FUNDS_STI) 1000.0 0.1) True)
!(test (approxEqual (getSti liquidity_a) 80.0 0.1) True)
!(test (approxEqual (getSti liquidity_b) 80.0 0.1) True)
!(test (approxEqual (getSti liquidity_c) 140.0 0.1) True)

; =================== atom protection when atoms are poor ===================
; fund=900, required=1000, deficit=100.
; atoms: 55, 55, 55. floor=50 gives totalCapacity=15.
; maxCollectionRate=0.5 means only 7.5 STI can be collected this cycle.
; each atom pays 2.5 and remains above the floor.
!(setupLiquidityProbe3 900.0 55.0 55.0 55.0)
!(test (applyLiquidityRent3 1000.0 50.0 0.5) (7.5 2.5 2.5 2.5))
!(test (approxEqual (getAttentionParam FUNDS_STI) 907.5 0.1) True)
!(test (approxEqual (getSti liquidity_a) 52.5 0.1) True)
!(test (approxEqual (getSti liquidity_b) 52.5 0.1) True)
!(test (approxEqual (getSti liquidity_c) 52.5 0.1) True)

; =================== no deficit means no rent ===================
!(setupLiquidityProbe3 1000.0 100.0 100.0 200.0)
!(test (applyLiquidityRent3 1000.0 50.0 0.5) (0.0 0.0 0.0 0.0))
!(test (getAttentionParam FUNDS_STI) 1000.0)
