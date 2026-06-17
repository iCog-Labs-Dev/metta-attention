!(bind! &insect (new-space))
; !(bind! &poison (new-space))
!(import! &insect data/insect-sent)

!(import! &self lib/lib_import)
!(import! &self lib/lib_spaces)
!(import! &self lib/lib_he)
!(static-import! &incident ./data/kg)



!(import! &self ../attention/AttentionParam)
!(import! &self ../attention/baching)
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
!(import! &self "../attention/ImportanceDiffusionAgent/getelement.py")


(match &wordnet ($atom ($mean $conf)) (setStv $atom ($mean $conf)))
(match &conceptnet ($atom ($mean $conf)) (setStv $atom ($mean $conf)))
; !(match &tempspace ($atom ($mean $conf)) (setStv $atom ($mean $conf)))


; write the params to a file
!(updateAttentionParam MAX_AF_SIZE 70.0)
!(updateAttentionParam TARGET_STI 1000.0)
!(updateAttentionParam TARGET_LTI 1000.0) 
!(updateAttentionParam STI_FUNDS_BUFFER 1000.0) 
!(updateAttentionParam LTI_FUNDS_BUFFER 1000.0) 
!(updateAttentionParam FUNDS_STI 100000.0) 
!(updateAttentionParam FUNDS_LTI 100000.0) 
!(updateAttentionParam TOPK 0.5)




; write the params to a file
!(start-log (attentionParam) "experiments")

(= (batch) 25)
(= (runAttentionBatch)
    (let*
        (
            ($_agents (collapse (test-superpose &incident)))
        )
        True
    )
)


(= (insectPoisonReadExp $expr $counter)
    (if (== $expr ())
        (let $_done (println! (finished-read count $counter)) True)
        (let*
            (
                ($now (car-atom $expr))
                ($rest (cdr-atom $expr))
                ($_stim (collapse (stimulate $now 10)))
                ($_stimlog (println! (stimulating atom --> $now)))
                ($_readlog (println! (read-step $counter word $now remaining (size-atom $rest))))
                ($_batch
                    (if (or (== (% $counter (batch)) 0) (== $rest ()))
                        (let*
                            (
                                ($_agents (runAttentionBatch))
                            )
                            True
                        )
                        (println! (continued to stimulate batched atoms ...))
                    )
                )
                ; (py-call (time.sleep 5.0))
                ($_next (insectPoisonReadExp $rest (+ $counter 1)))
            )
            True
        )
    )
)

; !(match &incident (much $x) (tropical $x))
!(insectPoisonReadExp (match &insect (insectSent $x) $x) 0)
