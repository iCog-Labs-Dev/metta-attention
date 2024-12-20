!(register-module! ../../../metta-attention)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:attention-bank)


;example usage to compute STI and LTI wages
!(assertEqual (calculate_STI_wage) 20.0)
!(assertEqual (calculate_LTI_wage) 20.0)

; Define a pattern and set initial AttentionValue
!(set_av C (200 200 0))

; Retrieve the AttentionValue of the atom before being stimulated
!(assertEqual (get_av C) (AV 200 200 0))


; Stimulate the atom with a stimulus of 1.5
!(stimulate C 1.5)

;Test helper functions to get sti,lti and vlti of an atom
!(assertEqual (get-sti C) 230.0)
!(assertEqual (get-lti C) 230.0)
!(assertEqual (get-vlti C) 0)

; Retrieve the updated AttentionValue
!(assertEqual (get_av C) (AV 230.0 230.0 0))