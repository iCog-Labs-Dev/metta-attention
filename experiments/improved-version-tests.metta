!(register-module! ../../metta-attention)
!(import! &ecan metta-attention:experiments:ecan-kb)
!(import! &self metta-attention:experiments:improved-version)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)

!(assertEqual (getTV (getType &ecan A)) 0.1)
!(assertEqual (getConf (getType &ecan A)) 0.2)
!(assertEqual (getSTI (getType &ecan A)) 0.0) ;check for default
!(assertEqual (getSTI (getType  &ecan B)) 100.0)
!(assertEqual (getLTI (getType &ecan B)) 110.0)

!(setSTV &ecan A (0.0 0.0))
!(setAV &ecan B (20.0 22.0))

!(setSTV &ecan A (0.0 0.0))
!(setAV &ecan B (20.0 22.0))

!(assertEqual (getSTI (getType &ecan B)) 20.0)
!(assertEqual (getLTI (getType &ecan B)) 22.0)

!(assertEqual (getTV (getType &ecan A)) 0.0)
!(assertEqual (getConf (getType &ecan A)) 0.0)

!(assertEqual (getSTI (getType &ecan ExpA)) 0.1)
!(assertEqual (getLTI (getType &ecan ExpA)) 0.2)

!(assertEqual (getSTI (getType &ecan one)) 0.1)
!(assertEqual (getLTI (getType &ecan one)) 0.2)
