!(register-module! ../../../../metta-attention)
!(import! &self metta-attention:attention:agents:mettaAgents:AttentionParam)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:bank:attention-bank)


; Test case 01: testing attention value setter(setAv) function for symbol atom type and 
;testing that atoms are inserted to atombins and attentional focus space when av is set to them
!(assertEqual (getAttentionBank fundsSTI) 100000)
!(assertEqual (getAttentionBank fundsLTI) 100000)
!(setAv A (200 200 0)) 
!(setAv A (400 400 0)) 
!(setAv Cat (400 400 1))  
!(setAv Animal (400 400 1))
!(setAv Human (400 400 1))
!(assertEqual (getAttentionBank fundsSTI) 98400)
!(assertEqual (getAttentionBank fundsLTI) 98400)
!(assertEqual (getAtomsInBins) ((53.0 (Human Animal Cat A))))
!(assertEqual (getAtomList) (A Cat Animal Human))
; Test case 02: testing attention value getter(getAv) function for symbol atom type

! (assertEqual (getAv A) (AV 400 400 0)) ; getting attention value for symbol A
! (assertEqual (getAv Cat) (AV 400 400 1))
! (assertEqual (getAv Animal) (AV 400 400 1))
! (assertEqual (getAv Human) (AV 400 400 1))
! (assertEqual (getAv k) %Undefined%) ; getting attention value for an atom 
                                      ; that previously not set any attention value return %Undefined%


; Test case 03: testing attention value setter(setAv) functionfor link/expressions atom type

! (setAv (a) (397 400 1))
! (setAv (C) (400 400 1))
! (setAv (EvaluationLink a b) (300 200 0))
! (setAv (Hebbianlink Human Cat) (200 200 0))
! (setAv (Hebbianlink (Hebbianlink Human Cat) Animal) (300 200 0))
! (setAv (Hebbianlink (Hebbianlink Animal Human) (Hebbianlink Animal Cat)) (200 200 0))


; Test case 04: testing attention value getter(getAv) function for link/expressions atom type

! (assertEqual (getAv (a)) (AV 397 400 1))
! (assertEqual (getAv (C)) (AV 400 400 1))
! (assertEqual (getAv (EvaluationLink a b)) (AV 300 200 0))
! (assertEqual (getAv (Hebbianlink Human Cat)) (AV 200 200 0))
! (assertEqual (getAv (Hebbianlink (Hebbianlink Human Cat) Animal)) (AV 300 200 0))
! (assertEqual (getAv (Hebbianlink (Hebbianlink Animal Human) (Hebbianlink Animal Cat))) (AV 200 200 0))


; Test case 05: testing simple truth value setter functions for symbol atom type

! (setStv A (0.1 0.9))
! (setStv A (1.0 0.9))
! (setStv Cat (0.8 0.9))
! (setStv Animal (0.7 0.8))
! (setStv Human (0.4 0.3))
! (setStv Socratus (0.5 0.6))


; Test case 06: testing simple truth value getter (getStv) functions for symbol atom type.

! (assertEqual (getStv A) (STV 1.0 0.9))
! (assertEqual (getStv Cat) (STV 0.8 0.9))
! (assertEqual (getStv Animal) (STV 0.7 0.8))
! (assertEqual (getStv Human) (STV 0.4 0.3))
! (assertEqual (getStv Socratus) (STV 0.5 0.6))
! (assertEqual (getStv k) %Undefined%)


; Test case 07: testing simple truth value setter(setStv) for link/expressions

! (setStv (a) (0.2 0.9))
! (setStv (C) (1 0.9))
! (setStv (EvaluationLink a b) (0.1 0.9))
! (setStv (Hebbianlink Human Cat) (0.3 0.9))
! (setStv (Hebbianlink (Hebbianlink Cat Human) Animal) (0.5 0.6))
! (setStv (Hebbianlink (Hebbianlink Animal Human) (Hebbianlink Animal Cat)) (0.1 0.9))


; Test case 08: testing simple truth value getter functions for link/expressions atom type

! (assertEqual (getStv (a)) (STV 0.2 0.9))
! (assertEqual (getStv (C)) (STV 1 0.9))
! (assertEqual (getStv (EvaluationLink a b)) (STV 0.1 0.9))
! (assertEqual (getStv (Hebbianlink Human Cat)) (STV 0.3 0.9))
! (assertEqual (getStv (Hebbianlink (Hebbianlink Cat Human) Animal)) (STV 0.5 0.6))
! (assertEqual (getStv (Hebbianlink (Hebbianlink Animal Human) (Hebbianlink Animal Cat))) (STV 0.1 0.9))


; Test case 09: testing mean, confidence, STI, LTI and VLTI getter functions

! (assertEqual (getMean A) 1)
! (assertEqual (getConfidence (EvaluationLink a b)) 0.9)
! (assertEqual (getSTI (Hebbianlink Human Cat)) 200)
! (assertEqual (getLTI (Hebbianlink (Hebbianlink Human Cat) Animal)) 200)
! (assertEqual (getVLTI (Hebbianlink (Hebbianlink Animal Hebbianlink) (Hebbianlink Animal Cat))) 0)

; Test case 10:testing setSTI,setLTI,setVLTI functions and the dereasing the global parameters
;(funsSTI and fundsLTI) for every av the is given to the atoms
!(setSTI k 200)
!(setLTI k 200)
!(setVLTI k 200)
!(assertEqual(getAv k) (AV 200 200 200))
!(assertEqual (getAttentionBank fundsSTI) 96403)
!(assertEqual (getAttentionBank fundsLTI) 96600)

