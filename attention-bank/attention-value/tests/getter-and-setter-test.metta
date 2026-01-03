!(import! &self ../../../../PeTTa/lib/lib_he)
!(import! &self ../../../../metta-attention/attention/AttentionParam)
!(import! &self ../../../../metta-attention/attention-bank/utilities/helper-functions)
!(import! &self ../../../../metta-attention/attention-bank/bank/importance-index/importance-index)
!(import! &self ../../../../metta-attention/attention-bank/bank/attention-bank)
!(import! &self ../../../../metta-attention/attention-bank/attention-value/getter-and-setter)
!(import! &self ../../../../metta-attention/attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../../../metta-attention/attention-bank/utilities/recentVal)

; Test case 01: testing attention value setter(setAv) function for symbol atom type and 

!(test (getAttentionParam FUNDS_STI) 100000)
!(test (getAttentionParam FUNDS_LTI) 100000)
!(setAv A (200 200 0)) 
!(setAv A (400 400 0)) 
!(setAv Cat (400 400 1))  
!(setAv Animal (400 400 1))
!(setAv Human (400 400 1))
!(test (getAttentionParam FUNDS_STI) 98400.0)
!(test (getAttentionParam FUNDS_LTI) 98400.0)

; Test case 02: testing attention value getter(getAv) function for symbol atom type

!(test (getAv A) (AV 400 400 0)) ; getting attention value for symbol A
!(test (getAv Cat) (AV 400 400 1))
!(test (getAv Animal) (AV 400 400 1))
!(test (getAv Human) (AV 400 400 1))
!(test (getAv k) %Undefined%) ; getting attention value for an atom 
                                      ; that previously not set any attention value return %Undefined%


; Test case 03: testing attention value setter(setAv) functionfor link/expressions atom type

!(setAv (a) (397 400 1))
!(setAv (C) (400 400 1))
!(setAv (EvaluationLink a b) (300 200 0))
!(setAv (Hebbianlink a b) (300 200 0))
!(setAv (Hebbianlink Human Cat) (200 200 0))
!(setAv (SimilarityLink Human Cat) (200 200 0))
!(setAv (Hebbianlink (Hebbianlink Human Cat) Animal) (300 200 0))
!(setAv (Hebbianlink (Hebbianlink Animal Human) (Hebbianlink Animal Cat)) (200 200 0))


; Test case 04: testing attention value getter(getAv) function for link/expressions atom type

!(test (getAv (a)) (AV 397 400 1))
!(test (getAv (C)) (AV 400 400 1))
!(test (getAv (EvaluationLink a b)) (AV 300 200 0))
!(test (getAv (Hebbianlink Human Cat)) (AV 200 200 0))
!(test (getAv (Hebbianlink (Hebbianlink Human Cat) Animal)) (AV 300 200 0))
!(test (getAv (Hebbianlink (Hebbianlink Animal Human) (Hebbianlink Animal Cat))) (AV 200 200 0))


; Test case 05: testing simple truth value setter functions for symbol atom type

!(setStv A (0.1 0.9))
!(setStv A (1.0 0.9))
!(setStv Cat (0.8 0.9))
!(setStv Animal (0.7 0.8))
!(setStv Human (0.4 0.3))
!(setStv Socratus (0.5 0.6))

; Test case 06: testing simple truth value getter (getStv) functions for symbol atom type.

!(test (getStv A) (STV 1.0 0.9))
!(test (getStv Cat) (STV 0.8 0.9))
!(test (getStv Animal) (STV 0.7 0.8))
!(test (getStv Human) (STV 0.4 0.3))
!(test (getStv Socratus) (STV 0.5 0.6))
!(test (getStv k) %Undefined%)


; Test case 07: testing simple truth value setter(setStv) for link/expressions

!(setStv (a) (0.2 0.9))
!(setStv (C) (1 0.9))
!(setStv (EvaluationLink a b) (0.1 0.9))
!(setStv (Hebbianlink Human Cat) (0.3 0.9))
!(setStv (Hebbianlink (Hebbianlink Cat Human) Animal) (0.5 0.6))
!(setStv (Hebbianlink (Hebbianlink Animal Human) (Hebbianlink Animal Cat)) (0.1 0.9))


; Test case 08: testing simple truth value getter functions for link/expressions atom type

!(test (getStv (a)) (STV 0.2 0.9))
!(test (getStv (C)) (STV 1 0.9))
!(test (getStv (EvaluationLink a b)) (STV 0.1 0.9))
!(test (getStv (Hebbianlink Human Cat)) (STV 0.3 0.9))
!(test (getStv (Hebbianlink (Hebbianlink Cat Human) Animal)) (STV 0.5 0.6))
!(test (getStv (Hebbianlink (Hebbianlink Animal Human) (Hebbianlink Animal Cat))) (STV 0.1 0.9))


; Test case 09: testing mean, confidence, STI, LTI and VLTI getter functions

!(test (getMean A) 1.0)
!(test (getConfidence (EvaluationLink a b)) 0.9)
!(test (getSti (Hebbianlink Human Cat)) 200)
!(test (getLti (Hebbianlink (Hebbianlink Human Cat) Animal)) 200)
!(test (getVlti (Hebbianlink (Hebbianlink Animal Hebbianlink) (Hebbianlink Animal Cat))) 0.0)

; Test case 10:testing setSti,setLti,setVlti functions and the dereasing the global parameters
;(FUNDS_STI and FUNDS_LTI) for every av the is given to the atoms
!(setSti k 200)
!(setLti k 200)
!(setVlti k 200)
!(test (getAv k) (AV 200 200 200))

!(test (getAttentionParam FUNDS_STI) 95903.0)
!(test (getAttentionParam FUNDS_LTI) 96200.0)


; Test case 11: testing  functions globalIncomingSetByType and globalIncomingSetwithoutType
!(test (globalIncomingSetByType a EvaluationLink)  ((EvaluationLink a b)))
!(test (globalIncomingSetByType Human Hebbianlink) ((Hebbianlink Human Cat)))

!(test (let $vals
    (globalIncomingSetwithoutType a)
    (subtraction-atom $vals ((EvaluationLink a b) (Hebbianlink a b)))
    ) 
    ()
)
!(test (let $vals
    (globalIncomingSetwithoutType Human)
    (subtraction-atom $vals ((SimilarityLink Human Cat) (Hebbianlink Human Cat)))
    ) 
    ()
)

!(test (getSize 45.0) 4)
; !(test (getBinList &typeSpace) (50.0 45.0 53.0))
!(test (getAtomsByBin 50.0) ((Hebbianlink a b) (Hebbianlink (Hebbianlink Human Cat) Animal) (EvaluationLink a b)))
!(test (size-atom (getAllAtomsWithBins)) 13)
!(test (getAllMaxSTI (getAfAtoms)) 400)
!(test (getAllMinSTI (getAllAtomsWithBins)) 200)
!(test (countAtomsInTypeSpace) 15)
!(removeTypeSpace k)
!(test (countAtomsInTypeSpace) 14)

!(getBinList &typeSpace)
!(unique-atom (4 5 6 4 3 4 5 7 8 9))
; !(getMinBinContents &typeSpace)
; !(getAtomsInTypeSpace)
; !(getStiHelper (getAtomsInTypeSpace) )

!(getMinBinContents)
; !(getAtomsByBin 50.0)
!(getAtomsByBin 45.0)

!(hello)
!(getMaxBinContents)
!(getAtomsByBin 53.0)
!(hello again)
!(computeMinSTI)
!(hello again)
!(getSTIValues (getMinBinContents))
!(getSTIValues (getMaxBinContents))
!(hello again)
!(computeMaxSTI)

; !(getAttentionParam MIN_STI)
; !(getAttentionParam MAX_STI)


; !(update)

; !(getAttentionParam MIN_STI)
; !(getAttentionParam MAX_STI)