(: node_a (createAV a (0.0 0.0 0.0)))
(: node_d (createAV d (7.0 4.0 0.0)))
(: node_c (createAV c (0.0 0.0 0.0)))
(: node_A (createAV A (100.0 200.0 300.0)))
(: node_B (createAV B (50.0 150.0 250.0)))
(: node_C (createAV C (200.0 300.0 400.0)))
(: node_D (createAV D (25.0 125.0 225.0)))
(: node_F (createAV F (70.0 100.0 200.0)))
(: node_G (createAV G (300.0 400.0 500.0)))
(: node_H (createAV H (15.0 25.0 35.0)))
(: node_I (createAV I (500.0 600.0 700.0)))

(: createLink (-> $source $target $type ($source $target)))
(: link_ak (createLink abebe kebede HebbianLink))
(: link_ca (createLink challa abebe PlusLink))

(= (getLinksByType $type $space)
   (
    match $space
    (: $x (createLink $source $target $type))
    (collapse ($type $source $target))
  )
)
