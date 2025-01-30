!(register-module! ../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:bank:atombins)
!(import! &self metta-attention:attention-bank:bank:importance-index)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:stochastic-importance-diffusion)
!(import! &self metta-attention:attention-bank:bank:get-min-max-content)

!(add-atom &atombin (1 (a b)))
!(setAv a (1 1 1))

; !(elapsed_time a)

!(update_bin a)

;Currently not removeing the atom from the diffusionrecordbin space before adding
; !(update_bin a)
; !(update_bin a)
!(match &diffusionrecordbin (1 $_) (1 $_))
