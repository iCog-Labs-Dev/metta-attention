; !(register-module! ../../../../../metta-attention)
!(import! &self ../../../../../metta-attention/attention/AttentionParam)
!(import! &self ../../../../../metta-attention/attention-bank/utilities/helper-functions)
!(import! &self ../../../../../metta-attention/attention-bank/attention-value/getter-and-setter)
!(import! &self ../../../../../metta-attention/attention-bank/bank/attention-bank)
!(import! &self ../../../../../metta-attention/attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../../../../metta-attention/attention-bank/bank/importance-index/importance-index)

!(import! &self ../../../../../metta-attention/attention/RentCollectionAgent/RentCollectionBaseAgent/RentCollectionBaseAgent)

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

