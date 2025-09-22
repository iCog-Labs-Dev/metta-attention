!(import! &self utils)
(= (write_csv_wrapper $afAtoms)
    (let $snapshot
        (collapse (AFsnapshot $afAtoms))
        (write_to_csv $snapshot)
    )
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

(= (start_log $attentionParam $file)
    (let $param
        (start_logger $file)
        (let $val (collapse (get-atoms $attentionParam)) (save_params $val))
    )
)


