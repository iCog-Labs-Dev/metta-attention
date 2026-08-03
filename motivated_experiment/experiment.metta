!(bind! &insect (new-space))
!(import! &insect ../experiments/data/insect-sent)

!(import! &self ../../PeTTa/lib/lib_import)
!(import! &self ../../PeTTa/lib/lib_spaces)
!(import! &self ../../PeTTa/lib/lib_he)

!(static-import! &incident ../experiments/data/kgadexp)

!(import! &self ../attention/AttentionParam)
!(import! &self ../attention/baching)
!(import! &self ../attention-bank/utilities/helper-functions)
!(import! &self ../attention-bank/utilities/recentVal)
!(import! &self "../attention/ImportanceDiffusionAgent/getelement.py")
!(import! &self ../attention-bank/attention-value/getter-and-setter)
!(import! &self ../attention-bank/bank/attention-bank)
!(import! &self "../experiments/utils/logger.py")
!(import! &self ../experiments/logger)
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
!(import! &self "../attention/ImportanceDiffusionAgent/fluidDiffusion/fluid_integration")
!(import! &self ../attention-bank/synapse/utils)
!(import! &self ../attention-bank/synapse/synapse)
!(import! &self "../attention-bank/synapse/topology_metrics.py")

!(import! &self ../../MetaMo/core/helpers.py)
!(import! &self ../../MetaMo/core/helper)
!(import! &self ../../MetaMo/core/state)
!(import! &self ../../MetaMo/core/state_accessors)
!(import! &self ../../MetaMo/core/config)
!(import! &self ../../MetaMo/openpsi/config)
!(import! &self ../../MetaMo/category/functors)
!(import! &self ../../MetaMo/category/bimonad)
!(import! &self ../../MetaMo/openpsi/appraisal)
!(import! &self ../../MetaMo/openpsi/appraisal_helpers)
!(import! &self ../../MetaMo/openpsi/feeling)
!(import! &self ../../MetaMo/magus/decision)
!(import! &self ../../MetaMo/dynamics/stability)
!(import! &self ../../MetaMo/dynamics/coherence)
!(import! &self ../../MetaMo/dynamics/default)
!(import! &self ../../MetaMo/main/main)
!(import! &self config)
!(import! &self stimulus)
!(import! &self strategies)


!(updateAttentionParam MAX_AF_SIZE 50.0)
!(updateAttentionParam TARGET_STI 10000.0)
!(updateAttentionParam TARGET_LTI 10000.0) 
!(updateAttentionParam STI_FUNDS_BUFFER 10000.0) 
!(updateAttentionParam LTI_FUNDS_BUFFER 10000.0) 
!(updateAttentionParam FUNDS_STI 100000.0) 
!(updateAttentionParam FUNDS_LTI 100000.0) 
!(updateAttentionParam MAX_SPREAD_PERCENTAGE 0.8)
(updateAttentionParam HEBBIAN_MAX_ALLOCATION_PERCENTAGE 0.5)
; !(updateAttentionParam TOPK 0.8)
!(updateAttentionParam AFRentFrequency 5.0)

!(bind! &metamoState (new-space))
!(let $initial 
    (
        (subsystemState 
            cautious 
            (motivation (0.6 0.4 0.6 0.2 0.2 0.3 0.7 0.5) (0.4 0.3 0.3 0.6 0.7 0.6))
        ) 
        (subsystemState 
            curious 
            (motivation (0.2 0.9 0.3 0.8 0.7 0.6 0.2 0.5) (0.6 0.7 0.7 0.3 0.3 0.3))
        )
    ) 
    (add-atom &metamoState (metaMoStates $initial))
)

(= (setMetaMoStates $states) 
    (let $old 
        (match &metamoState (metaMoStates $x) $x)
        (let $removed 
            (remove-atom &metamoState (metaMoStates $x))
            (add-atom &metamoState (metaMoStates $states))
        )
    )
)

!(bind! &noveltyTrack (new-space))

!(start-log (attentionParam) "metamo_guided" "metamo_guided" "redundancy_baseline_1")
!(initialize-baseline-cip)

(= (batch) 5)

(= (updateNoveltyTrack)
    (let* 
        (
            ($curr (getAfAtoms))
            ($prev (collapse (match &noveltyTrack (af-snapshot $atoms) $atoms)))
            ($1 (println! (fnd $prev)))
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
            $index $time $afAtoms $afResource $stiConcentration $fundSti $linkDensity $connectionRatio
            $preallocation $cognitiveSynergy $modulation $coordination $contextRetention $cognitiveMaintenance
            $effectiveness $gainedEfficiency $redundancyDegradation $triangleCount $betti0 $betti1 $betti2
        )
    )
)

(= (runMotivatedBatch)
    (let* 
        (
            ($1 (println! (prty adf)))
            ($states (match &metamoState (metaMoStates $s) $s))
            ($stim (ecanStimulus))
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
            ($_ag (collapse (test-superpose &incident)))
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
            ($_stim (collapse (stimulate $now 40)))
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
!(let $at (getAfAtoms) (map-atom $at $a ($a (getSti $a))))
