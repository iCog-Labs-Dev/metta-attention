!(register-module! ../../../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention:agents:mettaAgents:AttentionParam)
!(import! &self metta-attention:attention:agents:mettaAgents:RentCollectionAgent:RentCollectionBaseAgent:RentCollectionBaseAgent)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)

;calculate rent before atoms stimulated
!(assertEqual (calculateLtiRent (getAttentionParam StartingAtomLtiRent)) 0.0)
!(assertEqual  (calculateStiRent (getAttentionParam StartingAtomStiRent)) 0.0)
!(stimulate b 3000.0)
!(stimulate c 1500.0)
!(stimulate d 290.0)
!(stimulate (Hebbianlink a b) 50.0)
!(stimulate (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)) 5.0)
;calculate rent after atoms stimulated
!(assertEqual (> (calculateStiRent (getAttentionParam StartingAtomStiRent)) 0.0) True)
!(assertEqual (> (calculateLtiRent (getAttentionParam StartingAtomLtiRent)) 0.0) True)

