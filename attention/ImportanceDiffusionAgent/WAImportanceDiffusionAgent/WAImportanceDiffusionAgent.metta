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



;; This function is the entry point to the WAImportance Diffusion Agent
;; Parameters $space: The space that will be used to find the diffusion source vector
;; Return : The spreadImportanceWA function is called

; (: WAImportanceDiffusionAgent-Run (-> Grounded Empty))
(= (WAImportanceDiffusionAgent-Run $space)
  (with_mutex wamutex 
    (spreadImportanceWA $space)
  )
)


