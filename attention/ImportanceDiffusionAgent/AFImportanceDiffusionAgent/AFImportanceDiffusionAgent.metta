;; This function will return the diffusion source vector (atoms that can be diffused) from AF
;; Parameters $space: The space that will be used to find the diffusion source vector
;; Return : The diffusion source vector

; (: diffusionSourceVector (-> Grounded Atom))
(= (diffusionSourceVector $list)
    (let $q (collapse (let*
        (
        ($superposed (superpose $list))
        ($x (unify (HEBBIAN_LINK $a1 $a2) $superposed (HEBBIAN_LINK $a1 $a2) ()))
        ($y (unify $a $superposed (if (== (get-metatype $a) Expression) () $a) ()))
        )
         (if (and (== $y ()) (== $x ())) Empty (cons-atom $y $x))
    )) (flatten $q))
)


;; This function will calculate the diffusion amount
;; Parameters $atom: The atom that will be used to calculate the diffusion amount
;; Return : The diffusion amount

(: calculateDiffusionAmount (-> Atom Number))
(= (calculateDiffusionAmount $atom)
    (* (getSti $atom) (getAttentionParam MAX_SPREAD_PERCENTAGE))
)

;;This function will retrieve the diffusion source vector from AF and then call the diffuseAtom function to diffuse the atoms
;; Parameters $space: The space that will be used to find the diffusion source vector
;;            $space2: The space that will be used to find incomingSets
;; Return : The diffusion get called

; (: spreadImportance (-> Grounded Grounded Empty))
(= (spreadImportance $space)
    (let $diffusionSourceVector (diffusionSourceVector (afAtoms))
        (let ($atom $atomToReceive $stiGiven)
            (diffuseAtom (superpose $diffusionSourceVector) $space AF)
                (tradeSti $atom $atomToReceive $stiGiven)
            )
    )
)

;; This function is the entry point to the AFImportance Diffusion Agent
;; Parameters $space: The space that will be used to find the diffusion source vector
;;            $space2: The space that will be used to find incomingSets
;; Return : The spreadImportance function is called

; (: AFImportanceDiffusionAgent-Run (-> Grounded Grounded Empty))
(= (AFImportanceDiffusionAgent-Run $space)
    (spreadImportance $space)
)
