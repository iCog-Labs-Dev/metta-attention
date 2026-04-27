
(= (write_csv_wrapper $afAtoms)
        (py-call (logger.write_to_csv $afAtoms))
)

(= (write_metrics_wrapper $counter $afResource $stiConcentration $linkDensity $connectionRatio $normalizedStiEntropy $retention $pCorrelation $modulation $globalCoordination)
    (py-call (logger.write_metrics_row $counter $afResource $stiConcentration $linkDensity $connectionRatio $normalizedStiEntropy $retention $pCorrelation $modulation $globalCoordination))
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



