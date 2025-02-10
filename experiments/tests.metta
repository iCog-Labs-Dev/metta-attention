!(register-module! ../../metta-attention)
!(import! &kb metta-attention:experiments:kb)
!(import! &self metta-attention:experiments:depTypes)

;test the Link and Node dependent types
!(assertEqual (get-type-space &kb link_ab) (Link Hebbian node_a node_b (1.0 1.0 1.0) (0.4 0.5)))
!(assertEqual (get-type-space &kb node_a) (Node Concept a (1.0 2.0 3.0) (0.5 0.8)))

;test AV and STV getters for links
!(assertEqual (getAV (get-type-space &kb link_ab)) (1.0 1.0 1.0))
!(assertEqual (getSTV (get-type-space &kb link_ab)) (0.4 0.5))
;
;;test AV and STV getters for nodes
!(assertEqual (getAV (get-type-space &kb node_a)) (1.0 2.0 3.0))
!(assertEqual (getSTV (get-type-space &kb node_a)) (0.5 0.8))
;;
;;;test AV and STV setters for nodes
!(setAV &kb node_a (0 0 0))
!(setSTV &kb  node_a (0.0 0.0))
;
!(setSTV &kb link_ab (0.0 0.0))
!(setAV  &kb link_ab (0.0 0.0 0.0))

;!(getAV (get-type-space &depTypes link_ab))
!(assertEqual (getAV (get-type-space &kb link_ab)) (0.0 0.0 0.0))
!(assertEqual (getSTV (get-type-space &kb link_ab)) (0.0 0.0))

!(assertEqual (getAV (get-type-space &kb node_a)) (0 0 0))
!(assertEqual (getSTV (get-type-space &kb node_a)) (0.0 0.0))
