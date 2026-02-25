; !(register-module! ../../../../../metta-attention)
!(import! &self ../../../AttentionParam)
!(import! &self ../../../../attention-bank/utilities/helper-functions)
!(import! &self ../../../../attention-bank/attention-value/getter-and-setter)
!(import! &self ../../../../attention-bank/bank/attention-bank)
!(import! &self ../../../../attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../../../attention-bank/bank/importance-index/importance-index)
!(import! &self ../RentCollectionBaseAgent)

;calculate rent before atoms stimulated
!(test (calculateLtiRent (getAttentionParam StartingAtomLtiRent)) 0.0)
!(test  (calculateStiRent (getAttentionParam StartingAtomStiRent)) 0.0)
!(stimulate b 3000.0)
!(stimulate c 1500.0)
!(stimulate d 290.0)
!(stimulate (Hebbianlink a b) 50.0)
!(stimulate (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)) 5.0)
;calculate rent after atoms stimulated
!(test (> (calculateStiRent (getAttentionParam StartingAtomStiRent)) 0.0) True)
!(test (> (calculateLtiRent (getAttentionParam StartingAtomLtiRent)) 0.0) True)

