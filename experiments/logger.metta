
(= (write_csv_wrapper $afAtoms)
        (py-call (logger.write_to_csv $afAtoms))
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
        (
            (updateAttentionParam LOGGER True)
            (py-call (logger.save_params $val))
        )
    )
)



