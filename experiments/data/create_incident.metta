!(import! &self lib/lib_import)
!(import! &self lib/lib_spaces)

!(static-import! &wordnet ./wordnet_stv_clean)
!(static-import! &outputS ./incident_out)

!(let $now 
    (match &outputS (theoutput $atom) $atom)
    ($now 
        (collapse 
            (superpose
                (
                    (match &wordnet (($link $now $target) $val) (($link $now $target) $val))
                    (match &wordnet (($link $source $now) $val) (($link $source $now) $val))
                )
            ) 
        )
    )
)
