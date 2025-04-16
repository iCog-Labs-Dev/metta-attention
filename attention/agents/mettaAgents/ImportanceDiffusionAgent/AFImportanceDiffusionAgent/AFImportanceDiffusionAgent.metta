!(bind! maxSpreadPercentage 0.4)

;; This function will return the diffusion source vector (atoms that can be diffused) from AF
;; Parameters $space: The space that will be used to find the diffusion source vector
;; Return : The diffusion source vector

(: diffusionSourceVector (-> Grounded Atom))
(= (diffusionSourceVector $space)
    (let*
        (
            ($atoms (collapse (let $temp (match $space $x $x)
                (if (== (get-metatype $temp) Expression)
                    (if (== (car-atom $temp) ASYMMETRIC_HEBBIAN_LINK)  ;; Needs to be removed
                        (empty)
                        (if (== (car-atom $temp) HEBBIAN_LINK)
                            (empty)
                            $temp
                        )
                    )
                    $temp
                ))))
        )
        $atoms
    )
)


;; This function will calculate the diffusion amount
;; Parameters $atom: The atom that will be used to calculate the diffusion amount
;; Return : The diffusion amount

(: calculateDiffusionAmount (-> Atom Number))
(= (calculateDiffusionAmount $atom)
    (* (getSTI $atom) maxSpreadPercentage)
)

;;This function will retrieve the diffusion source vector from AF and then call the diffuseAtom function to diffuse the atoms
;; Parameters $space: The space that will be used to find the diffusion source vector
;;            $space2: The space that will be used to find incomingSets
;; Return : The diffusion get called

(: spreadImportance (-> Grounded Grounded Empty))
(= (spreadImportance $space $space2)
    (let $diffusionSourceVector (diffusionSourceVector $space)
        (let ($atom $atomToReceive $stiGiven)
            (diffuseAtom (superpose $diffusionSourceVector) $space2 AF)
                (tradeSti $atom $atomToReceive $stiGiven)
            )
    )
)

;; This function is the entry point to the AFImportance Diffusion Agent
;; Parameters $space: The space that will be used to find the diffusion source vector
;;            $space2: The space that will be used to find incomingSets
;; Return : The spreadImportance function is called

(: AFImportanceDiffusionAgent-Run (-> Grounded Grounded Empty))
(= (AFImportanceDiffusionAgent-Run $space $space2)
    (spreadImportance $space $space2)
)

