!(import! &self lib/lib_he)
!(import! &self lib/lib_spaces)
!(import! &self ../../../AttentionParam)
!(import! &self ../../../../attention-bank/utilities/helper-functions)
!(import! &self ../../../../attention-bank/attention-value/getter-and-setter)
!(import! &self ../../../../attention-bank/bank/attention-bank)
!(import! &self ../../../../attention-bank/utilities/recentVal)
!(import! &self ../../../../attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../../../attention-bank/bank/importance-index/importance-index)
!(import! &self ../../../Neighbors)
!(import! &self ../../ImportanceDiffusionBase/ImportanceDiffusionBase)
!(import! &self ../AFImportanceDiffusionAgent)



;;This are the same tests as the c++

;########################## Stimlating atoms so that they enter AF #############################
!(stimulate source 500)
!(stimulate target1 400)
!(stimulate target2 400)
!(stimulate target3 400)
!(stimulate target4 400)
!(stimulate target5 400)
!(stimulate target6 0)

;########################## Creating links between atoms #############################

!(setStv (ASYMMETRIC_HEBBIAN_LINK source target3) (0.6 0.1))
!(setStv (ASYMMETRIC_HEBBIAN_LINK source target4) (0.5 0.1))

!(setStv (INHERITANCE_LINK target3 source) (0 1))
!(setStv (INHERITANCE_LINK source target4) (0 1))
!(setStv (ASYMMETRIC_HEBBIAN_LINK target1 target2) (0 1))

!(setStv (ASYMMETRIC_HEBBIAN_LINK target2 target3) (0 1))
!(setStv (INHERITANCE_LINK source target5) (0 1))
!(setStv (INHERITANCE_LINK source target6) (0 1))
!(setStv (INHERITANCE_LINK (ASYMMETRIC_HEBBIAN_LINK source target4) target8) (0 1))
!(setStv (INHERITANCE_LINK target3 (ASYMMETRIC_HEBBIAN_LINK sorce target4)) (0 1))



;########################## Running the AF Importance Diffusion Agent #############################
!(AFImportanceDiffusionAgent-Run (TypeSpace))
;########################## Testing the STI values #############################
!(test (getSti source) 6000.0)
!(test (getSti target1) 8000.0)
!(test (getSti target2) 8000.0)
!(test (getSti target3) 4803.0)
!(test (getSti target4) 4802.5)
!(test (getSti target5) 4800.0)
!(test (getSti target6) 0.0)
!(test (getSti target7) 0.0)
!(test (getSti target8) 0.0)

!(test (getSti (HEBBIAN_LINK source target1)) 0.0)
!(test (getSti (HEBBIAN_LINK source target2)) 0.0)
!(test (getSti (ASYMMETRIC_HEBBIAN_LINK source target3)) 0.0)
!(test (getSti (INHERITANCE_LINK source target4)) 4198.625)
!(test (getSti (ASYMMETRIC_HEBBIAN_LINK target1 target2)) 0.0)
!(test (getSti (INHERITANCE_LINK source target5)) 4198.625)
!(test (getSti (INHERITANCE_LINK source target6)) 998.625)
!(test (getSti (INHERITANCE_LINK target3 source)) 2598.625)
!(test (getSti (ASYMMETRIC_HEBBIAN_LINK target2 target3)) 0.0)
!(test (getSti (INHERITANCE_LINK target3 (ASYMMETRIC_HEBBIAN_LINK sorce target4))) 1600.0)

; ;########################## Running the AF Importance Diffusion Agent #############################
!(AFImportanceDiffusionAgent-Run (TypeSpace))
; ;########################## Testing the STI values #############################
!(test (getSti source) 5998.9)
!(test (getSti target1) 8000.0)
!(test (getSti target2) 8000.0)
!(test (getSti target3) 4043.325)
!(test (getSti target4) 3722.725)
!(test (getSti target5) 3719.725)
!(test (getSti target6) 199.72500000000002)
!(test (getSti target7) 0.0)
!(test (getSti target8) 0.0)

!(test (getSti (HEBBIAN_LINK source target1)) 0.0)
!(test (getSti (HEBBIAN_LINK source target2)) 0.0)
!(test (getSti (ASYMMETRIC_HEBBIAN_LINK source target3)) 0.0)
!(test (getSti (INHERITANCE_LINK source target4)) 5039.35)
!(test (getSti (ASYMMETRIC_HEBBIAN_LINK target1 target2)) 0.0)
!(test (getSti (INHERITANCE_LINK source target5)) 5038.35)
!(test (getSti (INHERITANCE_LINK source target6)) 1198.35)
!(test (getSti (ASYMMETRIC_HEBBIAN_LINK target2 target3)) 0.0)
!(test (getSti (INHERITANCE_LINK target3 (ASYMMETRIC_HEBBIAN_LINK sorce target4))) 1920.6)

