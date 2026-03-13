!(import! &self lib/lib_import)
!(import! &self lib/lib_spaces)

!(static-import! &wordnet ./wordnet_stv_clean)

!(let $val 
    (unique-atom 
        (collapse 
            (match &wordnet (($link $source $target) $val) (superpose ( $source  $target )))
        )
    ) 
    (theoutput (superpose $val))
)

; sh run.sh ../metta-attention/experiments/data/incident.metta -s > ../metta-attention/incidnet.metta
; sed -i '/^true$/d' ../metta-attention/incidnet.metta


