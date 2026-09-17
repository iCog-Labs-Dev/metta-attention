
(= (ecanNovelty)
    (let*
        (
            ($prevs (collapse (match &noveltyTrack (af-snapshot $atoms) $atoms)))
            ($prev (if (== $prevs ()) () (car-atom $prevs)))
            ($curr (getAfAtoms))
            ($seedes (collapse (match &noveltyTrack (lastSeeds $s) $s)))
            ($seeds (if (== $seedes ()) () (car-atom $seedes)))
            ($newAtoms (if (== $prev ()) () (subtraction-atom $curr $prev)))
            ($maxSize (max-atom ((size-atom $curr) (if (== $prev ()) 0 (size-atom $prev)))))
            ($related (collectRelated $seeds))
            ($weighted (weightedNew $newAtoms $related))
        )
        (if (or (== $prev ()) (== $seeds ()) (== $maxSize 0))
            0.5
            (/ $weighted $maxSize)
        )
    )
)

(= (ecanConduciveness)
    (getSelectionModulation)
)

(= (ecanRisk)
    (let*
        (
            ($stiList (getListsti (getAfAtoms)))
        )
        (if (== $stiList ())
            0.5
            (let $m (mean $stiList)
                (if (== $m 0) 0.5
                    (min-atom ((/ (std $stiList) $m) 1.0))
                )
            )
        )
    )
)

(= (ecanEffort)
    (getEffectiveness)
)

(= (ecanStimulus)
    (stimulus (
        (ecanNovelty)
        (ecanConduciveness)
        (ecanRisk)
        (ecanEffort)
    ))
)

(= (stimNovelty (stimulus ($n $c $r $e))) $n)
(= (stimConduciveness (stimulus ($n $c $r $e))) $c)
(= (stimRisk (stimulus ($n $c $r $e))) $r)
(= (stimEffort (stimulus ($n $c $r $e))) $e)
