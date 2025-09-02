!(register-module! ../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention:AttentionParam)
!(import! &self metta-attention:attention:RentCollectionAgent:RentCollectionBaseAgent:RentCollectionBaseAgent)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter-2)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &self metta-attention:attention:RentCollectionAgent:AFRentCollectionAgent:AFRentCollectionAgent)
!(stimulate b 3000.0)
!(stimulate c 1500.0)
!(stimulate d 290.0)
!(stimulate (Hebbianlink a b) 50.0)
!(stimulate (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)) 5.0)
!(assertEqual  (getSti b) 60000.0)
!(assertEqual (getSti c)  30000.0)
!(assertEqual (getSti d) 2900.0)
!(assertEqual (getSti (Hebbianlink a b)) 355.0)
!(assertEqual  (getSti (Hebbianlink (Hebbianlink c d) (Hebbianlink c b))) 33.725)

; Run rent collection in a loop until enough time has passed
!(AFRentCollectionAgent-run)

;Sleep for the computed time to match C++ behavior
! ((py-atom time.sleep) (/ 1.0 5.0))
!(AFRentCollectionAgent-run)

;the sti value of the atoms must be lower and Python’s time.time() is only precise up to ~1e-6 or less,
;and sleep in MeTTa via Python is also not deterministic.that's why i used the approximation

!(assertEqual (approxEqual (getSti (Hebbianlink (Hebbianlink c d) (Hebbianlink c b))) 30.9 1.6) True)
!(assertEqual (approxEqual (getSti b) 59998.7 1.6) True)
!(assertEqual (approxEqual (getSti c) 29998.7 1.6) True)
!(assertEqual (approxEqual (getSti d) 2898.71 1.6) True)
!(assertEqual (approxEqual (getSti (Hebbianlink a b)) 353.725 1.6) True)



