!(register-module! ../../../../metta-attention)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &test-kb metta-attention:attention-bank:attention-value:tests:test-kb)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)

!(assertEqual (getSTI (getType &test-kb A)) 10.0)
!(assertEqual (getLTI (getType &test-kb A)) 10.0)
!(assertEqual (getMean (getType &test-kb B)) 0.5)
!(assertEqual (getConf (getType &test-kb B)) 0.5)

!(setAV &test-kb A (100.0 100.0 1.0))
!(setSTV &test-kb A (0.0 0.0))

!(setAV &test-kb B (100.0 100.0 1.0))
!(setSTV &test-kb B (0.0 0.0))

!(assertEqual (getSTI (getType &test-kb A)) 100.0)
!(assertEqual (getLTI (getType &test-kb A)) 100.0)

!(assertEqual (getSTI (getType &test-kb B)) 100.0)
!(assertEqual (getLTI (getType &test-kb B)) 100.0)

!(assertEqual (getMean (getType &test-kb B)) 0.0)
!(assertEqual (getConf (getType &test-kb B)) 0.0)

!(assertEqual (getSTV (getType &test-kb B)) (0.0 0.0))
!(assertEqual (getAV (getType &test-kb B)) (100.0 100.0 1.0))

!(setAV &test-kb link_ab (10.0 0.0 0.0))
!(assertEqual (getAV (getType &test-kb link_ab)) (10.0 0.0 0.0))
