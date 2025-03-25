!(register-module! ../../../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention:agents:mettaAgents:AttentionParam)
!(import! &self metta-attention:attention:agents:mettaAgents:RentCollectionAgent:RentCollectionBaseAgent:RentCollectionBaseAgent)


!(assertEqual (let $res (getAttentionParam StartingAtomStiRent)
                        (calculateStiRent $res)
              )
              0.0
)

!(assertEqual (calculateLtiRent (getAttentionParam StartingAtomLtiRent)) 0.0)
!(assertEqual (calculateStiRent 4.0) 0.0)
!(assertEqual (calculateLtiRent 4.0) 0.0)

