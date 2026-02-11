; !(register-module! ../../../../../metta-attention)
; !(import! &self metta-attention:attention-bank:bank:attention-bank)
; !(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
; !(import! &self metta-attention:attention:AttentionParam)
; !(import! &self metta-attention:attention:RentCollectionAgent:RentCollectionBaseAgent:RentCollectionBaseAgent)
; !(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
; !(import! &self metta-attention:attention-bank:utilities:helper-functions)
; !(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
; !(import! &self metta-attention:attention:RentCollectionAgent:AFRentCollectionAgent:AFRentCollectionAgent)


!(import! &self ../../../../../PeTTa/lib/lib_he)
!(import! &self lib/lib_spaces)
!(import! &self ../../../../../metta-attention/attention/AttentionParam)
!(import! &self ../../../../../metta-attention/attention-bank/utilities/helper-functions)
!(import! &self ../../../../../metta-attention/attention-bank/attention-value/getter-and-setter)
!(import! &self ../../../../../metta-attention/attention-bank/bank/attention-bank)
!(import! &self ../../../../../metta-attention/attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../../../../metta-attention/attention-bank/bank/importance-index/importance-index)
!(import! &self ../../../../../metta-attention/attention-bank/utilities/recentVal)
!(import! &self ../../../../../metta-attention/attention/Neighbors)
!(import! &self ../../../../../metta-attention/attention/RentCollectionAgent/RentCollectionBaseAgent/RentCollectionBaseAgent)
!(import! &self ../../../../../metta-attention/attention/RentCollectionAgent/AFRentCollectionAgent/AFRentCollectionAgent)


!(stimulate b 3000.0)
!(stimulate c 1500.0)
!(stimulate d 290.0)
!(stimulate (Hebbianlink a b) 50.0)
!(stimulate (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)) 5.0)


!(test  (getSti b) 60000.0)
!(test (getSti c)  30000.0)
!(test (getSti d) 2900.0)
!(test (getSti (Hebbianlink a b)) 355.0)
!(test  (getSti (Hebbianlink (Hebbianlink c d) (Hebbianlink c b))) 33.725)

; Run rent collection in a loop until enough time has passed
; !(hello here)
; (= (timeT) (py-call (time.time)))
; !(timeT)
!(AFRentCollectionAgent-run)
; !(hello)

;Sleep for the computed time to match C++ behavior
!(py-call (time.sleep (/ 2.0 6.0)))
; !(sleep (/ 1.0 6.0))
!(AFRentCollectionAgent-run)

;the sti value of the atoms must be lower and Python’s time.time() is only precise up to ~1e-6 or less,
;and sleep in MeTTa via Python is also not deterministic.that's why i used the approximation
!(getSti (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)))

!(getSti b)
!(test (approxEqual (getSti (Hebbianlink (Hebbianlink c d) (Hebbianlink c b))) 30.9 1.6) True)
!(test (approxEqual (getSti b) 59998.7 2.0) True)
!(test (approxEqual (getSti c) 29998.7 2.0) True)
!(test (approxEqual (getSti d) 2898.71 2.0) True)
!(test (approxEqual (getSti (Hebbianlink a b)) 353.725 2.0) True)

