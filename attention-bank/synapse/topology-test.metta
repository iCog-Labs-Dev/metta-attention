!(import! &self lib/lib_he)
!(import! &self lib/lib_spaces)
!(import! &self ../attention-value/getter-and-setter)
!(import! &self topology)

!(assertEqual (persistent-homology-invariants) (TopologyReport 0 0 0))

!(setStv (ASYMMETRIC_HEBBIAN_LINK A B) (0.5 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK B C) (0.5 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK C A) (0.5 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK B A) (0.5 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK D E) (0.5 0.9))

!(assertEqual (persistent-homology-invariants) (TopologyReport 1 2 1))
!(assertEqual (get-triangle-count (persistent-homology-invariants)) 1)
!(assertEqual (get-betti0 (persistent-homology-invariants)) 2)
!(assertEqual (get-betti1 (persistent-homology-invariants)) 1)
!(assertEqual (topology-triangle-count) 1)
!(assertEqual (topology-betti0) 2)
!(assertEqual (topology-betti1) 1)

!(record-topology-report 7 123.0)
!(assertEqual (get-cip-topology-report 7) (TopologyReport 1 2 1))
