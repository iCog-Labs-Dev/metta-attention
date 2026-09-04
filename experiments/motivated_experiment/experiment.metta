!(bind! &insect (new-space))
!(import! &insect ../data/insect-sent)

!(import! &self (library lib_import))
!(import_prolog_function working_dir)
!(import_prolog_function directory_file_path)
!(import_prolog_function absolute_file_name)

(= (registerLocalMettaAttentionLibrary)
    (let*
        (
            ($testDir (working_dir))
            ($rootPath (directory_file_path $testDir "../.."))
            ($repoRoot (absolute_file_name $rootPath))
        )
        (assertaPredicate (Predicate (library_path $repoRoot)))
    )
)

!(registerLocalMettaAttentionLibrary)
!(import! &self (library lib_spaces))
!(import! &self (library lib_he))

!(static-import! &incident ../data/kgadexp)

!(import! &self (library metta-attention attention/AttentionParam))
!(import! &self (library metta-attention attention/baching))
!(import! &self (library metta-attention attention-bank/utilities/helper-functions))
!(import! &self (library metta-attention attention-bank/utilities/recentVal))
!(import! &self (library metta-attention attention/ImportanceDiffusionAgent/getelement.py))
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
!(import! &self (library metta-attention attention/ImportanceDiffusionAgent/ImportanceDiffusionBase/ImportanceDiffusionBase))
!(import! &self (library metta-attention attention/ImportanceDiffusionAgent/WAImportanceDiffusionAgent/WAImportanceDiffusionAgent))
!(import! &self (library metta-attention attention/ImportanceDiffusionAgent/AFImportanceDiffusionAgent/AFImportanceDiffusionAgent))
!(import! &self (library metta-attention attention/HebbianUpdatingAgent/HebbianUpdatingAgent))
!(import! &self (library metta-attention attention/HebbianCreationAgent/HebbianCreationAgent))
!(import! &self (library metta-attention attention/runner-Def))
!(import! &self (library metta-attention attention/ImportanceDiffusionAgent/fluidDiffusion/fluid_integration))
!(import! &self (library metta-attention attention-bank/synapse/utils))
!(import! &self (library metta-attention attention-bank/synapse/synapse))
!(import! &self (library metta-attention attention-bank/synapse/topology_metrics.py))

!(import! &self ../../../MetaMo/core/helpers.py)
!(import! &self ../../../MetaMo/core/helper)
!(import! &self ../../../MetaMo/core/state)
!(import! &self ../../../MetaMo/core/state_accessors)
!(import! &self ../../../MetaMo/core/config)
!(import! &self ../../../MetaMo/openpsi/config)
!(import! &self ../../../MetaMo/category/functors)
!(import! &self ../../../MetaMo/category/bimonad)
!(import! &self ../../../MetaMo/openpsi/appraisal)
!(import! &self ../../../MetaMo/openpsi/appraisal_helpers)
!(import! &self ../../../MetaMo/openpsi/feeling)
!(import! &self ../../../MetaMo/magus/decision)
!(import! &self ../../../MetaMo/dynamics/stability)
!(import! &self ../../../MetaMo/dynamics/coherence)
!(import! &self ../../../MetaMo/dynamics/default)
!(import! &self ../../../MetaMo/main/main)
!(import! &self config)
!(import! &self closeness)
!(import! &self stimulus)
!(import! &self strategies)


!(updateAttentionParam MAX_AF_SIZE 50.0)
!(updateAttentionParam TARGET_STI 10000.0)
!(updateAttentionParam TARGET_LTI 10000.0) 
!(updateAttentionParam STI_FUNDS_BUFFER 10000.0) 
!(updateAttentionParam LTI_FUNDS_BUFFER 10000.0) 
!(updateAttentionParam FUNDS_STI 100000.0) 
!(updateAttentionParam FUNDS_LTI 100000.0) 
!(updateAttentionParam MAX_SPREAD_PERCENTAGE 0.4)
(updateAttentionParam HEBBIAN_MAX_ALLOCATION_PERCENTAGE 0.5)
; !(updateAttentionParam TOPK 0.8)
!(updateAttentionParam AFRentFrequency 20.0)

!(bind! &metamoState (new-space))
!(let $initial 
    (
        (subsystemState 
            cautious 
            (motivation (0.7 0.3 0.7 0.1 0.1 0.2 0.8 0.6) (0.5 0.4 0.4 0.7 0.8 0.7))
        ) 
        (subsystemState 
            curious 
            (motivation (0.1 0.95 0.2 0.9 0.9 0.5 0.1 0.4) (0.7 0.8 0.8 0.2 0.2 0.2))
        )
    ) 
    (add-atom &metamoState (metaMoStates $initial))
)

(= (setMetaMoStates $states) 
    (let $old 
        (car-atom (collapse (match &metamoState (metaMoStates $x) $x)))
        (let $removed 
            (remove-atom &metamoState (metaMoStates $old))
            (add-atom &metamoState (metaMoStates $states))
        )
    )
)

!(bind! &noveltyTrack (new-space))

!(start-log (attentionParam) "mtmo_explore_novel" "metamo_guided" "redundancy_baseline_1")
!(initialize-baseline-cip)

(= (batch) 5)

(= (updateNoveltyTrack)
    (let* 
        (
            ($curr (getAfAtoms))
            ($prev (collapse (match &noveltyTrack (af-snapshot $atoms) $atoms)))
        ) 
        (if (== $prev ())
            (add-atom &noveltyTrack (af-snapshot $curr))
            (let $oldAtom (af-snapshot $prev)
                (let $removed (remove-atom &noveltyTrack $oldAtom)
                    (add-atom &noveltyTrack (af-snapshot $curr))
                )
            )
        )
    )
)


(= (runMotivatedBatch)
    (let* 
        (
            ($states (car-atom (collapse (match &metamoState (metaMoStates $s) $s))))
            ($stim (ecanStimulus))
            ($1 (println! (sti $stim)))
            ($result (runMetaMoCycleDefault
                (defaultMetaMoBimonad)
                $states
                $stim
                (strategyCandidates)
                () 
                ()
            ))
            ($strategy (actionId (cycleFinalAction $result)))
            ($seeds (applyStrategy $strategy))
            ($_log (println! (chose strategy $strategy)))
            ($_seedrec
                (let $old (collapse (match &noveltyTrack (lastSeeds $x) $x))
                    (if (== $old ())
                        (add-atom &noveltyTrack (lastSeeds $seeds))
                        (let $removed (remove-atom &noveltyTrack (lastSeeds $old))
                            (add-atom &noveltyTrack (lastSeeds $seeds))
                        )
                    )
                )
            )
            ($_ag (collapse (agent-runner &incident)))
            ($_fl (collapse (applyFluidSimulation "../metta-attention/experiments/data/adagram_sparse_random.metta" $seeds)))
            ($_state (setMetaMoStates (cycleNextStates $result)))
            ($_nt (updateNoveltyTrack))
        )
        True
    )
)

(= (motivatedReadExp $expr $counter)
    (if (== $expr ())
        (let $_done (println! (finished read count $counter)) True)
        (let* (
            ($now (car-atom $expr))
            ($rest (cdr-atom $expr))
            ($_stim (stimulate $now 30))
            ($_stimlog (println! (stimulating atom --> $now)))
            ($_batch
                (if (or (== (% $counter (batch)) 0) (== $rest ()))
                    (runMotivatedBatch)
                    (println! (continued to stimulate batched atoms ...))
                )
            )
            ($_cip (logcurrCip))
            ($_next (motivatedReadExp $rest (+ $counter 1)))
        )
            True
        )
    )
)

!(motivatedReadExp (car-atom (collapse (match &insect (insectSent $x) $x))) 0)
