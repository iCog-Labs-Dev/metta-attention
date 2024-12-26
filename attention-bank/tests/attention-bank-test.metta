!(register-module! ../../../metta-attention)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:attention-bank)

; Example usage to compute STI and LTI wages
!(assertEqual (calculateSTIWage) 20.0)
!(assertEqual (calculateLTIWage) 20.0)

; Initial AttentionValues
!(set_av E (200 200 0))

; Stimulate the atom with a stimulus of 1.5
!(stimulate E 1.5)

; Retrieve the updated AttentionValue
!(assertEqual (get_av E) (AV 230.0 230.0 0))

; Check updated funds
!(assertEqual (match &space (fundsSTI $x) $x) 99970.0)
!(assertEqual (match &space (fundsLTI $x) $x) 99970.0)

; Stimulate the atom with a stimulus of 2
!(stimulate E 2)

; Retrieve the updated AttentionValue
!(assertEqual (get_av E) (AV 270.0 270.0 0))

; Check updated funds
!(assertEqual (match &space (fundsSTI $x) $x) 99930.0)
!(assertEqual (match &space (fundsLTI $x) $x) 99930.0)

