!(register-module! ../../../../metta-attention)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)

!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)

!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)

!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:utilities:recentVal)

; Example usage to compute STI and LTI wages
!(assertEqual (calculateSTIWage) 20.0)
!(assertEqual (calculateLTIWage) 20.0)

(add-atom &atombin (1 (x)))
(add-atom &atombin (10 (y)))
(add-atom &atombin (18 (z)))
; Initial AttentionValues
!(setAv x (200.0 200.0 0.0))
!(setAv y (200.0 200.0 0.0))
!(setAv z (200.0 200.0 0.0))

; Stimulate the atom with a stimulus of 1.5
!(stimulate x 1.5)

; Retrieve the updated AttentionValue
!(assertEqual (getAv x) (AV 230.0 230.0 0))

; Check updated funds
!(assertEqual (match &space (fundsSTI $x) $x) 99370.0)
!(assertEqual (match &space (fundsLTI $x) $x) 99370.0)

; Stimulate the atom with a stimulus of 2
!(stimulate x 2)

; Retrieve the updated AttentionValue
!(assertEqual (getAv x) (AV 270.0 270.0 0))

; Check updated funds
!(assertEqual (match &space (fundsSTI $x) $x) 99330.0)
!(assertEqual (match &space (fundsLTI $x) $x) 99330.0)

; Check the  attentional focus  is updated  when an atom is stimulated
!(assertEqual (getAtomList) (x y z))
!(stimulate y 2)
!(assertEqual (getAtomList) (x y z))
