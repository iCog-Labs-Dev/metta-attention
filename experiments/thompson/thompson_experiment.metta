;; ══════════════════════════════════════════════════════════════════════════════
;; IMPORTS
;; ══════════════════════════════════════════════════════════════════════════════
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

!(import! &self "thompson_utils.py")
!(import! &self thompson_utils)
!(import! &self ../motivated_experiment/closeness)
!(import! &self ../motivated_experiment/strategies)
!(import! &self thompson_stimulus)
!(import! &self thompson)

;; ══════════════════════════════════════════════════════════════════════════════
;; CONFIGURATION
;; ══════════════════════════════════════════════════════════════════════════════
!(updateAttentionParam MAX_AF_SIZE 50.0)
!(updateAttentionParam TARGET_STI 10000.0)
!(updateAttentionParam TARGET_LTI 10000.0) 
!(updateAttentionParam STI_FUNDS_BUFFER 10000.0) 
!(updateAttentionParam LTI_FUNDS_BUFFER 10000.0) 
!(updateAttentionParam FUNDS_STI 100000.0) 
!(updateAttentionParam FUNDS_LTI 100000.0) 
!(updateAttentionParam MAX_SPREAD_PERCENTAGE 0.4)
(updateAttentionParam HEBBIAN_MAX_ALLOCATION_PERCENTAGE 0.5)
!(updateAttentionParam AFRentFrequency 20.0)

;; ══════════════════════════════════════════════════════════════════════════════
;; NOVELTY TRACKING
;; ══════════════════════════════════════════════════════════════════════════════
!(bind! &noveltyTrack (new-space))

!(add-atom &tsState (ts-posterior narrow-focus 1.0 1.0))
!(add-atom &tsState (ts-posterior expand-focus 1.0 1.0))
!(add-atom &tsState (ts-posterior explore-novel 1.0 1.0))

!(add-atom &tsState (tsBaseline 0.5))

!(start-log (attentionParam) "thompson_contextual" "mtmo_explore_novel" "redundancy_baseline_1")
!(initialize-baseline-cip)

;; ══════════════════════════════════════════════════════════════════════════════
;; HELPERS
;; ══════════════════════════════════════════════════════════════════════════════
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

;; ══════════════════════════════════════════════════════════════════════════════
;; THOMPSON BATCH
;; ══════════════════════════════════════════════════════════════════════════════
(= (runThompsonBatch)
    (let*
        (
            ($prevStim (ecanStimulus))
            ($baseline (car-atom (collapse (match &tsState (tsBaseline $b) $b))))
            ($samples (tsScores (thompsonStrategies)))
            ($strategy (pickBestSample $samples))
            ($seeds (applyStrategy $strategy))
            ($_log (println! (thompson chose $strategy)))
            ($_samples (println! (samples $samples)))
            ($_stimlog (println! (stim $prevStim)))
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
            ($nextStim (ecanStimulus))
            ($_post (println! (stim after $nextStim)))
            ($raw (rawReward $prevStim $nextStim))
            ($reward (differentialReward $raw $baseline))
            ($newBaseline (updateBaseline $baseline $raw))
            ($_reward (println! (reward raw $raw reward $reward baseline $newBaseline)))
            ($_pu (tsUpdate $strategy $reward))
            ($_bu
                (let $oldB (collapse (match &tsState (tsBaseline $x) $x))
                    (let $removedB (remove-atom &tsState (tsBaseline $x))
                        (add-atom &tsState (tsBaseline $newBaseline))
                    )
                )
            )
            ($_nt (updateNoveltyTrack))
        )
        True
    )
)

;; ══════════════════════════════════════════════════════════════════════════════
;; MAIN
;; ══════════════════════════════════════════════════════════════════════════════
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
                    (runThompsonBatch)
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
