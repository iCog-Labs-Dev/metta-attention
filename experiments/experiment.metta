
!(bind! &insect (new-space))
!(bind! &poison (new-space))
!(bind! &tempspace (new-space))
!(import! &insect data/insect-sent)

; !(let $x (get-atoms &self) (add-atom &insect $x))
; !(let $x (match &self $y $y) (remove-atom &self $y))

!(import! &poison data/poison-sent)
; !(let $x (get-atoms &self) (add-atom &poison $x))
; !(let $x (match &self $y $y) (remove-atom &self $y))

; !(import! &tempspace data/sent-kb)
; !(import! &tempspace data/adagram)
; !(let $x (get-atoms &self) (add-atom &tempspace $x))
; !(let $x (match &self $y $y) (remove-atom &self $y))

!(import! &self lib/lib_import)
!(import! &self lib/lib_spaces)
!(static-import! &wordnet data/wordnet_stv_clean)
; !(static-import! &conceptnet data/conceptnet_stv_clean)

!(import! &self ../attention/AttentionParam)
!(import! &self ../attention-bank/utilities/helper-functions)
!(import! &self ../attention-bank/utilities/recentVal)

!(import! &self ../attention-bank/attention-value/getter-and-setter)
!(import! &self ../attention-bank/bank/attention-bank)
!(import! &self "utils/logger.py")
!(import! &self logger)
!(import! &self ../attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../attention-bank/bank/importance-index/importance-index)
!(import! &self ../attention/Neighbors)
!(import! &self ../attention-bank/bank/stochastic-importance-diffusion/stochastic-importance-diffusion)
!(import! &self ../attention/RentCollectionAgent/RentCollectionBaseAgent/RentCollectionBaseAgent)
!(import! &self ../attention/RentCollectionAgent/WARentCollectionAgent/WARentCollectionAgent)
!(import! &self ../attention/RentCollectionAgent/AFRentCollectionAgent/AFRentCollectionAgent)
!(import! &self ../attention/ImportanceDiffusionAgent/ImportanceDiffusionBase/ImportanceDiffusionBase)
!(import! &self ../attention/ImportanceDiffusionAgent/WAImportanceDiffusionAgent/WAImportanceDiffusionAgent)
!(import! &self ../attention/ImportanceDiffusionAgent/AFImportanceDiffusionAgent/AFImportanceDiffusionAgent)
!(import! &self ../attention/HebbianUpdatingAgent/HebbianUpdatingAgent)
!(import! &self ../attention/HebbianCreationAgent/HebbianCreationAgent)
!(import! &self ../attention/runner-Def)


!(match &wordnet ($atom ($mean $conf)) (setStv $atom ($mean $conf)))
; !(match &conceptnet ($atom ($mean $conf)) (setStv $atom ($mean $conf)))
; !(match &tempspace ($atom ($mean $conf)) (setStv $atom ($mean $conf)))


; write the params to a file
!(updateAttentionParam MAX_AF_SIZE 100.0)
!(updateAttentionParam TARGET_STI 1000.0)
!(updateAttentionParam TARGET_LTI 1000.0) 
!(updateAttentionParam STI_FUNDS_BUFFER 1000.0) 
!(updateAttentionParam LTI_FUNDS_BUFFER 1000.0) 
!(updateAttentionParam FUNDS_STI 100000.0) 
!(updateAttentionParam FUNDS_LTI 100000.0) 

; !(updateAttentionParam STI_FUNDS_BUFFER 99900)
; !(updateAttentionParam LTI_FUNDS_BUFFER 99900)
; !(updateAttentionParam TARGET_STI 99900)
; !(updateAttentionParam TARGET_LTI 99900)
; !(updateAttentionParam AFRentFrequency 2.0)
; !(updateAttentionParam MAX_AF_SIZE 12)


; write the params to a file
!(start-log (attentionParam) "experiments")

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
                    (stimulate $now 300)
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


