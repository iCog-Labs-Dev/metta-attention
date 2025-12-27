!(bind! &wordnet (new-space))
!(bind! &conceptnet (new-space))

!(import! &self lib/lib_import)
!(static-import! &wordnet wordnet_stv_clean)
; !(static-import! &conceptnet conceptnet_stv_clean)



!(match &wordnet (insynset able $y $z) $y)
; !(match &conceptnet (dbpedia_product xebec_n_wp_studio $y ('0.6' '0.6')) $y)


