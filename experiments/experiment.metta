!(import! &self lib/lib_import)
!(git-import! "https://github.com/patham9/mettaclaw.git")
!(import! &self inject.py)
!(import! &self (library mettaclaw lib_mettaclaw))
!(bind! &insect (new-space))
!(import! &insect data/insect-sent)
!(import! &self lib/lib_spaces)
!(import! &self lib/lib_he)
!(static-import! &incident ./data/kgadexp)
; !(static-import! &conceptnet data/conceptnet_stv_clean)

!(import! &self ../attention/AttentionParam)
!(import! &self ../attention/baching)

!(import! &self ../attention-bank/utilities/helper-functions)
!(import! &self ../attention-bank/utilities/recentVal)
!(import! &self "../attention/ImportanceDiffusionAgent/getelement.py")

!(import! &self ../attention-bank/attention-value/getter-and-setter)
!(import! &self ../attention-bank/bank/attention-bank)
!(import! &self "utils/logger.py")
!(import! &self "utils/goal_candidates.py")
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
!(import! &self "../attention/ImportanceDiffusionAgent/getelement.py")
!(import! &self ../attention/ImportanceDiffusionAgent/fluidDiffusion/fluid_integration)
!(import! &self ../attention-bank/synapse/utils)
!(import! &self ../attention-bank/synapse/synapse)
!(import! &self "../attention-bank/synapse/topology_metrics.py")

; Import before insectPoisonReadExp is defined so (detach_mettaclaw) compiles as a call.
!(import_prolog_functions_from_file "../metta-attention/experiments/utils/detach_claw.pl" (detach_mettaclaw))

; !(match &wordnet ($atom ($mean $conf)) (setStv $atom ($mean $conf)))
; !(match &conceptnet ($atom ($mean $conf)) (setStv $atom ($mean $conf)))
; !(match &tempspace ($atom ($mean $conf)) (setStv $atom ($mean $conf)))


; write the params to a file
!(updateAttentionParam MAX_AF_SIZE 50.0)
!(updateAttentionParam TARGET_STI 70000.0)
!(updateAttentionParam TARGET_LTI 70000.0) 
!(updateAttentionParam STI_FUNDS_BUFFER 70000.0) 
!(updateAttentionParam LTI_FUNDS_BUFFER 70000.0) 
!(updateAttentionParam FUNDS_STI 100000.0) 
!(updateAttentionParam FUNDS_LTI 100000.0) 
(updateAttentionParam MAX_SPREAD_PERCENTAGE 0.4)
(updateAttentionParam HEBBIAN_MAX_ALLOCATION_PERCENTAGE 0.5)
; !(updateAttentionParam TOPK 0.8)
!(updateAttentionParam AFRentFrequency 50.0)

; write the params to a file
; usage(baseline parameters are optional): !(start-log (attentionParam) "current_experiment" "efficiency_baseline" "redundancy_baseline")
!(start-log (attentionParam) "current_experiment" "fluid_integration" "redundancy_baseline_1")

!(initialize-baseline-cip)
!(bind! &goalspace (new-space))

(= (logcurrCip)
        (let* (
                ($cip (transition-to-next-cip))
                ((CIPSnapshot $index $time $afAtoms $metrice) $cip)
                (($_gainedEfficiencyMetric $afResource $stiConcentration $fundSti $linkDensity $connectionRatio
                    $preallocation $cognitiveSynergy $modulation $coordination $contextRetention $cognitiveMaintenance
                    $effectiveness $triangleCount $betti0 $betti1 $betti2) $metrice)
                ($gainedEfficiency (getGainedEfficiency $index))
                ($redundancyDegradation (getRedundancyDegradation $index))
        )
        (write_metrics_wrapper
            $index
            $time
            $afAtoms
            $afResource
            $stiConcentration
            $fundSti
            $linkDensity
            $connectionRatio
            $preallocation
            $cognitiveSynergy
            $modulation
            $coordination
            $contextRetention
            $cognitiveMaintenance
            $effectiveness
            $gainedEfficiency
            $redundancyDegradation
            $triangleCount
            $betti0
            $betti1
            $betti2
        )
    )
)

; Bare (agents fluid) would apply agents as a function to fluid — use let*.
(= (runEcanBatch $seeds)
    (let*
        (
            ($_agents (collapse (test-superpose &incident)))
            ($_fluid (applyFluidSimulation "../metta-attention/experiments/data/adagram_sparse_random.metta" $seeds))
        )
        True
    )
)

; AF atoms paired with their STI — for the MettaClaw prompt (atomspace, not Python).
(= (getAfPairs)
    (collapse (match &af ($atom $sti) ($atom $sti)))
)

; Graph frontier only (EXPAND / BREAK). SHARPEN / SETTLE use &af via getAfPairs in the prompt.
(= (getGoalCandidates)
    (py-call (goal_candidates.goal_candidates (getAfAtoms)))
)

; Batch-window retention so R2 sees churn across the MettaClaw interval.
(= (getContextRetentionBatch)
    (let $prevIndex (- (get-lattest-cip-index) (batch))
        (if (< $prevIndex 0)
            1.0
            (getContextRetention (get-cip-af $prevIndex) (getAfAtoms))))
)

; Separate clauses: do not let $goals alias getSeeds' return value (empty goals then can't return seeds).
(= (randomFallbackSeeds)
    (let*
        (
            ($a (getRandomAtomInAF))
            ($b (getRandomAtomInAF))
            ($c (getRandomAtomInAF))
            ($d (getRandomAtomInAF))
        )
        (cons-atom $a (cons-atom $b (cons-atom $c (cons-atom $d ()))))
    )
)

(= (goalsOrFallback ())
    (randomFallbackSeeds)
)
(= (goalsOrFallback $goals)
    $goals
)

(= (getSeeds)
    (with_mutex goalspace_mutex
        (goalsOrFallback (collapse (match &goalspace (Goal $concept) $concept))))
)

(= (batch) 5)
(= (insectPoisonReadExp $expr $counter)
    (if (== $expr ())
        (let $_done (println! (finished-read count $counter)) True)
        (let*
            (
                ($now (car-atom $expr))
                ($rest (cdr-atom $expr))
                ($_stim (collapse (stimulate $now 20)))
                ($_stimlog (println! (stimulating atom --> $now)))
                ($_readlog (println! (read-step $counter word $now remaining (size-atom $rest))))
                ($_batch
                    (if (or (== (% $counter (batch)) 0) (== $rest ()))
                        (let*
                            (
                                ($seeds (getSeeds))
                                ($_agents (runEcanBatch $seeds))
                                ($moduleLinksWithValues (getAllHebLinksWithValues))
                                ($modules (identifyHebbianModules $moduleLinksWithValues))
                                ($moduleCount (size-atom $modules))
                                ($mo (println! (module-count $moduleCount modules $modules)))
                                ; After first batch: avoid racing claw Python init with first fluid call.
                                ($_claw
                                    (if (== $counter 0)
                                        (detach_mettaclaw)
                                        True))
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

; once: top-level !() is collapse/findall; without once, nondet solutions flood and halt kills claw.
!(once (progn
    (insectPoisonReadExp (car-atom (collapse (match &insect (insectSent $x) $x))) 0)
    True))
