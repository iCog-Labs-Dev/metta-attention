!(register-module! ../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:bank:atombins)
!(import! &self metta-attention:attention-bank:bank:importance-index)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:utilities:recentVal)

;For Testing the update, getMaxSTI, getMinSTI
!(setAv a (2 2 2))
!(setAv d (4 2 2))
!(setAv c (3 2 2))

!(add-atom &atombin (1 (a)))
!(add-atom &atombin (10 (d)))
!(add-atom &atombin (18 (c)))

!(assertEqual (getHandleSet 1 20) (a d c))
!(assertEqual (getHandleSet 10 10) ())

; Test importanceBin function
!(assertEqual (importanceBin -5)  0)    ; Should return 0
!(assertEqual (importanceBin 10)   10)   ; Should return 10 (direct assignment)
!(assertEqual (importanceBin 20)  18)    ; Should calculate based on group logic 18
!(assertEqual (importanceBin 50)  29)    ; Should calculate based on group logic 29
;
!(assertEqual (update &atombin) ("Updated"))
!(assertEqual (getMaxSTI) 2.0)
!(assertEqual (getMinSTI) 1.0)
;
;;;Test cases that need to be refactored
! (assertEqual (updateImportance &atombin a 1 20) ("Importance Updated"))

!(assertEqual (getContent 1 ()) ())
; Normalize STI value 30 with clipping
!(assertEqual(getNormalisedZeroToOneSTI 30 False True) 1.0) 
; Normalize STI value 30 without clipping
!(assertEqual (getNormalisedZeroToOneSTI 30 False False) 14.0)
; Normalize STI value 70 with clipping
!(assertEqual (getNormalisedZeroToOneSTI 70 True True) 1.0) 
; Normalize STI value 70 without clipping
!(assertEqual (getNormalisedZeroToOneSTI 70 True False) 69.0) 


