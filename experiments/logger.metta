
(= (write_csv_wrapper $afAtoms)
    (let $snapshot
        (collapse (AFsnapshot $afAtoms))
        (py-call (logger.write_to_csv $snapshot))
    )
)

(= (AFsnapshot $afAtoms)
    (if (== $afAtoms ())
        ()
        (let* 
            (
                ($atom (superpose $afAtoms))
                ($av (eval (getAv $atom)))
            ) 
            ($atom $av) 
        )
    )
)

; Start logging: call logger.start_logger to set up output files, then save params
(= (start-log $attentionParam $file)
    (let* (
        ($param (py-call (logger.start_logger $file))) 
        ($val (collapse (get-atoms $attentionParam))))
        (py-call (logger.save_params $val))
    )
)



