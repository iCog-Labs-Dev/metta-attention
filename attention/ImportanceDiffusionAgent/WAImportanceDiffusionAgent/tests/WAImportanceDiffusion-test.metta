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

!(bind! &incident (new-space))

!(updateAttentionParam MAX_AF_SIZE 4.0)

!(stimulate source 400)
!(stimulate target1 300)
!(stimulate target2 300)
!(stimulate target3 300)
!(stimulate target4 200)

;########################## Creating incident links between atoms #############################
!(add-atom &incident 
    (source 
        (
            (INHERITANCE_LINK target3 source)
            (INHERITANCE_LINK source target4)
            (INHERITANCE_LINK source target5)
            (INHERITANCE_LINK source target6)
        )
    )
)

!(add-atom &incident (target3 ( (INHERITANCE_LINK target3 (ASYMMETRIC_HEBBIAN_LINK sorce target4)) (INHERITANCE_LINK target3 source))))
!(add-atom &incident (target4 ( (INHERITANCE_LINK source target4))))
!(add-atom &incident (target5 ( (INHERITANCE_LINK source target5))))
!(add-atom &incident (target6 ( (INHERITANCE_LINK source target6))))
!(add-atom &incident (target8 ( (INHERITANCE_LINK (ASYMMETRIC_HEBBIAN_LINK source target4) target8))))

!(match &atomBinInfo ($in $val) $val)

!(setStv (ASYMMETRIC_HEBBIAN_LINK source target3) (0.0 1.0))
!(setStv (ASYMMETRIC_HEBBIAN_LINK target1 target2) (0.0 1.0))
!(setStv (ASYMMETRIC_HEBBIAN_LINK target2 target1) (0.0 1.0))

!(WAImportanceDiffusionAgent-Run &incident)

!(match (TypeSpace) 
        ((INHERITANCE_LINK source target4) $val) 
        (remove-atom &typeSpace ((INHERITANCE_LINK source target4) $val))
 )
!(py-call (time.sleep 0.5))

!(WAImportanceDiffusionAgent-Run &incident)

!(test (< (getSti target4) 6000.0) True)
!(test (> (getSti (INHERITANCE_LINK source target4)) 0.0) True)

!(match (TypeSpace) 
        ((INHERITANCE_LINK source target4) $val) 
        (remove-atom &typeSpace ((INHERITANCE_LINK source target4) $val))
 )
!(WAImportanceDiffusionAgent-Run &incident)

!(test (< (getSti target4) 6000.0) True)
!(test (> (getSti (INHERITANCE_LINK source target4)) 0.0) True)
