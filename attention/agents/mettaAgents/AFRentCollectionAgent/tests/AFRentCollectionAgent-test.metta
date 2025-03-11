!(register-module! ../../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention:agents:mettaAgents:AttentionParam)
!(import! &self metta-attention:attention:agents:mettaAgents:RentCollectionBaseAgent:RentCollectionBaseAgent)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention:agents:mettaAgents:AFRentCollectionAgent:AFRentCollectionAgent)

;;inorder to see the rent collection in action,we have to decrease the size of the attentional focus 
;;run it with cogntive controller because it depends on time passed since last renet collected
;;i have tested with that and it works fine
!(setAv b (200.0 200.0 0.0))
!(setAv c (200.0 200.0 0.0))
!(setAv d (200.0 200.0 0.0))
!(setAv (Hebbianlink a b) (200.0 200.0 0.0))
!(setAv (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)) (200.0 200.0 0.0))
!(stimulate (Hebbianlink c b) 2)
!(stimulate (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)) 2)
!(stimulate b 2)
!(stimulate c 2)
!(stimulate d 2)
!(AFRentCollectionAgent-run)
!(getAv (Hebbianlink c b))
!(getAv (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)))
!(getAv b)
!(getAv c)
!(getAv d)




