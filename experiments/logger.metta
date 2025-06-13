!(import! &self utils)
(= (write_csv_wrapper $space $file)
    (let*
        (
            ($atom (get-atoms $space))
            ($av (getAv $atom))
            ($size (getAttentionParam MAX_AF_SIZE)) 
        )
        (write_to_csv (($atom $av)) ($size) $file)
    )
)
