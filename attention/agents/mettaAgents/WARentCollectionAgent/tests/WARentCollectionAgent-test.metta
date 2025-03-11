!(register-module! ../../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention:agents:mettaAgents:AttentionParam)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:atom-bins:get-min-max-content)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention:agents:mettaAgents:RentCollectionBaseAgent:RentCollectionBaseAgent)
!(import! &self metta-attention:attention-bank:bank:stochastic-importance-diffusion:stochastic-importance-diffusion)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention:agents:mettaAgents:WARentCollectionAgent:WARentCollectionAgent)


;;inorder to see the rent collection in action,we have to decrease the size of the attentional focus 
;;run it with cogntive controller because it depends on time passed since last renet collected
;;i have tested with that and it works fine
!(setAv x (200.0 200.0 0.0))
!(setAv y (200.0 200.0 0.0))
!(setAv z (200.0 200.0 0.0))
!(setAv (Hebbianlink x z) (200.0 200.0 0.0))
!(setAv (Hebbianlink (Hebbianlink x y) (Hebbianlink x z))(200.0 200.0 0.0))
!(stimulate (Hebbianlink x z) 2)
!(stimulate x 2)
!(stimulate y 2)
!(stimulate (Hebbianlink (Hebbianlink x y) (Hebbianlink x z)) 2)
!(stimulate z 1)
!(WARentCollectionAgent-Run)
!(getAv (Hebbianlink x z))
!(getAv (Hebbianlink (Hebbianlink x y) (Hebbianlink x z)))
!(getAv x)
!(getAv y)
!(getAv z)









