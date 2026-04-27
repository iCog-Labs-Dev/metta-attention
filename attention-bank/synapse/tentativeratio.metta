; ;; cognitive maintainance (recursive list version)
; (= (cognitiveMaintainanceHelper () $sum $count)
;      (if (> $count 0) (/ $sum $count) 0.0)
; )
;
; (= (cognitiveMaintainanceHelper (cons $single ()) $sum $count)
;      (if (> $count 0) (/ $sum $count) 0.0)
; )
;
; (= (cognitiveMaintainanceHelper (cons $state1 (cons $state2 $tail)) $sum $count)
;      (let*
;           (
;              ($retention (contextRetention $state1 $state2))
;              ($newSum (+ $sum $retention))
;              ($newCount (+ $count 1))
;           )
;      )
;      (
;        (cognitiveMaintainanceHelper (cons $state2 $tail) $newSum $newCount)
;      )
; )
;
; (= (cognitiveMaintainance $trajectory)
;      (cognitiveMaintainanceHelper $trajectory 0.0 0)
; )


(= (systemPerformance $state)
  ;; todo -> an actual performance metrics is required
  1.0
)

(= (totalResourceCost $state)
  ;; todo -> again an actual cost metrics is required, I will try out afResourceUsage
  1.0
)

(= (gainedEfficiency $optimizedState $baselineState)
    (let*
        (
           ($baselineCost (totalResourceCost $baselineState))
           ($optimizedCost (totalResourceCost $optimizedState))
           ($baselinePerf (systemPerformance $baselineState))
           ($optimizedPerf (systemPerformance $optimizedState))
           ($baselineEff
              (if (> $baselineCost 0) (/ $baselinePerf $baselineCost) 0.0)
           )
           ($optimizedEff 
                (if (> $optimizedCost 0) (/ $optimizedPerf $optimizedCost) 0.0)
           )
           ($efficiencyDiff (- $optimizedEff $baselineEff))
        ) 
        (if (> $baselineEff 0)
            (/ $efficiencyDiff $baselineEff)
            0.0
        )
    )
)


(= (getClipIndex (CIPSnapshot $index $state $time $metrics)) $index)

(= (cipCurrentTime)
 ;; bind to an actual time lib
 0 
)

(= (measureAllMetrics $state $trajectory)
   ((DummyMetric 1.0))
)

(= (initializeBaselineClip $initialState)
    (let*
        (
            ($metrics (measureAllMetrics $initialState ()))
            ($timestamp (cipCurrentTime))
        )
        (CIPSnapshot 0 $initialState $timestamp $metrics)
    )
)

(= (transitionToNextClip $prevClip $newState $trajectory)
    (let*
        (
            ($prevIndex (getClipIndex $prevClip))
            ($newIndex (+ $prevIndex 1))

            ($metrics (measureAllMetrics $newState $trajectory))

            ($timestamp (cipCurrentTime))
        )
        (CIPSnapshot $newIndex $newState $timestamp $metrics)
    )
)
