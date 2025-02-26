!(register-module! ../../../../metta-attention)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)

!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &test-kb metta-attention:attention-bank:bank:tests:test-kb)

!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)

!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)

!(import! &self metta-attention:attention-bank:utilities:helper-functions)

; Example usage to compute STI and LTI wages
!(assertEqual (calculateSTIWage) 20.0)
!(assertEqual (calculateLTIWage) 20.0)

!(add-atom &atombin (1 (node_x)))
!(add-atom &atombin (10 (node_y)))
!(add-atom &atombin (18 (node_z)))
; Initial AttentionValues

; Stimulate the atom with a stimulus of 1.5
!(stimulate node_x 1.5 &test-kb)

; Retrieve the updated AttentionValue
!(assertEqual (getAV (getType &test-kb node_x)) (230.0 230.0 0))

;; Check updated funds
!(assertEqual (match &space (fundsSTI $x) $x) 99970.0)
!(assertEqual (match &space (fundsLTI $x) $x) 99970.0)

;; Stimulate the atom with a stimulus of 2
!(stimulate node_x 2 &test-kb)

;; Retrieve the updated AttentionValue
!(assertEqual (getAV (getType &test-kb node_x)) (270.0 270.0 0))

;; Check updated funds
!(assertEqual (match &space (fundsSTI $x) $x) 99930.0)
!(assertEqual (match &space (fundsLTI $x) $x) 99930.0)

;; Check the  attentional focus  is updated  when an atom is stimulated
!(assertEqual (getAtomList) (node_x))
!(stimulate node_y 2 &test-kb)

!(assertEqual (getAtomList) (node_x node_y))
