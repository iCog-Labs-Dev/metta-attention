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
            ; (() (println! (atom $atom)))
        ) 
        ($atom $av) 
    )
)

(= (start_log $attentionParam $space $file)
    (let $param
        (start_logger $file)
        (let $atoms
            (let $val (collapse (get-atoms $attentionParam)) (save_params $val))
            (let $vals (collapse (get-atoms $space)) (save_params $vals))
        )
    )
)


