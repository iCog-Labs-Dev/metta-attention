!(register-module! ../../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)

;Test helper functions
!(assertEqual (findGroup 5 0 0) 3) ; Should return 3
!(assertEqual (findGroup 10 0 0) 4); Should return 4
!(assertEqual (ceil 5.7) 6)      ; Should return 6
!(assertEqual (ceil 7.3) 8)     ; Should return 8
!(assertEqual (truncate 5.7) 5)  ; Should return 5
!(assertEqual (truncate 4.8)  4) ; Should return 4
!(assertEqual (pow 2 3)  8)      ; Should return 8
!(assertEqual (pow 2 4)  16)      ; Should return 16
