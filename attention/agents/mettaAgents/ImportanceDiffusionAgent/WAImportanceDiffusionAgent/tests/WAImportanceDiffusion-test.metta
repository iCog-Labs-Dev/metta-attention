!(register-module! ../../../../../../../metta-attention)
!(import! &self metta-attention:attention:agents:mettaAgents:AttentionParam)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:atom-bins:get-min-max-content)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &self metta-attention:attention:agents:mettaAgents:Neighbors)
!(import! &self metta-attention:attention:agents:mettaAgents:ImportanceDiffusionAgent:ImportanceDiffusionBase:ImportanceDiffusionBase)
!(import! &self metta-attention:attention:agents:mettaAgents:ImportanceDiffusionAgent:WAImportanceDiffusionAgent:WAImportanceDiffusionAgent)
!(import! &self metta-attention:attention-bank:bank:stochastic-importance-diffusion:stochastic-importance-diffusion)
!(import! &self metta-attention:attention-bank:utilities:recentVal)

;###########################################################################
!(----------------)
!(stimulate source 500)
!(stimulate target1 400)

!(stimulate (ASYMMETRIC_HEBBIAN_LINK source target3) 100)
!(----------------)
; ;############################################################################
!(
    (WAImportanceDiffusionAgent-Run (TypeSpace))
    (WAImportanceDiffusionAgent-Run (TypeSpace))
)
;############################################################################
!(----------------)
!(getAv source)
!(getAv target1)

!(getAv (ASYMMETRIC_HEBBIAN_LINK source target3))
!(----------------)