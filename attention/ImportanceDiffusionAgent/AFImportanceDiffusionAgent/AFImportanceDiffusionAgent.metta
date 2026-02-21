;; This function will return the diffusion source vector (atoms that can be diffused) from AF
;; Parameters $space: The space that will be used to find the diffusion source vector
;; Return : The diffusion source vector

; (: diffusionSourceVector (-> Grounded Atom))
(= (diffusionSourceVector $list)
    (collapse 
        (let
            $temp 
            (superpose $list)
            (if (== (get-metatype $temp) Expression)
                (if (== (car-atom $temp) HEBBIAN_LINK)
                    (empty)
                    $temp
                )
                $temp
                
            )
        )
    ) 
)


;; This function will calculate the diffusion amount
;; Parameters $atom: The atom that will be used to calculate the diffusion amount
;; Return : The diffusion amount


;;This function will retrieve the diffusion source vector from AF and then call the diffuseAtom function to diffuse the atoms
;; Parameters $space: The space that will be used to find the diffusion source vector
;;            $space2: The space that will be used to find incomingSets
;; Return : The diffusion get called

; (: spreadImportance (-> Grounded Grounded Empty))
; (= (spreadImportance $space)
;         (let*
;         (
;             ($difatoms (getAfAtoms))
;             ($atoms (collapse 
;                 (let $atom
;                     (superpose $difatoms)
;                     (diffuseAtom $atom $space AF))
;                 )
;             )
;             ($p (println! (working for (tradeList $atoms)))) 
;             (($atom $sti) (tradeList $atoms))
            
;         )
;          (collapse (setSti $atom $sti))
;         )
;     )

(= (spreadImportance $space)
    (let $diffusionSourceVector (diffusionSourceVector (getAfAtoms))
        (let ($atom $atomToReceive $stiGiven)
            (diffuseAtom (superpose $diffusionSourceVector) $space AF)
                (tradeSti $atom $atomToReceive $stiGiven)
            )
    )
)


(: tradeList (-> Expression Expression))
(= (tradeList $result)
    (let*
        (
            ($diffusingAtoms (collapse 
                (let ($atom $atomToReceive $stiGiven)
                    (superpose $result)
                    $atom 
                )
            ))
            ($recivingAtoms (collapse 
                (let ($atom $atomToReceive $stiGiven)
                    (superpose $result)
                    $atomToReceive 
                )
            ))
            ($combindedAtoms (union-atom $diffusingAtoms $recivingAtoms))
            ($sources (unique-atom $combindedAtoms))
            ($source (superpose $sources))
            ($sourceSti (collapse (filterTrade $result $source)))
            ($trade (foldl-atom $sourceSti 0 $acc $x (+ $acc $x)))
            ($newTrade (+ (getSti $source) $trade))
        )
        ($source $newTrade)
    )
)

;; This function filters returns sti transfers for a given atom and negates all values 
;; where it is giving sti
;; Parameters:
;;      $result: list of all trades
;;      $source: atom in consideration
;; Result: (non - deterministic)
;;      Number value of sti trade of an atom
; (: filterTrade (-> Expression Atom Number))
(= (filterTrade $result $source)
    (let ($atom $atomToReceive $stiGiven)
        (superpose $result)
        (if (== $atom $source)
            (* -1 $stiGiven)
            (if (== $atomToReceive $source)
                $stiGiven
                (empty)
            )
        )
    )
)
;; This function is the entry point to the AFImportance Diffusion Agent
;; Parameters $space: The space that will be used to find the diffusion source vector
;;            $space2: The space that will be used to find incomingSets
;; Return : The spreadImportance function is called

; (: AFImportanceDiffusionAgent-Run (-> Grounded Grounded Empty))
(= (AFImportanceDiffusionAgent-Run $space)
    (with_mutex afmutex 
        (spreadImportance $space)
    )
)
