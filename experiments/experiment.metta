!(bind! &insect (new-space))
; !(bind! &poison (new-space))
!(import! &insect data/insect-sent)
!(import! &self lib/lib_import)
!(import! &self lib/lib_spaces)
!(import! &self lib/lib_he)
;!(static-import! &incident ./data/kg)
!(import! &incident ./data/kg-mini)
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
!(updateAttentionParam MAX_AF_SIZE 10.0)
!(updateAttentionParam TARGET_STI 90000.0)
!(updateAttentionParam TARGET_LTI 90000.0) 
!(updateAttentionParam STI_FUNDS_BUFFER 90000.0) 
!(updateAttentionParam LTI_FUNDS_BUFFER 90000.0) 
!(updateAttentionParam FUNDS_STI 100000.0) 
!(updateAttentionParam FUNDS_LTI 100000.0) 
!(updateAttentionParam MAX_SPREAD_PERCENTAGE 0.25)
!(updateAttentionParam HEBBIAN_MAX_ALLOCATION_PERCENTAGE 0.75)
!(updateAttentionParam TOPK 0.4)
!(updateAttentionParam AFRentFrequency 0.5)

; write the params to a file
!(start-log (attentionParam) "experiments")


!(initialize-baseline-cip)

(= (logcurrCip)
        (let* (
                ($currIndex (get-lattest-cip-index))
                ($prevIndex (if (< (- $currIndex 1) 0) 0 (- $currIndex 1)))
                ($cipPrev (get-cip-snapshots $prevIndex))
                ($cip (transition-to-next-cip))
                ($eff (calculateEffectiveness $cipPrev $cip))
                ((CIPSnapshot $index $time $af_atoms $metrice) $cip)
        )
        (write_cip_wrapper $index $time $af_atoms $metrice $eff)
    )
)

;(= (logBatchEffectiveness)
;    (let* (
;            ($currIndex (get-lattest-cip-index))
;            ($prevIndex (- $currIndex 1))
;            ($safePrev (if (< $prevIndex 0) 0 $prevIndex))
;            ($currSnap (get-cip-snapshots $currIndex))
;            ($prevSnap (get-cip-snapshots $safePrev))
;            
;            ($batchEff (calculateEffectiveness $prevSnap $currSnap))
;        )
;        (println! (=== Batch Effectiveness: $batchEff ===))
;    )
;)

(= (batch) 30)
(= (insectPoisonReadExp $expr $counter)
    (if (== $expr ())
        (empty)
        (let* 
            (
                ($now (car-atom $expr))
                ($rest (cdr-atom $expr))
                ($af (getAfAtoms))
            )
            ( 
                (stimulate $now 30)
                (println! (stimulating atom --> $now))
                (if (or (== (% $counter (batch)) 0) (== $rest ()))
                    (
            
                        (collapse (test-superpose &incident))

                        (let $currentSnapShot (+ (get-lattest-cip-index) 1)
                            (map-atom (getAfAtoms) $atom 
                                (let $res (collapse (getSti $atom))
                                    (let $sti (if (== $res ()) 0.0 (car-atom $res))
                                        (updateAtomHistory $atom $sti $currentSnapShot)
                                    )
                                )
                            )
                        )
                    )

                    (logcurrCip) 
                    ;(logBatchEffectiveness)
                    
                    (
                        (println! (continued to stimulate batched atoms ...))
                    )
                )
                ; (py-call (time.sleep 5.0))
                ;; (logcurrCip) 
                (insectPoisonReadExp $rest (+ $counter 1)))
        )
    )
)

!(bind! &baselinePrevSnap (new-state ()))
!(let $snap (get-cip-snapshots (get-lattest-cip-index)) (change-state! &baselinePrevSnap $snap))

!(insectPoisonReadExp (match &insect (insectSent $x) $x) 0)

!(bind! &baselineCurrSnap (new-state ()))
!(let $snap (get-cip-snapshots (get-lattest-cip-index)) (change-state! &baselineCurrSnap $snap))


!(updateAttentionParam HEBBIAN_MAX_ALLOCATION_PERCENTAGE 0.8)
;!(updateAttentionParam MAX_AF_SIZE 30.0)

!(wipeEngineMemory)

!(import! &incident ./data/kg-mini)
!(import! &incident ./data/insect-sent.metta)

!(bind! &optPrevSnap (new-state ()))
!(let $snap (get-cip-snapshots (get-lattest-cip-index)) (change-state! &optPrevSnap $snap))

!(insectPoisonReadExp (match &insect (insectSent $x) $x) 0)

!(bind! &optCurrSnap (new-state ()))
!(let $snap (get-cip-snapshots (get-lattest-cip-index)) (change-state! &optCurrSnap $snap))

!(let $eff (calculateEffectiveness (get-state &baselinePrevSnap) (get-state &baselineCurrSnap))
    (println! (=== Baseline Effectiveness: $eff ===))
)

!(let $eff (calculateEffectiveness (get-state &optPrevSnap) (get-state &optCurrSnap))
    (println! (=== Optimized Effectiveness: $eff ===))
)

!(let $efficiency (gainedEfficiency (get-state &baselinePrevSnap) (get-state &baselineCurrSnap) (get-state &optPrevSnap) (get-state &optCurrSnap))
    (println! (Gained Efficiency: $efficiency))
)

!(bind! &junkAtoms ((Concept "Junk1") (Concept "Junk2") (Concept "Junk3")))
!(let $report (redundancyDegradation (get-state &optPrevSnap) (get-state &optCurrSnap) ((Concept "Junk1") (Concept "Junk2") (Concept "Junk3")))
    (println! (Redundancy Degradation Report: $report))
)


