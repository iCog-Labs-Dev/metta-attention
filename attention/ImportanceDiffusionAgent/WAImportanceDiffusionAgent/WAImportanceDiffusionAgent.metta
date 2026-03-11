;; This function will return the diffusion source vector (atoms that can be diffused) from WA
;; Parameters $space: The space that will be used to find the diffusion source vector
;; Return : The diffusion source vector

; (: diffusionSourceVectorWA (-> Atom))
(= (diffusionSourceVectorWA)
    (let*
        (
            ($atoms (getRandomAtomNotInAF))
            ; ($at (println! (this is non af atom $atoms)))
            ($result
                (if (== $atoms ())
                    ()
                    (if (== (get-metatype $atoms) Expression)
                        (if (== (car-atom $atoms) HEBBIAN_LINK)
                            ()
                            $atoms
                        )
                        $atoms
                    )
                )
            )
        )
        $result
    )
)

;;This function will retrieve the diffusion source vector from WA and then call the diffuseAtom function to diffuse the atoms
;; Parameters $space: The space that will be used to find the diffusion source vector
;; Return : The diffusion get called

; (: spreadImportanceWA (-> Grounded Empty))
(= (spreadImportanceWA $space)
    (let $diffusionSourceVector (collapse (diffusionSourceVectorWA))
        (if (== (size-atom $diffusionSourceVector) 0.0)
            ()
            (let* 
            (
                ($target (index-atom $diffusionSourceVector 0))
                (($atom $atomToReceive $stiGiven) (diffuseAtom $target $space WA))
                ; ($_ (println! (inside spread importance wa this $atom $atomToReceive $stiGiven)))
            ) 
                (tradeSti $atom $atomToReceive $stiGiven)
            )
        )
    )
)



(= (diffuseIncidentWA $atom $space $diffAmount $diffPercentage)
    (let*
        (
            ($foset (if (= (get-metatype $atom) Expression) (cdr-atom $atom) ()))
            ($incidentAtoms (unify $space ($atom $incidents) $incidents ()))
            ($incidentAndoset (union-atom $foset $incidentAtoms))
            ($diffsize (size-atom $incidentAndoset))
            ($diffuseTo (superpose $incidentAndoset))
            ($2 (println! (diffAmoun $diffAmount)))
            ($stiGiven (* (/ $diffPercentage $diffsize) $diffAmount))
            ($atomToReceive (if (= (get-metatype $diffuseTo) Expression) (car-atom $diffuseTo) $diffuseTo))
            ($1 (println! (out $atomToReceive $atom $stiGiven)))
        ) 
        ($atom $atomToReceive $stiGiven)
    )
)

(= (diffuseHebbianWA $atom $diffsize $diffAmount $diffPercentage) 
    (let*
        (
            ($stiportion (/ $diffPercentage $diffsize))
            (($atomToReceive (STV $mean $conf)) 
                (match (TypeSpace) ((ASYMMETRIC_HEBBIAN_LINK $atom $target) $val) ($target $val))
            )
            ($stiGiven (* (* $stiportion (* $mean $conf)) $diffAmount))
        )
        ($atom $atomToReceive $stiGiven)
    )
)

(= (diffuseWA $atom $incidentSpace $hebbainSpace) 
    (let*
        (
            ($size (* (getAttentionParam MAX_AF_SIZE) 0.3))
            ($sourceSti (getSti $atom))
            ($maxSpreadPercentage (getAttentionParam MAX_SPREAD_PERCENTAGE)) 
            ($hebbianMaximumLinkAllocation (getAttentionParam HEBBIAN_MAX_ALLOCATION_PERCENTAGE))
            ($diffAmount (- $sourceSti (diffusedValue $atom $maxSpreadPercentage)))
            ($afpercentage (* $maxSpreadPercentage (- 1 $hebbianMaximumLinkAllocation)))
            ($hebpercentage (* $maxSpreadPercentage $hebbianMaximumLinkAllocation))
        )
        (superpose (
            (diffuseIncidentWA $atom $incidentSpace $diffAmount $afpercentage)
            (diffuseHebbianWA $atom $size $diffAmount $hebpercentage)
        ))
    )
)
(= (spreadImportanceWA $incidentSpace $hebbainSpace)
    (let $diffusionSourceVector (diffusionSourceVectorWA)
        (if (== $diffusionSourceVector ())
            ()
            (let $output 
                (collapse (diffuseWA $diffusionSourceVector $incidentSpace $hebbainSpace))
                (
                    (setSti (tradeList $output))
                    (empty)
                )
            )
        )
    )
)
;; This function is the entry point to the WAImportance Diffusion Agent
;; Parameters $space: The space that will be used to find the diffusion source vector
;; Return : The spreadImportanceWA function is called

; (: WAImportanceDiffusionAgent-Run (-> Grounded Empty))
(= (WAImportanceDiffusionAgent-Run $space)
  ; (with_mutex wamutex 
    (spreadImportanceWA $space (TypeSpace))
  ; )
)


