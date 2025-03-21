!(register-module! ../../../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:atom-bins:get-min-max-content)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &self metta-attention:attention:agents:mettaAgents:Neighbors)
!(import! &self metta-attention:attention:agents:mettaAgents:ImportanceDiffusionAgent:ImportanceDiffusionBase)
!(import! &self metta-attention:attention-bank:bank:stochastic-importance-diffusion:stochastic-importance-diffusion)

;###########################################################################
!(stimulate source 500)
!(stimulate target1 400)
!(stimulate target2 400)
!(stimulate target3 400)
!(stimulate target4 400)
!(stimulate target5 400)
!(stimulate target6 10)

!(stimulate (HEBBIAN_LINK source target1) 10)
!(stimulate (HEBBIAN_LINK source target2) 10)
!(stimulate (ASYMMETRIC_HEBBIAN_LINK source target3) 10)

!(stimulate (INHERITANCE_LINK target3 source) 10)
!(stimulate (INHERITANCE_LINK source target4) 10)
!(stimulate (ASYMMETRIC_HEBBIAN_LINK target1 target2) 10)

!(stimulate (ASYMMETRIC_HEBBIAN_LINK target2 target1) 10)
!(stimulate (INHERITANCE_LINK source target5) 10)
!(stimulate (INHERITANCE_LINK source target6) 10)

;############################################################################
!(
    (WAImportanceDiffusionAgent-Run (TypeSpace))
    (WAImportanceDiffusionAgent-Run (TypeSpace))
)
;############################################################################
!(getRandomAtomNotInAF)
!(getAv source)
!(getAv target1)
!(getAv target2)
!(getAv target3)
!(getAv target4)
!(getAv target5)
!(getAv target6)

!(getAv (HEBBIAN_LINK source target1))
!(getAv (HEBBIAN_LINK source target2))
!(getAv (ASYMMETRIC_HEBBIAN_LINK source target3))

!(getAv (INHERITANCE_LINK target3 source))
!(getAv (INHERITANCE_LINK source target4))
!(getAv (ASYMMETRIC_HEBBIAN_LINK target1 target2))

!(getAv (ASYMMETRIC_HEBBIAN_LINK target2 target1))
!(getAv (INHERITANCE_LINK source target5))
!(getAv (INHERITANCE_LINK source target6))