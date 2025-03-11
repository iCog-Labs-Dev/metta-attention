!(register-module! ../../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention:agents:mettaAgents:AttentionParam)
!(import! &self metta-attention:attention:agents:mettaAgents:RentCollectionBaseAgent:RentCollectionBaseAgent)


!(assertEqual (let $res (getAttentionParam StartingAtomStiRent)
    
    (calculateStiRent $res)
    
    ) 2.0)
    
!(assertEqual (calculateLtiRent (getAttentionParam StartingAtomLtiRent)) 2.0)
!(assertEqual  (calculateStiRent 4.0) 8.0)
!(assertEqual (calculateLtiRent 4.0) 8.0)

