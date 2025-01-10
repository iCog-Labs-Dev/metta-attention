!(register-module! ../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:bank:importance-index)


; Test importanceBin function
!(assertEqual (importanceBin -5)  0)    ; Should return 0
!(assertEqual (importanceBin 10)   10)   ; Should return 10 (direct assignment)
!(assertEqual (importanceBin 20)  18)    ; Should calculate based on group logic 18
!(assertEqual (importanceBin 50)  29)    ; Should calculate based on group logic 29
