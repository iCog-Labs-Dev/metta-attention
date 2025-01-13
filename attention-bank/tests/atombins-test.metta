!(register-module! ../../../metta-attention)
!(import! &self metta-attention:attention-bank:bank:atombins)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)

;
!(add-atom &atombin (1 (a)))
!(add-atom &atombin (2 (d)))
!(add-atom &atombin (3 (c)))
!(add-atom &atombin (4 ()))
!(add-atom &atombin (5 (f h j k)))
!(setAv a (0 0 0))
!(setAv d (7 4 0))
!(setAv c (0 0 0))


!(let $res (collapse (getRandomAtom)) (assertEqual (size $res 0) 1))
