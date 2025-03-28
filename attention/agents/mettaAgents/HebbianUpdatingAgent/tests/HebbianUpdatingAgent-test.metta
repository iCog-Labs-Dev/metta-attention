!(register-module! ../../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &self metta-attention:attention-bank:utilities:recentVal)
!(import! &self metta-attention:attention:agents:mettaAgents:HebbianUpdatingAgent:HebbianUpdatingAgent)
!(import! &self metta-attention:attention-bank:utilities:recentVal)

;################ Prep: giving (source and target1) atoms mean and confidence ####################
!(setStv source (0.1 0.9))
!(setStv target1 (0.3 0.9))

;################ Prep: setting up Hebbian link between target2 and source ####################
!(setStv (ASYMMETRIC_HEBBIAN_LINK target2 source) (0.01 0.9))

;################ Prep: stimulating source, target1 and target2 atoms to add them into AF ####################
!(stimulate source 200)
!(stimulate target1 200)
!(stimulate target2 100)

;################ Running the HebbianUpdatingAgent ####################
!(updateHebbianLinks target2 (TypeSpace))

; ;################ Testing ####################
!(assertEqual (getAv source) (AV 4000.0 4000.0 0))
!(assertEqual (getAv target1) (AV 4000.0 4000.0 0))

;################ The weight should be updated ####################
; expected result 0.0105976 but since there is precision issue, we are checking the value in the range of 0.0105976

!(assertEqual (if (and (>= (getMean (ASYMMETRIC_HEBBIAN_LINK target2 source)) 0.0105975)
                       (<= (getMean (ASYMMETRIC_HEBBIAN_LINK target2 source)) 0.01059757))
                        True
                        False
              )
              True
)
