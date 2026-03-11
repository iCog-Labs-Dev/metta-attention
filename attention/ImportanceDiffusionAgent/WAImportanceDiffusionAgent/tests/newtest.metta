!(bind! &inc (new-space))

;; This function will return the diffusion source vector (atoms that can be diffused) from WA
!(import! &self lib/lib_he)
!(import! &self lib/lib_spaces)
; !(import! &self ../../../../experiments/logger)
; !(import! &self "../../../../experiments/utils/logger.py")
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
!(import! &self ../../AFImportanceDiffusionAgent/AFImportanceDiffusionAgent)
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
!(setStv (ASYMMETRIC_HEBBIAN_LINK source target3) (0.1 1.0))

!(setStv (INHERITANCE_LINK target3 source) (0.0 1.0))
!(setStv (INHERITANCE_LINK source target4) (0.0 1.0))
!(setStv (INHERITANCE_LINK target3 target4) (0.0 1.0))
!(setStv (ASYMMETRIC_HEBBIAN_LINK target4 target2) (0.3 1.0))

; !(setStv (ASYMMETRIC_HEBBIAN_LINK target2 target1) (0.0 1.0))


!(add-atom &incident
    (target4
        (
            ((INHERITANCE_LINK source target4) (0.0 1.0))
            ((INHERITANCE_LINK target4 target3) (0.0 1.0))
        )
    )
)

(diffuseIncidentWA target4 &incident)
(diffuseIncidentWA target4 &incident)

(diffuseHebbianWA source (TypeSpace) 1)
(diffuseAtom source (TypeSpace) WA)


(diffuseHebbianWA source (TypeSpace) 1)
(diffuseAtom source (TypeSpace) WA)

(let $diffusionSourceVector (diffusionSourceVectorWA)
    (if (== $diffusionSourceVector ())
        ()
        (let* 
            (
                ($1 (println! (diffusionSourceVector $diffusionSourceVector)))
                ($output 
                    (collapse (superpose (
                        (diffuseIncidentWA $diffusionSourceVector &incident)
                        (diffuseHebbianWA $diffusionSourceVector (TypeSpace) 1)
                    ))))
                ($trades (collapse (tradeList $output)))  
            ) 
            $trades
        )
    )
)

(let $diffusionSourceVector (diffusionSourceVectorWA)
    (if (== $diffusionSourceVector ())
        ()
        (let* 
            (
                ($1 (println! (diff $diffusionSourceVector)))
                ($output 
                    (collapse (superpose (
                        (diffuseIncidentWA $diffusionSourceVector &incident)
                        (diffuseHebbianWA $diffusionSourceVector (TypeSpace) 1)
                 ))))
            ) 
            $output 
        )
    )
)



!(WAImportanceDiffusionAgent-Run &incident)
!(println! (++====================))
(println! (here))
(py-call (time.sleep 1.3))
!(WAImportanceDiffusionAgent-Run &incident)
!(println! (++====================))
(WAImportanceDiffusionAgent-Run &incident)
!(println! (++====================))
(WAImportanceDiffusionAgent-Run &incident)
!(println! (++====================))
!(getSti (INHERITANCE_LINK source target4))

!(match (TypeSpace) $x $x)


(union-atom (a) ())
(car-atom (collapse (match (TypeSpace) (var) var)))
