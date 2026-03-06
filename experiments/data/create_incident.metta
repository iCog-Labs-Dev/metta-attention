!(import! &self lib/lib_import)
!(import! &self lib/lib_spaces)

!(static-import! &wordnet ./wordnet_stv_clean)
!(static-import! &outputS ./incident_out)

!(let $now 
    (match &outputS (theoutput $now) $now)
    ($now 
        (collapse 
            (superpose
                (
                    (match &wordnet (($link $now $target) $val) (($link $now $targt) $val))
                    (match &wordnet (($link $now $target) $val) (($link $now $targt) $val))
                )
            ) 
        )
    )
)
