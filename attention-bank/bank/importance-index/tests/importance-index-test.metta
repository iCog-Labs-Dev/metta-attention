!(import! &self ../../../../../PeTTa/lib/lib_he)
!(import! &self ../../../../../metta-attention/attention/AttentionParam)
!(import! &self ../../../../../metta-attention/attention-bank/utilities/helper-functions)
!(import! &self ../../../../../metta-attention/attention-bank/attention-value/getter-and-setter)
!(import! &self ../../../../../metta-attention/attention-bank/utilities/recentVal)
!(import! &self ../../../../../metta-attention/attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../../../../metta-attention/attention-bank/bank/importance-index/importance-index)
!(import! &self ../../../../../metta-attention/attention-bank/bank/attention-bank)


;###################### Prep: adding atoms to the atom bin #####################
!(setAv a (2.0 2.0 2.0))
!(setAv d (4.0 2.0 2.0))
!(setAv c (3.0 2.0 2.0))
!(setAv x (200.0 200.0 0.0))
!(setAv (EvaluationLink a b) (20 20 0)) 
!(setAv another (25 25 0)) 
!(setAv Animals (30 30 1)) 
!(setAv (Hebbianlink (Hebbianlink Human Cat)  Animal) (40 40 1))
!(setAv something   (80 80 1))

;########################### Testing ###########################################

; Test case 01: Testing importanceBin with different number value
!(test (importanceBin -5.0)  0.0)    ; Should return 0
!(test (importanceBin 10.0)   10.0)   ; Should return 10 (direct assignment)
!(test (importanceBin 20.0)  20.0)    ; Should calculate based on group logic 18
!(test (importanceBin 50.0) 29.0)    ; Should calculate based on group logic 29


; Test case 02: Testing getHandleSet,getContent and filterContents functions
!(getAllAtomsWithBins)
!(test (getHandleSet 20 40) ((EvaluationLink a b) another Animals (Hebbianlink (Hebbianlink Human Cat) Animal)))
!(test (filterContents ((EvaluationLink a b) another Animals ) 10 25) ((EvaluationLink a b) another ()))
!(test (getHandleSet 11 26.0) ((EvaluationLink a b) another))
!(test (getContent 20.0 30) ((EvaluationLink a b) another Animals (Hebbianlink (Hebbianlink Human Cat) Animal)) )

; Test case 03: Testing update function
!(test (getMaxSTI) 200.0)
!(test (getMinSTI) 2.0)

!(test (findGroup 0) 0)
!(test (findGroup 1) 1)
!(test (findGroup 2) 2)
!(test (findGroup 3) 2)
!(test (findGroup 4) 3)

!(test (findGroup 50) 6)
!(test (findGroup 500) 9)
!(test (findGroup 5000) 12.0)
; Test cases 04: Testing stimulate that need to be refactored
!(test (stimulate x 1.5) ("Updated"))


; Test case 05: Testing getNormalisedZeroToOneSTI with different average and clip values both on and off
!(getNormalisedZeroToOneSTI (getSti a) True True)
!(test (getNormalisedZeroToOneSTI (getSti a) True True) 0.0)
!(test (getNormalisedZeroToOneSTI (getSti d) True False) 0.008771929824561403)
!(test (getNormalisedZeroToOneSTI (getSti c)  False False) 0.0043859649122807015)
; Test case 06: Testing getNormalisedSTI 

!(test (getNormalisedSTI (getSti a)) 1.0)
!(test (getNormalisedSTI (getSti x)) 115.0)


; Test case 07: Testing getNormalisedSTI with different average and clip values

!(test (getNormalisedSTI (getSti a) True True) -1.0)
!(test (getNormalisedSTI (getSti d) True False) -1.0263157894736843)