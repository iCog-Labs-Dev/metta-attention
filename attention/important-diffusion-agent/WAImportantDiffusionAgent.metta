
;======================================================



;function spreadImportance
;param None
;return None
; Carries out the importance diffusion process, spreading STI along the
; graph according to the configuration settings
(: spreadImportance (-> empty))

(= (spreadImportance)
    (
        let $sourceVec (diffusionSourceVector)
        (if (== $sourceVec ())
            (empty)
            (let* (
                ($target (car-atom $sourceVec))
                ($diffuse (diffuseAtom $target))
                ($val (processDiffusionStack))
                )
                ($target)
            
            )
        )
    )
)


;function diffusionSourceVector
;param None
;return Expression

(: diffusionSourceVector (-> Expression))
(= (diffusionSourceVector)
    (let* (
        ($randomAtom (getRandomAtomNotInAF))
        ($sources (removeHebbianLink ($randomAtom)))
        )
        $sources
    )
)