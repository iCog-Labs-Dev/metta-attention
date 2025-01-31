!(register-module! ../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:bank:atombins)
!(import! &self metta-attention:attention-bank:bank:importance-index)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:stochastic-importance-diffusion)
!(import! &self metta-attention:attention-bank:bank:get-min-max-content)

;This sets the atom bin index's size to 2
!(add-atom &atombin (1 (a b)))

;This sets the STI of a to 1 which will give bin index of 1
!(setAv a (1 1 1))

;This will update the _bin
!(update_bin a)
!(update_bin a)
!(update_bin a)

;This will the elapsed_time of the atom
; !(elapsed_time a)

;Since we have updated the _bin 3 times and since the size of 
;the bin is 2 the below should return (3 2)
!(assertEqual (match (diffusionrecordbin) (1 ((count $cnt_val) (index $idx_val) (_size $size_val) (update_rate $update_rate_val) (last_update $last_update_val))) 
    ($cnt_val $size_val)) (3 2))