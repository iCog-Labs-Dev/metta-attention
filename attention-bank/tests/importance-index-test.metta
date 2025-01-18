!(register-module! ../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:bank:atombins)
!(import! &self metta-attention:attention-bank:bank:importance-index)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)

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

! (assertEqual (update &atombin) ("Updated"))
! (assertEqual (getMaxSTI) (_maxSTI 3))
! (assertEqual (getMinSTI) (_minSTI 2))

;Test cases that need to be refactored
! (assertEqual (updateImportance &atombin a 1 20) ("Importance Updated"))
! (assertEqual (or (== (collapse (match &atombin ($x $y) ($x $y))) ((10 (d)) (18 (a c)))) 
                   (== (collapse (match &atombin ($x $y) ($x $y))) ((18 (a c)) (10 (d))))) 
                   True)

