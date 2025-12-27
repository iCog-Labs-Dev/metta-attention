!(bind! &insect (new-space))
!(bind! &poison (new-space))
!(bind! &diseases (new-space))
!(bind! &species (new-space))
!(bind! &tempspace (new-space))

!(import! &self ../../../../metta-attention/experiments/Metta/experiment1/data/insect-words)
!(let $x (get-atoms &self) (add-atom &insect $x))
!(let $x (match &self $y $y) (remove-atom &self $y))

!(import! &self ../../../../metta-attention/experiments/Metta/experiment1/data/poison-words)
!(let $x (get-atoms &self) (add-atom &poison $x))
!(let $x (match &self $y $y) (remove-atom &self $y))

!(import! &self ../../../../metta-attention/experiments/Metta/experiment1/data/species)
!(let $x (get-atoms &self) (add-atom &species $x))
!(let $x (match &self $y $y) (remove-atom &self $y))

!(import! &self ../../../../metta-attention/experiments/Metta/experiment1/data/diseases)
!(let $x (get-atoms &self) (add-atom &diseases $x))
!(let $x (match &self $y $y) (remove-atom &self $y))

!(import! &self ../../../../metta-attention/experiments/Metta/experiment1/data/links)
!(let $x (get-atoms &self) (add-atom &tempspace $x))
!(let $x (match &self $y $y) (remove-atom &self $y))

!(import! &self ../../../../metta-attention/attention/AttentionParam)
!(import! &self ../../../../metta-attention/attention-bank/utilities/helper-functions)
!(import! &self ../../../../metta-attention/attention-bank/utilities/recentVal)

!(import! &self ../../../../metta-attention/attention-bank/attention-value/getter-and-setter)
!(import! &self ../../../../metta-attention/attention-bank/bank/attention-bank)
!(import! &self "../../../../metta-attention/experiments/utils/logger.py")
!(import! &self ../../../../metta-attention/experiments/logger)
!(import! &self ../../../../metta-attention/attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../../../metta-attention/attention-bank/bank/importance-index/importance-index)
!(import! &self ../../../../metta-attention/attention-bank/bank/stochastic-importance-diffusion/stochastic-importance-diffusion)
!(import! &self ../../../../metta-attention/attention/RentCollectionAgent/RentCollectionBaseAgent/RentCollectionBaseAgent)
!(import! &self ../../../../metta-attention/attention/RentCollectionAgent/WARentCollectionAgent/WARentCollectionAgent)
!(import! &self ../../../../metta-attention/attention/RentCollectionAgent/AFRentCollectionAgent/AFRentCollectionAgent)
!(import! &self ../../../../metta-attention/attention/ImportanceDiffusionAgent/WAImportanceDiffusionAgent/WAImportanceDiffusionAgent)
!(import! &self ../../../../metta-attention/attention/ImportanceDiffusionAgent/AFImportanceDiffusionAgent/AFImportanceDiffusionAgent)
!(import! &self ../../../../metta-attention/attention/ImportanceDiffusionAgent/ImportanceDiffusionBase/ImportanceDiffusionBase)
!(import! &self ../../../../metta-attention/attention/HebbianUpdatingAgent/HebbianUpdatingAgent)
!(import! &self ../../../../metta-attention/attention/HebbianCreationAgent/HebbianCreationAgent)
!(import! &self ../../../../metta-attention/attention/Neighbors)
!(import! &self ../../../../metta-attention/experiments/runner-Def)


(= (spaceAdder) (get-atoms &tempspace))
!(match &tempspace ($atom $val) (setStv $atom $val))

; write the params to a file
!(updateAttentionParam MAX_AF_SIZE 10.0)
!(updateAttentionParam TARGET_STI 1000.0) 
!(updateAttentionParam TARGET_LTI 1000.0) 
!(updateAttentionParam STI_FUNDS_BUFFER 1000.0) 
!(updateAttentionParam LTI_FUNDS_BUFFER 1000.0) 
!(updateAttentionParam FUNDS_STI 2000.0) 
!(updateAttentionParam FUNDS_LTI 2000.0) 

!(start-log (attentionParam) "experiments/Metta/experiment1/")

(= (insectPoisonExp $maxim $space $type)
    (
        (if (< $maxim 0)
            finished
            (let* 
                (
                    ($words (collapse (match $space ($type $x) $x)))
                    ($randInt1 (random-int 0 (size-atom $words)))
                    ($randInt2 (random-int 0 (size-atom $words)))
                    ($randomWord1 (index-atom $words $randInt1))
                )
                (
                    (stimulate $randomWord1 30)
                    ; (println! ($type $randomWord1))
                    (collapse (test-superpose))
                    (let $newMaxim (- $maxim 1)
                        (if (> $maxim 2)
                            (insectPoisonExp $newMaxim  &insect insect)
                            (insectPoisonExp $newMaxim  &poison poison)
                        )
                    )
                )
            )
        )     
    )
)


!(insectPoisonExp 3 &insect insect)
