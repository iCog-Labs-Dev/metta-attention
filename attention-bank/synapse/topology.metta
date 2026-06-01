!(import! &self "topology_metrics.py")

!(bind! &topologySeries (new-space))

(= (TopologySeries) &topologySeries)

; Topological invariants of the undirected Hebbian link graph.
; TopologyReport fields:
;   triangle_count: unique 3-cycles
;   betti_0: connected components
;   betti_1: independent graph cycles

(= (topology-metrics)
    (py-call (topology_metrics.topology_metric_values (getAllHebLinks)))
)

(= (get-topology-triangle-count ($triangles $betti0 $betti1)) $triangles)
(= (get-topology-betti0 ($triangles $betti0 $betti1)) $betti0)
(= (get-topology-betti1 ($triangles $betti0 $betti1)) $betti1)

(= (get-triangle-count (TopologyReport $triangles $betti0 $betti1)) $triangles)
(= (get-betti0 (TopologyReport $triangles $betti0 $betti1)) $betti0)
(= (get-betti1 (TopologyReport $triangles $betti0 $betti1)) $betti1)

(= (persistent-homology-invariants)
    (let* (
            ($metrics (topology-metrics))
            ($triangles (get-topology-triangle-count $metrics))
            ($betti0 (get-topology-betti0 $metrics))
            ($betti1 (get-topology-betti1 $metrics))
        )
        (TopologyReport $triangles $betti0 $betti1)
    )
)

(= (topology-triangle-count)
    (let* (
            ($report (persistent-homology-invariants))
            ((TopologyReport $triangles $betti0 $betti1) $report)
        )
        $triangles
    )
)

(= (topology-betti0)
    (let* (
            ($report (persistent-homology-invariants))
            ((TopologyReport $triangles $betti0 $betti1) $report)
        )
        $betti0
    )
)

(= (topology-betti1)
    (let* (
            ($report (persistent-homology-invariants))
            ((TopologyReport $triangles $betti0 $betti1) $report)
        )
        $betti1
    )
)

(= (record-topology-report $cipIndex $time)
    (let $report (persistent-homology-invariants)
        (add-atom &topologySeries (CIPTopologyReport $cipIndex $time $report))
    )
)

(= (get-cip-topology-report $cipIndex)
    (let $report (collapse (match &topologySeries
                            (CIPTopologyReport $cipIndex $time $report)
                            $report))
        (if (== $report ())
            ()
            (car-atom $report)
        )
    )
)

(= (get-topology-series)
    (collapse (match &topologySeries
              (CIPTopologyReport $cipIndex $time $report)
              (CIPTopologyReport $cipIndex $time $report)))
)
