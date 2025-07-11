!(import! &self utils)
(= (write_csv_wrapper $space)
    (let $snapshot
        (collapse (AFsnapshot $space))
        (write_to_csv $snapshot)
    )
)

(= (AFsnapshot $space)
    (let* 
        (
            ($atom (get-atoms $space))
            ($av (getAv $atom))
        ) 
        ($atom $av) 
    )
)

(= (start_log $attentionParam $file)
    (let $param
        (start_logger $file)
        (let $atoms
            (let $val (collapse (get-atoms $attentionParam)) (save_params $val))
        )
    )
)


