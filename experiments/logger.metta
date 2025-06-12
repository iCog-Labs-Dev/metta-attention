!(import! &self utils)
(= (write_csv_wrapper $space $file)
    (let*
        (
            ($atom (get-atoms $space))
            ($av (getAv $atom))
        )
        (write_to_csv (($atom $av)) $file)

    )
)