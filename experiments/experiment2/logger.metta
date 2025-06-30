!(import! &self logger2)
(= (write_csv_wrapper $space $file)
    (let $snapshot
        (collapse (AFsnapshot $space))
        (write_to_csv $snapshot $file)
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
