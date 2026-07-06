
(= (write_csv_wrapper $afAtoms)
        (py-call (logger.write_to_csv $afAtoms))
)

(= (write_metrics_wrapper 
    $counter $time $af_atoms $afResource $stiConcentration $fundSti $linkDensity $connectionRatio
    $preallocation $cognitiveSynergy $modulation $coordination $contextRetention $cognitiveMaintenance $effectiveness
    $gainedEfficiency $redundancyDegradation $triangleCount $betti0 $betti1 $betti2)
    (py-call (logger.write_metrics_row 
                $counter 
                $time 
                $af_atoms 
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
                $betti2)
    )
)





(= (write_cip_wrapper $index $time $af_atoms $metrice)
    (py-call (logger.write_cip_row $index $time $af_atoms $metrice))
)

(= (get_baseline_effectiveness $index)
    (py-call (logger.get_baseline_effectiveness $index))
)

(= (get_baseline_redundancy_data $index)
    (py-call (logger.get_baseline_redundancy_data $index))
)


(= (AFsnapshot $afAtoms)
    (if (== $afAtoms ())
        ()
        (let* 
            (
                ($atom (superpose $afAtoms))
                ($av (getAv $atom))
            ) 
            ($atom $av) 
        )
    )
)

; Start logging: call logger.start_logger to set up output files, then save params
(= (start-log $attentionParam $file)
    (let* 
        (
            ($param (py-call (logger.start_logger $file))) 
            ($val (collapse (get-atoms $attentionParam)))
        )
        (py-call (logger.save_params $val))
    )
)

