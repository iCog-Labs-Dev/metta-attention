!(register-module! ../../../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention:agents:mettaAgents:AttentionParam)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:atom-bins:get-min-max-content)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention:agents:mettaAgents:RentCollectionAgent:RentCollectionBaseAgent:RentCollectionBaseAgent)
!(import! &self metta-attention:attention-bank:bank:stochastic-importance-diffusion:stochastic-importance-diffusion)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention:agents:mettaAgents:RentCollectionAgent:WARentCollectionAgent:WARentCollectionAgent)


;;inorder to see the rent collection in action,we have to decrease the size of the attentional focus 
;;run it with cognitive controller because it depends on time passed since last rent collected on that atom
;;i have tested with that and it works fine
!(setAv b (50000.0 50000.0 0.0))
!(setAv c (20000.0 20000.0 0.0))
!(setAv d (29000.0 29000.0 0.0))
!(setAv (Hebbianlink a b) (400.0 400.0 0.0))
!(setAv (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)) (400.0 400.0 0.0))
!(WARentCollectionAgent-Run)
;; Sleep for the computed time to match C++ behavior
!((py-atom time.sleep) (/ 1.0 5.0))
!(WARentCollectionAgent-Run)
!(getSTI(Hebbianlink a b)) 
!(getSTI (Hebbianlink (Hebbianlink c d) (Hebbianlink c b))) 
!(getSTI b)
!(getSTI c)
!(getSTI d)
!(getLTI (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)))
!(getLTI b)
!(getLTI c)
!(getLTI d)








