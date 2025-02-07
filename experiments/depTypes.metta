(: AV (-> Number Number Number Type))
(: STV (-> Number Number Type))

(: Link (-> $type $source $target ($sti $lti $vlti) ($tv $conf) ((AV $sti $lti $vlti) (STV $tv $conf))))
(: Node (-> $type $symbol ($sti $lti $vlti) ($tv $conf) ((AV $sti $lti $vlti) (STV $tv $conf))))


;getters for Link types
(= (getAV (Link $type $source $target $av $stv)) $av)
(= (getSTV (Link $type $source $target $av $stv)) $stv)

;getters for Node types
(= (getSTV (Node $type $symbol $av $stv)) $stv)
(= (getAV (Node $type $symbol $av $stv)) $av)

;NOTE: Currently, the functions setAV and setSTV are being written independently only
;to check if they each work properly. A general function that brings them together will be 
;used once the separate cases are proven to work.

;av and stv setters for Node types
(= (setAV $pattern $newAV)
   (let $var (get-type $pattern) (
                              unify (quote $var)
                                    (quote ($node $type $symbol $av $stv))
                                    (let () (remove-atom &self (: $pattern ($node $type $symbol $av $stv)))
                                      (add-atom &self (: $pattern ($node $type $symbol $newAV $stv))
                                      )
                                    )
                                    failure
                            )

    )
)

(= (setSTV $pattern $newSTV)
   (let $var (get-type $pattern) (
                              unify (quote $var)
                                    (quote ($node $type $symbol $av $stv))
                                    (let () (remove-atom &self (: $pattern ($node $type $symbol $av $stv)))
                                      (add-atom &self (: $pattern ($node $type $symbol $av $newSTV))
                                      )
                                    )
                                    failure
                            )

    )
)



; TESTS
(: node_a (Node Concept a (1.0 2.0 3.0) (0.5 0.8)))
(: node_b (Node Concept b (1.0 2.0 3.0) (0.5 0.8)))

;define a link from node_a to node_b
(: link_ab (Link Hebbian node_a node_b (1.0 1.0 1.0) (0.4 0.5)))

;test the Link and Node dependent types
!(assertEqual (get-type link_ab) (Link Hebbian node_a node_b (1.0 1.0 1.0) (0.4 0.5)))
!(assertEqual (get-type node_a) (Node Concept a (1.0 2.0 3.0) (0.5 0.8)))

;test AV and STV getters for links
!(assertEqual (getAV (get-type link_ab)) (1.0 1.0 1.0))
!(assertEqual (getSTV (get-type link_ab)) (0.4 0.5))

;test AV and STV getters for nodes
!(assertEqual (getAV (get-type node_a)) (1.0 2.0 3.0))
!(assertEqual (getSTV (get-type node_a)) (0.5 0.8))

;test AV and STV setters for nodes
!(setAV node_a (0 0 0))
!(setSTV node_a (0.0 0.0))

!(assertEqual (getAV (get-type node_a)) (0 0 0))
!(assertEqual (getSTV (get-type node_a)) (0.0 0.0))
