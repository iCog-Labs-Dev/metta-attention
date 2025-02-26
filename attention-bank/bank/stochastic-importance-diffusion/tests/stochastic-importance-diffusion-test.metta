!(register-module! ../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)

!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:atom-bins:get-min-max-content)

!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)

!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)

!(import! &self metta-attention:attention-bank:bank:stochastic-importance-diffusion:stochastic-importance-diffusion)
!(import! &test-kb metta-attention:attention-bank:bank:stochastic-importance-diffusion:tests:test-kb)

;add atoms for testing diffusedValue
;This sets the atom bin index's size to 2
!(add-atom &atombin (1 (node_a node_b)))

;This sets the STI of a to 1 which will give bin index of 1

;This will update the _bin
!(updateBin node_a &test-kb)
!(updateBin node_a &test-kb)


;This will the elapsed_time of the atom
;Since size is greater than zero it will return some value
;above zero
!(assertEqual (> (elapsedTime node_a &test-kb) 0.0) True)

;Since we have updated the _bin 3 times (considering elapsedTime updating the bin) and since the size of 
;the bin is 2 the below should return (3 2)
!(assertEqual (match (AtomBinInfo) (1 ((count $cnt_val) (index $idx_val) (_size $size_val) (update_rate $update_rate_val) (last_update $last_update_val))) 
    ($cnt_val $size_val)) (3 2))
!!(assertEqual (> (diffusedValue node_a 0.5 &test-kb) 0.5) True) 
!(assertEqual (diffusedValue node_a 1 &test-kb) 0) ;after on round the sti value 1 will have decreased by the decay rate=1 therefore, output becomes 0
