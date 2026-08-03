(= (ecanNovelty)
    (let* (
        ($prev (collapse (match &noveltyTrack (af-snapshot $atoms) $atoms)))
        ($curr (getAfAtoms))
        ($overlap (if (== $prev ()) 0 (size-atom (intersection-atom $curr $prev))))
        ($maxSize (max-atom ((size-atom $curr) (if (== $prev ()) 0 (size-atom $prev)))))
    )
        (if (== $maxSize 0) 0.5 (- 1.0 (/ $overlap $maxSize)))
    )
)

(= (ecanConduciveness)
    (let* (
        ($af (getAfAtoms))
        ($stiList (getListsti $af))
    )
        (if (== $stiList ()) 0.5
            (let $meanSti (mean $stiList)
                (min-atom ((/ $meanSti 100.0) 1.0))
            )
        )
    )
)

(= (ecanRisk)
    (let* (
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
    (let* (
        ($afSize (size-atom (getAfAtoms)))
        ($maxSize (getAttentionParam MAX_AF_SIZE))
    )
        (if (== $maxSize 0) 0.5 (min-atom ((/ $afSize $maxSize) 1.0)))
    )
)

(= (ecanStimulus)
    (stimulus (
        (ecanNovelty)
        (ecanConduciveness)
        (ecanRisk)
        (ecanEffort)
    ))
)
