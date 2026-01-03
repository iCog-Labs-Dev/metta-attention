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


!(import! &self lib/lib_import)
!(static-import! &wordnet wordnet_stv_reordered)
; !(static-import! &conceptnet conceptnet_stv_clean)

; !(getAttentionParam MIN_STI)
; !(getAttentionParam MAX_STI)

; !(match &wordnet ((insynset able able_a_01) $y) $y)
; !(match &wordnet ($atom ($mean $conf)) (setStv $atom ($mean $conf)))
!(match &wordnet ($atom ($mean $conf)) (stimulate $atom 1))
; !(getBinList &typeSpace)

!(getAttentionParam MIN_STI)
!(getAttentionParam MAX_STI)



