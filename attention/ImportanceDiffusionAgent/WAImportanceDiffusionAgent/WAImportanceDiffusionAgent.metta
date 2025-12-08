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




;; This function will calculate the diffusion amount for WA
;; Parameters $atom: The atom that will be used to calculate the diffusion amount
;; Return : The diffusion amount

; (: calculateDiffusionAmountWA (-> Atom Number))
(= (calculateDiffusionAmountWA $atom)
    (let*
        (
            ($maxSpreadPercentage (getAttentionParam MAX_SPREAD_PERCENTAGE))
            ; ($sp (println! (max spredding perce $maxSpreadPercentage)))
            ($currentEstiate (eval (diffusedValue $atom $maxSpreadPercentage)))
            ; ($curr (println! (current estimate $currentEstiate for atom $atom)))

            ($diffusionAmount (- (getSti $atom) $currentEstiate))
            ; ($cur (println! (diffusion amount $diffusionAmount)))

        )
        $diffusionAmount
    )
)

;; This function is the entry point to the WAImportance Diffusion Agent
;; Parameters $space: The space that will be used to find the diffusion source vector
;; Return : The spreadImportanceWA function is called

; (: WAImportanceDiffusionAgent-Run (-> Grounded Empty))
(= (WAImportanceDiffusionAgent-Run $space)
    (eval (spreadImportanceWA $space))
)
