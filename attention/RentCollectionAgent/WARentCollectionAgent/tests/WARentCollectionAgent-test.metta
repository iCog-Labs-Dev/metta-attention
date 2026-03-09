!(import! &self lib/lib_he)
!(import! &self lib/lib_spaces)
!(import! &self ../../../AttentionParam)
!(import! &self ../../../../attention-bank/utilities/helper-functions)
!(import! &self ../../../../attention-bank/bank/importance-index/importance-index)
!(import! &self ../../../../attention-bank/attention-value/getter-and-setter)
!(import! &self ../../../../attention-bank/bank/attention-bank)
!(import! &self ../../../../attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../../../attention-bank/bank/stochastic-importance-diffusion/stochastic-importance-diffusion)
; !(import! &self ../../../../../metta-attention/attention-bank/utilities/recentVal)
!(import! &self ../../../Neighbors)
!(import! &self ../../RentCollectionBaseAgent/RentCollectionBaseAgent)
!(import! &self ../WARentCollectionAgent)





;lower max AFsize for testing
!(updateAttentionParam MAX_AF_SIZE 4.0)

!(test (getAttentionParam MAX_AF_SIZE) 4.0)


!(stimulate b 3000.0)
!(stimulate c 1500.0)
!(stimulate d 290.0)
!(stimulate (Hebbianlink a b) 50.0)
!(stimulate (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)) 5.0)


!(test (getSti b) 60000.0)
!(test (getSti c) 30000.0)
!(test (getSti d) 2900.0)
!(test (getSti (Hebbianlink a b)) 355.0)
!(test (getSti (Hebbianlink (Hebbianlink c d) (Hebbianlink c b))) 33.725)
!(test (selectTargets) (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)))

; !(getSti (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)))

!((let $res (selectTargets) (elapsedTime $res) ))

; !(match &atomBinInfo ($in $val) $val)

!(WARentCollectionAgent-Run)

; Sleep for the computed time to match C++ behavior

; !(py-call (time.sleep 0.5))

; !(WARentCollectionAgent-Run)


!(test (< (getSti (Hebbianlink (Hebbianlink c d) (Hebbianlink c b))) 33.725) True) ;must have lower sti

; !(getSti (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)))

!(test (getSti b) 60000.0)
!(test (getSti c) 30000.0)
!(test (getSti d) 2900.0)
!(test (getSti (Hebbianlink a b)) 355.0)



