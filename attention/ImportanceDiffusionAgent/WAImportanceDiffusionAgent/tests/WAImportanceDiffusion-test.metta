!(import! &self ../../../../../PeTTa/lib/lib_he)
!(import! &self ../../../../../metta-attention/attention/AttentionParam)
!(import! &self ../../../../../metta-attention/attention-bank/utilities/helper-functions)
!(import! &self ../../../../../metta-attention/attention-bank/attention-value/getter-and-setter)
!(import! &self ../../../../../metta-attention/attention-bank/attention-value/get-min-max)
!(import! &self ../../../../../metta-attention/attention-bank/bank/attention-bank)
!(import! &self ../../../../../metta-attention/attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../../../../metta-attention/attention-bank/bank/importance-index/importance-index)
!(import! &self ../../../../../metta-attention/attention-bank/utilities/recentVal)
!(import! &self ../../../../../metta-attention/attention/Neighbors)
!(import! &self ../../../../../metta-attention/attention/ImportanceDiffusionAgent/ImportanceDiffusionBase/ImportanceDiffusionBase)
!(import! &self ../../../../../metta-attention/attention/ImportanceDiffusionAgent/WAImportanceDiffusionAgent/WAImportanceDiffusionAgent)
!(import! &self ../../../../../metta-attention/attention-bank/bank/stochastic-importance-diffusion/stochastic-importance-diffusion)


!(updateAttentionParam MAX_AF_SIZE 4.0)

!(stimulate source 400)
!(stimulate target1 300)
!(stimulate target2 300)
!(stimulate target3 300)
!(stimulate target4 200)



; !(updateBin target4)
!(match &atomBinInfo ($in $val) $val)
; !(match (TypeSpace) $x $x)
; !(getAv source)
!(getAfAtoms)

!(setStv (HEBBIAN_LINK source target1) (0.0 1.0))
!(setStv (HEBBIAN_LINK source target2) (0.0 1.0))
!(setStv (ASYMMETRIC_HEBBIAN_LINK source target3) (0.0 1.0))

!(setStv (INHERITANCE_LINK target3 source) (0.0 1.0))
!(setStv (INHERITANCE_LINK source target4) (0.0 1.0))
!(setStv (ASYMMETRIC_HEBBIAN_LINK target1 target2) (0.0 1.0))

!(setStv (ASYMMETRIC_HEBBIAN_LINK target2 target1) (0.0 1.0))



!(getSti target4)

!(WAImportanceDiffusionAgent-Run (TypeSpace))

!(match &atomBinInfo ($in $val) $val)
!(getSti (INHERITANCE_LINK source target4))
!(getSti target4)


!(WAImportanceDiffusionAgent-Run (TypeSpace))

!(test (< (getSti target4) 6000.0) True)
!(test (> (getSti (INHERITANCE_LINK source target4)) 0.0) True)
!(match &atomBinInfo ($in $val) $val)

!(getSti target4)
!(getSti (INHERITANCE_LINK source target4))

!(WAImportanceDiffusionAgent-Run (TypeSpace))
; !(py-call (time.sleep 1))
!(getSti target4)
!(getSti (INHERITANCE_LINK source target4))
!(match &atomBinInfo ($in $val) $val)


; !(setSti atom1 5)

; ; !(getSti atom1)

; ; !(elapsedTime atom1)
; !(diffusedValue atom1 0.4)
; !(match &atomBinInfo ($in $val) $val)

; !(py-call (time.sleep 1))

; ; !(elapsedTime atom1)
; !(diffusedValue atom1 0.4)
; !(match &atomBinInfo ($in $val) $val)


; !(py-call (time.sleep 5))

; ; !(elapsedTime atom1)
; !(diffusedValue atom1 0.4)
; !(match &atomBinInfo ($in $val) $val)
