!(register-module! ../experiments)
!(import! &self experiments.utils2)

; Test the path functions
!((py-atom utils2.parse_path) $_ experiments)
!((py-atom utils2.create_file_path) $_ experiments)

; Mettalog-compatible logger functions
(= (write_csv_wrapper $space)
    (let $snapshot
        (collapse (AFsnapshot $space))
        ((py-atom utils2.write_to_csv) $_ $snapshot)
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
        ((py-atom utils2.start_logger) $_ $file)
        (let $val (collapse (get-atoms $attentionParam))
            ((py-atom utils2.save_params) $_ $val)
        )
    )
)

(= (save_params $params)
    ((py-atom utils2.save_params) $_ $params)
)