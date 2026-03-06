!(import! &self lib/lib_import)
!(import! &self lib/lib_spaces)

!(static-import! &wordnet ./wordnet_stv_clean)

(= (incidet $space)
    (let* 
        (
            ($uSource  
                (unique-atom 
                    (collapse 
                        (match $space (($link $source $target) $val) (superpose ( $source  $target )))
                    )
                )
            )
            ($now (superpose $uSource))
        )
        ($now
            (collapse 
                (superpose 
                    (
                        (match $space (($link $now $target) $val) ($link $now $target))
                        (match $space (($link $target $now) $val) ($link $target $now))
                    )
                )
            )
        )
    )
)

!(incidet &wordnet)

; sh run.sh ../metta-attention/experiments/data/incident.metta -s > ../metta-attention/incidnet.metta
; sed -i '/^true$/d' ../metta-attention/incidnet.metta


