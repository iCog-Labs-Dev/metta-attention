
!(bind! &insect (new-space))
!(bind! &poison (new-space))
!(bind! &tempspace (new-space))
!(import! &insect ../../../../metta-attention/experiments/Metta/experiment2/data/insect-sent)

; !(let $x (get-atoms &self) (add-atom &insect $x))
; !(let $x (match &self $y $y) (remove-atom &self $y))

!(import! &poison ../../../../metta-attention/experiments/Metta/experiment2/data/poison-sent)
; !(let $x (get-atoms &self) (add-atom &poison $x))
; !(let $x (match &self $y $y) (remove-atom &self $y))

; !(import! &tempspace ../../../../metta-attention/experiments/Metta/experiment2/data/sent-kb)
; !(let $x (get-atoms &self) (add-atom &tempspace $x))
; !(let $x (match &self $y $y) (remove-atom &self $y))

!(import! &self lib/lib_import)
!(static-import! &wordnet wordnet_stv_clean)
; !(static-import! &conceptnet output)
; !(static-import! &conceptnet conceptnet_links_only)



!(import! &self ../../../../metta-attention/attention/AttentionParam)
!(import! &self ../../../../metta-attention/attention-bank/utilities/helper-functions)
!(import! &self ../../../../metta-attention/attention-bank/utilities/recentVal)

!(import! &self ../../../../metta-attention/attention-bank/attention-value/getter-and-setter)
!(import! &self ../../../../metta-attention/attention-bank/bank/attention-bank)
!(import! &self "../../../../metta-attention/experiments/utils/logger.py")
!(import! &self ../../../../metta-attention/experiments/logger)
!(import! &self ../../../../metta-attention/attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../../../metta-attention/attention-bank/bank/importance-index/importance-index)
!(import! &self ../../../../metta-attention/attention/Neighbors)
!(import! &self ../../../../metta-attention/attention-bank/bank/stochastic-importance-diffusion/stochastic-importance-diffusion)
!(import! &self ../../../../metta-attention/attention/RentCollectionAgent/RentCollectionBaseAgent/RentCollectionBaseAgent)
!(import! &self ../../../../metta-attention/attention/RentCollectionAgent/WARentCollectionAgent/WARentCollectionAgent)
!(import! &self ../../../../metta-attention/attention/RentCollectionAgent/AFRentCollectionAgent/AFRentCollectionAgent)
!(import! &self ../../../../metta-attention/attention/ImportanceDiffusionAgent/ImportanceDiffusionBase/ImportanceDiffusionBase)
!(import! &self ../../../../metta-attention/attention/ImportanceDiffusionAgent/WAImportanceDiffusionAgent/WAImportanceDiffusionAgent)
!(import! &self ../../../../metta-attention/attention/ImportanceDiffusionAgent/AFImportanceDiffusionAgent/AFImportanceDiffusionAgent)
!(import! &self ../../../../metta-attention/attention/HebbianUpdatingAgent/HebbianUpdatingAgent)
!(import! &self ../../../../metta-attention/attention/HebbianCreationAgent/HebbianCreationAgent)
!(import! &self ../../../../metta-attention/experiments/runner-Def)


!(match &wordnet ($atom ($mean $conf)) (setStv $atom ($mean $conf)))
; !(match &conceptnet ($atom ($mean $conf)) (setStv $atom ($mean $conf)))


; write the params to a file
!(updateAttentionParam MAX_AF_SIZE 20.0)
!(updateAttentionParam TARGET_STI 1000.0)
!(updateAttentionParam TARGET_LTI 1000.0) 
!(updateAttentionParam STI_FUNDS_BUFFER 1000.0) 
!(updateAttentionParam LTI_FUNDS_BUFFER 1000.0) 
!(updateAttentionParam FUNDS_STI 8000.0) 
!(updateAttentionParam FUNDS_LTI 8000.0) 


; write the params to a file
!(start-log (attentionParam) "experiments/Metta/experiment2/")

(= (insectPoisonReadExp $space $type $expr)
    (
        (if (and (== $type poisonSent) (== $expr ()))
            finished
            (let* 
                (
                    ($now (car-atom $expr))
                    ($rest (cdr-atom $expr))
                    
                )
                (
                    (stimulate $now 30)
                    (println! (stimulating atom --> $now))
                    ; ($sle (py-call (time.sleep 4)))
                    (collapse (test-superpose))
                    (let $d (if (== $rest ())
                            (if (== $type insectSent)
                                (insectPoisonReadExp &poison poisonSent (match &poison (poisonSent $x) $x))
                                finished
                    )
                 
                 (insectPoisonReadExp $space $type $rest))
                 $d
             )
                )
                )
            )
            
    )
)
!(insectPoisonReadExp &insect insectSent (match &insect (insectSent $x) $x))
