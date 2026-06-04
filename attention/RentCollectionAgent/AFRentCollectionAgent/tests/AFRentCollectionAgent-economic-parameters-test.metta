!(import! &self lib/lib_he)
!(import! &self lib/lib_spaces)
!(import! &self ../../../AttentionParam)
!(import! &self ../../../baching)
!(import! &self ../../../../attention-bank/utilities/helper-functions)
!(import! &self ../../../../attention-bank/attention-value/getter-and-setter)
!(import! &self ../../../../attention-bank/bank/attention-bank)
!(import! &self ../../../../attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../../../attention-bank/bank/importance-index/importance-index)
!(import! &self ../../../Neighbors)
!(import! &self ../../RentCollectionBaseAgent/RentCollectionBaseAgent)
!(import! &self ../AFRentCollectionAgent)

; These tests isolate the economic parameters from machine runtime.
; All rent calls use AFRentFrequency = 10Hz and elapsed time = 0.25 seconds.
; Therefore threshold = 0.1 seconds and timer weight = 0.25 * 10 = 2.5.

(= (setAFRentElapsedSeconds $seconds)
    (let $now (timeTime)
        (setLastUpdate (- $now $seconds))
    )
)

(= (setupAFRentParams $fund $target $buffer)
    (let*
        (
            ($_fundSti (updateAttentionParam FUNDS_STI $fund))
            ($_fundLti (updateAttentionParam FUNDS_LTI $fund))
            ($_targetSti (updateAttentionParam TARGET_STI $target))
            ($_targetLti (updateAttentionParam TARGET_LTI $target))
            ($_bufferSti (updateAttentionParam STI_FUNDS_BUFFER $buffer))
            ($_bufferLti (updateAttentionParam LTI_FUNDS_BUFFER $buffer))
            ($_stiRent (updateAttentionParam StartingAtomStiRent 1.0))
            ($_ltiRent (updateAttentionParam StartingAtomLtiRent 1.0))
            ($_freq (updateAttentionParam AFRentFrequency 10.0))
            ($_afSize (updateAttentionParam MAX_AF_SIZE 20.0))
            ($_first (setFirstTime False))
        )
        ()
    )
)

(= (setupOneAFRentProbe $fund $target $buffer)
    (let*
        (
            ($_a (setAv rent_param_a (100.0 100.0 0.0)))
            ($_params (setupAFRentParams $fund $target $buffer))
        )
        ()
    )
)

(= (setupFiveAFRentProbe $fund $target $buffer)
    (let*
        (
            ($_a (setAv rent_param_a (100.0 100.0 0.0)))
            ($_b (setAv rent_param_b (100.0 100.0 0.0)))
            ($_c (setAv rent_param_c (100.0 100.0 0.0)))
            ($_d (setAv rent_param_d (100.0 100.0 0.0)))
            ($_e (setAv rent_param_e (100.0 100.0 0.0)))
            ($_params (setupAFRentParams $fund $target $buffer))
        )
        ()
    )
)

(= (runAFRentProbe $targetSet)
    (let*
        (
            ($_elapsed (setAFRentElapsedSeconds 0.25))
            ($_run (collapse (collectAFRent $targetSet)))
        )
        ()
    )
)

(= (runOneAFRentAtWeight)
    (applyRent 2.5 rent_param_a)
)

(= (runFiveAFRentAtWeight)
    (let*
        (
            ($_a (applyRent 2.5 rent_param_a))
            ($_b (applyRent 2.5 rent_param_b))
            ($_c (applyRent 2.5 rent_param_c))
            ($_d (applyRent 2.5 rent_param_d))
            ($_e (applyRent 2.5 rent_param_e))
        )
        ()
    )
)

; =================== FUNDS_STI vs TARGET_STI ===================
; If FUNDS_STI is already at or above TARGET_STI, calculateStiRent returns 0.0.
; Rent does not run even though the timer threshold is satisfied.
!(setupOneAFRentProbe 1000.0 1000.0 1000.0)
!(runAFRentProbe (rent_param_a))
!(test (getSti rent_param_a) 100.0)
!(test (getAttentionParam FUNDS_STI) 1000.0)

!(setupOneAFRentProbe 1100.0 1000.0 1000.0)
!(runAFRentProbe (rent_param_a))
!(test (getSti rent_param_a) 100.0)
!(test (getAttentionParam FUNDS_STI) 1100.0)

; Lower funds below the target produce higher rent.
; fund=990: base rent = 1 + ((1000 - 990) / 1000) = 1.01
; collected STI = 1.01 * 2.5 = 2.525
!(setupOneAFRentProbe 990.0 1000.0 1000.0)
!(runAFRentProbe (rent_param_a))
!(test (approxEqual (getSti rent_param_a) 97.475 0.1) True)
!(test (approxEqual (getAttentionParam FUNDS_STI) 992.525 0.1) True)

; fund=900: base rent = 1 + ((1000 - 900) / 1000) = 1.1
; collected STI = 1.1 * 2.5 = 2.75
!(setupOneAFRentProbe 900.0 1000.0 1000.0)
!(runAFRentProbe (rent_param_a))
!(test (approxEqual (getSti rent_param_a) 97.25 0.1) True)
!(test (approxEqual (getAttentionParam FUNDS_STI) 902.75 0.1) True)

; =================== STI_FUNDS_BUFFER ===================
; Smaller buffer makes the same fund gap more urgent.
; gap=100, buffer=100: base rent clamps to 2.0, collected STI = 5.0
!(setupOneAFRentProbe 900.0 1000.0 100.0)
!(runAFRentProbe (rent_param_a))
!(test (approxEqual (getSti rent_param_a) 95.0 0.1) True)
!(test (approxEqual (getAttentionParam FUNDS_STI) 905.0 0.1) True)

; gap=100, buffer=5000: base rent = 1.02, collected STI = 2.55
!(setupOneAFRentProbe 900.0 1000.0 5000.0)
!(runAFRentProbe (rent_param_a))
!(test (approxEqual (getSti rent_param_a) 97.45 0.1) True)
!(test (approxEqual (getAttentionParam FUNDS_STI) 902.55 0.1) True)

; =================== TARGET_STI ===================
; If target is below current fund, rent is zero.
!(setupOneAFRentProbe 900.0 500.0 1000.0)
!(runAFRentProbe (rent_param_a))
!(test (getSti rent_param_a) 100.0)
!(test (getAttentionParam FUNDS_STI) 900.0)

; If target is much higher, base rent clamps to 2.0.
; target=2000, fund=900, buffer=1000: gap=1100 -> clamp to 1.0
; collected STI = 2.0 * 2.5 = 5.0
!(setupOneAFRentProbe 900.0 2000.0 1000.0)
!(runAFRentProbe (rent_param_a))
!(test (approxEqual (getSti rent_param_a) 95.0 0.1) True)
!(test (approxEqual (getAttentionParam FUNDS_STI) 905.0 0.1) True)

; =================== AF atom count ===================
; More atoms in the rent target set return more total STI to the global fund.
; This section calls applyRent directly with weight=2.5, the same weight
; produced above by elapsedTime=0.25 and AFRentFrequency=10.
; With one atom, ending fund is about 902.75.
!(setupOneAFRentProbe 900.0 1000.0 1000.0)
!(runOneAFRentAtWeight)
!(test (approxEqual (getAttentionParam FUNDS_STI) 902.75 0.1) True)

; With five atoms, ending fund is about 913.7.
; It is not exactly 900 + (5 * 2.75), because each atom updates FUNDS_STI
; and the next atom sees a slightly smaller fund gap.
!(setupFiveAFRentProbe 900.0 1000.0 1000.0)
!(runFiveAFRentAtWeight)
!(test (approxEqual (getAttentionParam FUNDS_STI) 913.7 0.3) True)
!(test (> (getAttentionParam FUNDS_STI) 902.75) True)
