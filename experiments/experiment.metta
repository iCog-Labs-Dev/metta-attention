!(bind! &insect (new-space))
; !(bind! &poison (new-space))
!(import! &insect data/insect-sent)
!(import! &self lib/lib_import)
!(import! &self lib/lib_spaces)
!(import! &self lib/lib_he)
!(static-import! &incident ./data/kg)
; !(static-import! &conceptnet data/conceptnet_stv_clean)

!(import! &self ../attention/AttentionParam)
!(import! &self ../attention/baching)

!(import! &self ../attention-bank/utilities/helper-functions)
!(import! &self ../attention-bank/utilities/recentVal)
!(import! &self "../attention/ImportanceDiffusionAgent/getelement.py")

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
!(import! &self ../attention/RentCollectionAgent/AFRentCollectionAgent/AFRentCollectionAgent2)
!(import! &self ../attention/ImportanceDiffusionAgent/ImportanceDiffusionBase/ImportanceDiffusionBase)
!(import! &self ../attention/ImportanceDiffusionAgent/WAImportanceDiffusionAgent/WAImportanceDiffusionAgent)
!(import! &self ../attention/ImportanceDiffusionAgent/AFImportanceDiffusionAgent/AFImportanceDiffusionAgent)
!(import! &self ../attention/HebbianUpdatingAgent/HebbianUpdatingAgent)
!(import! &self ../attention/HebbianCreationAgent/HebbianCreationAgent)
!(import! &self ../attention/runner-Def)
!(import! &self ../attention-bank/synapse/utils)
!(import! &self ../attention-bank/synapse/ratio)


(match &wordnet ($atom ($mean $conf)) (setStv $atom ($mean $conf)))
(match &conceptnet ($atom ($mean $conf)) (setStv $atom ($mean $conf)))
; !(match &tempspace ($atom ($mean $conf)) (setStv $atom ($mean $conf)))


; write the params to a file
!(updateAttentionParam MAX_AF_SIZE 70.0)
!(updateAttentionParam TARGET_STI 90000.0)
!(updateAttentionParam TARGET_LTI 90000.0) 
!(updateAttentionParam STI_FUNDS_BUFFER 90000.0) 
!(updateAttentionParam LTI_FUNDS_BUFFER 90000.0) 
!(updateAttentionParam FUNDS_STI 100000.0) 
!(updateAttentionParam FUNDS_LTI 100000.0) 
!(updateAttentionParam MAX_SPREAD_PERCENTAGE 0.8)
!(updateAttentionParam HEBBIAN_MAX_ALLOCATION_PERCENTAGE 0.5)
; !(updateAttentionParam TOPK 0.8)
!(updateAttentionParam AFRentFrequency 2.0)

; write the params to a file
!(start-log (attentionParam) "experiments")


!(initialize-baseline-cip)

(= (logcurrCip) 
        (let* (
                ($cip (transition-to-next-cip))
                ((CIPSnapshot $index $time $af_atoms $metrice) $cip)
        )
        (write_cip_wrapper $index $time $af_atoms $metrice)
    )
)

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
                ($_stim (collapse (stimulate $now 30)))
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
                ($_cip (logcurrCip))
                ($_next (insectPoisonReadExp $rest (+ $counter 1)))
            )
            True
        )
    )
)

; !(insectPoisonReadExp (match &insect (insectSent $x) $x) 0)
!(insectPoisonReadExp (car-atom (collapse (match &insect (insectSent $x) $x))) 0)


; stimulat is taking long time, idk why??
; its performance accross funds and number of atoms should be studied??