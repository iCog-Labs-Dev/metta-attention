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

; This test varies only:
;   1. FUNDS_STI
;   2. AFRentFrequency
;   3. elapsed time
;
; Fixed values:
;   atom STI = 100
;   TARGET_STI = 1000
;   STI_FUNDS_BUFFER = 1000
;   StartingAtomStiRent = 1
;
; Formula for one atom:
;   threshold seconds = 1 / AFRentFrequency
;   if elapsed < threshold: rent = 0
;   else:
;     baseRent = 1 + ((TARGET_STI - FUNDS_STI) / STI_FUNDS_BUFFER)
;     baseRent is clamped to max 2.0 and becomes 0.0 when FUNDS_STI >= TARGET_STI
;     collected = baseRent * elapsed * AFRentFrequency

(= (setFundFreqElapsedProbe $fund $freq)
    (let*
        (
            ($_atom (setAv rent_ffe_probe (100.0 100.0 0.0)))
            ($_fundSti (updateAttentionParam FUNDS_STI $fund))
            ($_fundLti (updateAttentionParam FUNDS_LTI $fund))
            ($_targetSti (updateAttentionParam TARGET_STI 1000.0))
            ($_targetLti (updateAttentionParam TARGET_LTI 1000.0))
            ($_bufferSti (updateAttentionParam STI_FUNDS_BUFFER 1000.0))
            ($_bufferLti (updateAttentionParam LTI_FUNDS_BUFFER 1000.0))
            ($_stiRent (updateAttentionParam StartingAtomStiRent 1.0))
            ($_ltiRent (updateAttentionParam StartingAtomLtiRent 1.0))
            ($_freq (updateAttentionParam AFRentFrequency $freq))
            ($_afSize (updateAttentionParam MAX_AF_SIZE 10.0))
            ($_first (setFirstTime False))
        )
        ()
    )
)

(= (setAFRentElapsedSeconds $seconds)
    (let $now (timeTime)
        (setLastUpdate (- $now $seconds))
    )
)

(= (runFundFreqElapsedProbe $elapsed)
    (let*
        (
            ($_elapsed (setAFRentElapsedSeconds $elapsed))
            ($_run (AFRentCollectionAgent-run))
        )
        ()
    )
)

; =================== elapsed threshold ===================
; fund=900 gives baseRent = 1.1.
; freq=10 gives threshold = 0.1 seconds.
!(setFundFreqElapsedProbe 900.0 10.0)
!(runFundFreqElapsedProbe 0.05)
!(test (getSti rent_ffe_probe) 100.0)
!(test (getAttentionParam FUNDS_STI) 900.0)

!(setFundFreqElapsedProbe 900.0 10.0)
!(runFundFreqElapsedProbe 0.1)
!(test (approxEqual (getSti rent_ffe_probe) 98.9 0.1) True)
!(test (approxEqual (getAttentionParam FUNDS_STI) 901.1 0.1) True)

!(setFundFreqElapsedProbe 900.0 10.0)
!(runFundFreqElapsedProbe 0.25)
!(test (approxEqual (getSti rent_ffe_probe) 97.25 0.1) True)
!(test (approxEqual (getAttentionParam FUNDS_STI) 902.75 0.1) True)

; =================== frequency at same elapsed time ===================
; elapsed=0.25.
; freq=5 passes threshold and weight=1.25, collected=1.1*1.25=1.375.
!(setFundFreqElapsedProbe 900.0 5.0)
!(runFundFreqElapsedProbe 0.25)
!(test (approxEqual (getAttentionParam FUNDS_STI) 901.375 0.1) True)

; freq=20 passes threshold and weight=5.0, collected=1.1*5=5.5.
!(setFundFreqElapsedProbe 900.0 20.0)
!(runFundFreqElapsedProbe 0.25)
!(test (approxEqual (getAttentionParam FUNDS_STI) 905.5 0.1) True)

; =================== fund level at same elapsed time and frequency ===================
; elapsed=0.25, freq=10, weight=2.5.
; fund=500 gives baseRent=1.5, collected=3.75.
!(setFundFreqElapsedProbe 500.0 10.0)
!(runFundFreqElapsedProbe 0.25)
!(test (approxEqual (getAttentionParam FUNDS_STI) 503.75 0.1) True)

; fund=990 gives baseRent=1.01, collected=2.525.
!(setFundFreqElapsedProbe 990.0 10.0)
!(runFundFreqElapsedProbe 0.25)
!(test (approxEqual (getAttentionParam FUNDS_STI) 992.525 0.1) True)

; fund >= target gives baseRent=0, so no rent even when threshold is satisfied.
!(setFundFreqElapsedProbe 1000.0 10.0)
!(runFundFreqElapsedProbe 0.25)
!(test (getAttentionParam FUNDS_STI) 1000.0)

!(setFundFreqElapsedProbe 1100.0 10.0)
!(runFundFreqElapsedProbe 0.25)
!(test (getAttentionParam FUNDS_STI) 1100.0)

; =================== all three interact ===================
; fund=500 has stronger base rent, but elapsed below threshold still blocks rent.
!(setFundFreqElapsedProbe 500.0 5.0)
!(runFundFreqElapsedProbe 0.1)
!(test (getAttentionParam FUNDS_STI) 500.0)

; Same fund and elapsed, higher frequency lowers threshold and raises weight.
; freq=20 threshold=0.05, weight=2.0, baseRent=1.5, collected=3.0.
!(setFundFreqElapsedProbe 500.0 20.0)
!(runFundFreqElapsedProbe 0.1)
!(test (approxEqual (getAttentionParam FUNDS_STI) 503.0 0.1) True)
