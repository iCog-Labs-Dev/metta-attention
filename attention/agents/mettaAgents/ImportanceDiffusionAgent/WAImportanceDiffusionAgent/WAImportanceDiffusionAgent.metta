
(bind! maxSpreadPercentage 0.4)

;; This function will return the diffusion source vector (atoms that can be diffused) from WA
;; Parameters $space: The space that will be used to find the diffusion source vector
;; Return : The diffusion source vector

(: diffusionSourceVectorWA (-> Atom))
(= (diffusionSourceVectorWA)
    (let*
        (
            ($atoms (getRandomAtomNotInAF))
            ($result
                (if (== $atoms ())
                    ()
                    (if (== (get-metatype $atoms) Expression)
                        (if (== (car-atom $atoms) HEBBIAN_LINK)
                            (empty)
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

(: spreadImportanceWA (-> Grounded Empty))
(= (spreadImportanceWA $space)
    (let $diffusionSourceVector (collapse (diffusionSourceVectorWA))
        (if (== (size-atom $diffusionSourceVector) 0)
            ()
            (let $target (index-atom $diffusionSourceVector 0)
                (let ($atom $atomToReceive $stiGiven)
                        (diffuseAtom $target $space WA)
                             (tradeSti $atom $atomToReceive $stiGiven)
                        )
            )
        )
    )
)



;; This function will calculate the diffusion amount for WA
;; Parameters $atom: The atom that will be used to calculate the diffusion amount
;; Return : The diffusion amount

(: calculateDiffusionAmountWA (-> Atom Number))
(= (calculateDiffusionAmountWA $atom)
    (let*
        (
            ($currentEstiate (diffusedValue $atom (getAttentionParam MAX_SPREAD_PERCENTAGE)))
            ($diffusionAmount (- (getSTI $atom) $currentEstiate))
        )
        $diffusionAmount
    )
)

;; This function is the entry point to the WAImportance Diffusion Agent
;; Parameters $space: The space that will be used to find the diffusion source vector
;; Return : The spreadImportanceWA function is called

(: WAImportanceDiffusionAgent-Run (-> Grounded Empty))
(= (WAImportanceDiffusionAgent-Run $space)
    (spreadImportanceWA $space)
)