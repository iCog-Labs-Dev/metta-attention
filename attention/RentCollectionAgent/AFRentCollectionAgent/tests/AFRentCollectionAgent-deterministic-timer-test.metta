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

; The probe keeps this test deterministic:
; STI/LTI = 100, funds = 900, target = 1000, buffer = 1000.
; calculateStiRent and calculateLtiRent therefore start at 1.1.
(= (resetAFRentProbe)
    (let*
        (
            ($_setAv (setAv afr_timer_probe (100.0 100.0 0.0)))
            ($_fundSti (updateAttentionParam FUNDS_STI 900.0))
            ($_fundLti (updateAttentionParam FUNDS_LTI 900.0))
            ($_targetSti (updateAttentionParam TARGET_STI 1000.0))
            ($_targetLti (updateAttentionParam TARGET_LTI 1000.0))
            ($_bufferSti (updateAttentionParam STI_FUNDS_BUFFER 1000.0))
            ($_bufferLti (updateAttentionParam LTI_FUNDS_BUFFER 1000.0))
            ($_stiRent (updateAttentionParam StartingAtomStiRent 1.0))
            ($_ltiRent (updateAttentionParam StartingAtomLtiRent 1.0))
            ($_afSize (updateAttentionParam MAX_AF_SIZE 10.0))
        )
        ()
    )
)

(= (setAFRentElapsedSeconds $seconds)
    (let $now (timeTime)
        (setLastUpdate (- $now $seconds))
    )
)

; First AFRentCollectionAgent-run only flips firstTime to False.
; It does not collect rent, even if elapsed time is already above threshold.
!(resetAFRentProbe)
!(updateAttentionParam AFRentFrequency 5.0)
!(setAFRentElapsedSeconds 0.5)
!(test (match &timer (firstTime $x) $x) True)
!(AFRentCollectionAgent-run)
!(test (match &timer (firstTime $x) $x) False)
!(test (getSti afr_timer_probe) 100.0)
!(test (getAttentionParam FUNDS_STI) 900.0)

; AFRentFrequency = 5Hz gives threshold = 1 / 5 = 0.2 seconds.
; An elapsed time below that threshold collects no rent.
!(resetAFRentProbe)
!(updateAttentionParam AFRentFrequency 5.0)
!(setAFRentElapsedSeconds 0.1)
!(AFRentCollectionAgent-run)
!(test (getSti afr_timer_probe) 100.0)
!(test (getAttentionParam FUNDS_STI) 900.0)

; Same frequency, elapsed time above threshold:
; w = elapsed * frequency = 0.25 * 5 = 1.25.
; rent = 1.1 * 1.25 = 1.375.
!(resetAFRentProbe)
!(updateAttentionParam AFRentFrequency 5.0)
!(setAFRentElapsedSeconds 0.25)
!(AFRentCollectionAgent-run)
!(test (approxEqual (getSti afr_timer_probe) 98.625 0.05) True)
!(test (approxEqual (getAttentionParam FUNDS_STI) 901.375 0.05) True)

; Same elapsed time, doubled AFRentFrequency:
; w = 0.25 * 10 = 2.5, so rent doubles to 2.75.
!(resetAFRentProbe)
!(updateAttentionParam AFRentFrequency 10.0)
!(setAFRentElapsedSeconds 0.25)
!(AFRentCollectionAgent-run)
!(test (approxEqual (getSti afr_timer_probe) 97.25 0.05) True)
!(test (approxEqual (getAttentionParam FUNDS_STI) 902.75 0.05) True)

; Fixed elapsed time can fail the low-frequency threshold and pass the high-frequency threshold.
!(resetAFRentProbe)
!(updateAttentionParam AFRentFrequency 5.0)
!(setAFRentElapsedSeconds 0.11)
!(AFRentCollectionAgent-run)
!(test (getSti afr_timer_probe) 100.0)
!(test (getAttentionParam FUNDS_STI) 900.0)

!(resetAFRentProbe)
!(updateAttentionParam AFRentFrequency 10.0)
!(setAFRentElapsedSeconds 0.11)
!(AFRentCollectionAgent-run)
!(test (approxEqual (getSti afr_timer_probe) 98.79 0.05) True)
!(test (approxEqual (getAttentionParam FUNDS_STI) 901.21 0.05) True)


; my conclusion is that the timer is working as intended, 
; and that the rent collected is appropriately sensitive to both elapsed time and AFRentFrequency. 
; The test cases show that when the elapsed time is below the threshold defined by AFRentFrequency, 
; no rent is collected, and when it is above, the rent collected increases with both elapsed time and frequency.
