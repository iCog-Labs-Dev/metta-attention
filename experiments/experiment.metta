!(bind! &insect (new-space))
!(import! &insect data/insect-sent)

!(import! &self (library lib_import))
!(import! &self (library lib_spaces))
!(import! &self (library lib_he))
!(import_prolog_function working_dir)
!(import_prolog_function directory_file_path)
!(import_prolog_function absolute_file_name)

(= (registerLocalMettaAttentionLibrary)
    (let*
        (
            ($testDir (working_dir))
            ($rootPath (directory_file_path $testDir ".."))
            ($repoRoot (absolute_file_name $rootPath))
        )
        (assertaPredicate (Predicate (library_path $repoRoot)))
    )
)

!(registerLocalMettaAttentionLibrary)
!(import! &self (library lib_he))

!(static-import! &incident ./data/kgadexp)

!(import! &self (library metta-attention attention/AttentionParam))
!(import! &self (library metta-attention attention/baching))
!(import! &self (library metta-attention attention-bank/utilities/helper-functions))
!(import! &self (library metta-attention attention-bank/utilities/recentVal))
!(import! &self (library metta-attention attention-bank/attention-value/getter-and-setter))
!(import! &self (library metta-attention attention-bank/bank/attention-bank))
!(import! &self (library metta-attention experiments/utils/logger.py))
!(import! &self (library metta-attention experiments/logger))
!(import! &self (library metta-attention attention-bank/bank/attentional-focus/attentional-focus))
!(import! &self (library metta-attention attention-bank/bank/importance-index/importance-index))
!(import! &self (library metta-attention attention/Neighbors))
!(import! &self (library metta-attention attention-bank/bank/stochastic-importance-diffusion/stochastic-importance-diffusion))
!(import! &self (library metta-attention attention/RentCollectionAgent/RentCollectionBaseAgent/RentCollectionBaseAgent))
!(import! &self (library metta-attention attention/RentCollectionAgent/WARentCollectionAgent/WARentCollectionAgent))
!(import! &self (library metta-attention attention/RentCollectionAgent/AFRentCollectionAgent/AFRentCollectionAgent))
!(import! &self (library metta-attention attention/RentCollectionAgent/AFRentCollectionAgent/AFRentCollectionAgent2))
!(import! &self (library metta-attention attention/ImportanceDiffusionAgent/ImportanceDiffusionBase/ImportanceDiffusionBase))
!(import! &self (library metta-attention attention/ImportanceDiffusionAgent/WAImportanceDiffusionAgent/WAImportanceDiffusionAgent))
!(import! &self (library metta-attention attention/ImportanceDiffusionAgent/getelement.py))
!(import! &self (library metta-attention attention/ImportanceDiffusionAgent/AFImportanceDiffusionAgent/AFImportanceDiffusionAgent))
!(import! &self (library metta-attention attention/HebbianUpdatingAgent/HebbianUpdatingAgent))
!(import! &self (library metta-attention attention/HebbianCreationAgent/HebbianCreationAgent))
!(import! &self (library metta-attention attention/runner-Def))
!(import! &self (library metta-attention attention/ImportanceDiffusionAgent/fluidDiffusion/fluid_integration))
!(import! &self (library metta-attention attention-bank/synapse/utils))
!(import! &self (library metta-attention attention-bank/synapse/synapse))
!(import! &self (library metta-attention attention-bank/synapse/topology_metrics.py))


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


(= (runAttentionBatch)
    (let*
        (
            ($_agents (collapse (agent-runner &incident)))
        )
        True
    )
)

(= (runAttentionBatch $now)
    (
        (collapse (agent-runner &incident))
        (collapse (applyFluidSimulation "../metta-attention/experiments/data/adagram_sparse_random.metta" $now))
    )
)

(= (getSeed)
    (let*
        (
            ($seed1t (getRandomAtomNotInAF)) 
            ($seed1 (if (== $seed1t ())
                        (getRandomAtomInAF)
                        $seed1t
                    )
            )
        )
        $seed1 
    )
)

(= (getSeeds)
    ((getRandomAtomInAF) (getRandomAtomInAF) (getRandomAtomInAF) (getRandomAtomInAF))
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
                                ($_agents (runAttentionBatch $seeds))
                            )
                            True
                        )
                        (println! (continued to stimulate batched atoms ...))
                    )
                )
                ($_cip (logcurrCip))
                ($_next (insectPoisonReadExp $rest (+ $counter 1)))
            )
            True
        )
    )
)

!(insectPoisonReadExp (car-atom (collapse (match &insect (insectSent $x) $x))) 0)
