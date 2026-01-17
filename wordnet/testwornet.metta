!(bind! &wordnet (new-space))
!(bind! &conceptnet (new-space))


!(import! &self ../../PeTTa/lib/lib_he)
!(import! &self ../../metta-attention/attention/AttentionParam)
!(import! &self ../../metta-attention/attention-bank/utilities/helper-functions)
!(import! &self ../../metta-attention/attention-bank/attention-value/getter-and-setter)
!(import! &self ../../metta-attention/attention-bank/bank/attention-bank)
!(import! &self ../../metta-attention/attention-bank/bank/importance-index/importance-index)
!(import! &self ../../metta-attention/attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../metta-attention/attention-bank/utilities/recentVal)


!(import! &self ../../metta-attention/attention-bank/bank/stochastic-importance-diffusion/stochastic-importance-diffusion)
!(import! &self ../../metta-attention/attention/RentCollectionAgent/RentCollectionBaseAgent/RentCollectionBaseAgent)
!(import! &self ../../metta-attention/attention/RentCollectionAgent/WARentCollectionAgent/WARentCollectionAgent)
!(import! &self ../../metta-attention/attention/RentCollectionAgent/AFRentCollectionAgent/AFRentCollectionAgent)
!(import! &self ../../metta-attention/attention/ImportanceDiffusionAgent/ImportanceDiffusionBase/ImportanceDiffusionBase)
!(import! &self ../../metta-attention/attention/ImportanceDiffusionAgent/WAImportanceDiffusionAgent/WAImportanceDiffusionAgent)
!(import! &self ../../metta-attention/attention/ImportanceDiffusionAgent/AFImportanceDiffusionAgent/AFImportanceDiffusionAgent)
!(import! &self ../../metta-attention/attention/HebbianUpdatingAgent/HebbianUpdatingAgent)
!(import! &self ../../metta-attention/attention/HebbianCreationAgent/HebbianCreationAgent)
!(import! &self ../../metta-attention/experiments/runner-Def)


!(import! &self lib/lib_import)
!(static-import! &wordnet wordnet_stv_reordered)
; !(static-import! &conceptnet conceptnet_stv_clean)

; !(getAttentionParam MIN_STI)
; !(getAttentionParam MAX_STI)

!(updateAttentionParam MAX_AF_SIZE 20.0)
; !(updateAttentionParam TARGET_STI 1000.0) 
; !(updateAttentionParam TARGET_LTI 1000.0) 
; !(updateAttentionParam STI_FUNDS_BUFFER 1000.0) 
; !(updateAttentionParam LTI_FUNDS_BUFFER 1000.0) 
; !(updateAttentionParam FUNDS_STI 2000.0) 
; !(updateAttentionParam FUNDS_LTI 2000.0) 
; !(updateAttentionParam AFRentFrequency 9.0)

; !(match &conceptnet ($atom ($mean $conf)) (stimulate $atom 1)) 
; !(match &wordnet ($atom ($mean $conf)) (setStv $atom ($mean $conf)))
!(match &wordnet ($atom ($mean $conf)) (stimulate $atom 1)) 

; !(getSti (insynset able able_a_01))
; !(getSti (insynset musky musky_s_01))
; !(getSti (insynset antepenultimate antepenultimate_s_01))

; !(getAfAtoms)
; !(getAfAtomsHelper 10)
; !(size-atom (getAllAtomsWithBins))
; !(getBinList (TypeSpace))
; !(test-superpose)
; !(HebbianUpdatingAgent-Run (TypeSpace))
; !(HebbianCreationAgent-Run (TypeSpace))
; !(sortDecend (getBinList (TypeSpace) ))
!(getAfAtomsHelper 10)
; !(getAttentionParam MAX_AF_SIZE)

; !(getAttentionParam MAX_STI)
; !(getAttentionParam MIN_STI)


