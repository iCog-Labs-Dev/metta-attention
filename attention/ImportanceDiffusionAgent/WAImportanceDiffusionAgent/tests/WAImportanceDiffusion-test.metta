!(import! &self lib/lib_he)
!(import! &self lib/lib_spaces)
!(import! &self ../../../AttentionParam)
!(import! &self ../../../../attention-bank/utilities/helper-functions)
!(import! &self ../../../../attention-bank/bank/importance-index/importance-index)
!(import! &self ../../../../attention-bank/attention-value/getter-and-setter)
!(import! &self ../../../../attention-bank/bank/attention-bank)
!(import! &self ../../../../attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../../../attention-bank/utilities/recentVal)
!(import! &self ../../../Neighbors)
!(import! &self ../../../../attention-bank/bank/stochastic-importance-diffusion/stochastic-importance-diffusion)
!(import! &self ../../ImportanceDiffusionBase/ImportanceDiffusionBase)
!(import! &self ../WAImportanceDiffusionAgent)


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
