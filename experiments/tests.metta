!(register-module! ../../metta-attention)
!(import! &depTypes metta-attention:experiments:kb)
!(import! &self metta-attention:experiments:depTypes)

(= (dT) &depTypes)

;test the Link and Node dependent types
!(assertEqual (get-type-space &depTypes link_ab) (Link Hebbian node_a node_b (1.0 1.0 1.0) (0.4 0.5)))
!(assertEqual (get-type-space &depTypes node_a) (Node Concept a (1.0 2.0 3.0) (0.5 0.8)))

;test AV and STV getters for links
!(assertEqual (getAV (get-type-space &depTypes link_ab)) (1.0 1.0 1.0))
!(assertEqual (getSTV (get-type-space &depTypes link_ab)) (0.4 0.5))
;
;;test AV and STV getters for nodes
!(assertEqual (getAV (get-type-space &depTypes node_a)) (1.0 2.0 3.0))
!(assertEqual (getSTV (get-type-space &depTypes node_a)) (0.5 0.8))
;;
;;;test AV and STV setters for nodes
!(setAV node_a (0 0 0))
!(setSTV node_a (0.0 0.0))
;
!(setSTV link_ab (0.0 0.0))
!(setAV link_ab (0.0 0.0 0.0))

!(getAV (get-type-space &depTypes link_ab))
!(assertEqual (getAV (get-type-space &depTypes link_ab)) (0.0 0.0 0.0))
!(assertEqual (getSTV (get-type-space &depTypes link_ab)) (0.0 0.0))

!(assertEqual (getAV (get-type-space &depTypes node_a)) (0 0 0))
!(assertEqual (getSTV (get-type-space &depTypes node_a)) (0.0 0.0))
