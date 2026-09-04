!(bind! &tsState (new-space))

(= (thompsonStrategies)
    (narrow-focus expand-focus explore-novel)
)

(= (clamp01 $x)
    (if (< $x 0.0) 0.0 (if (> $x 1.0) 1.0 $x))
)

(= (absValue $x)
    (if (< $x 0.0) (- 0.0 $x) $x)
)

(= (tsLookup $strat)
    (unify &tsState (ts-posterior $strat $alpha $beta) ($alpha $beta) (1.0 1.0))
)

(= (tsScores ()) ())
(= (tsScores (cons $head $tail))
    (let* 
        (
            (($alpha $beta) (tsLookup $head))
            ($sample (randomBeta $alpha $beta))
        )
        (cons-atom ($head $sample) (tsScores $tail))
    )
)

(= (sampleStrat ($s $v)) $s)
(= (sampleVal ($s $v)) $v)

(= (pickBest $samples $bestVal $bestName)
    (if (== $samples ())
        ($bestName $bestVal)
        (let* 
            (
                ($head (car-atom $samples))
                ($tail (cdr-atom $samples))
            )
            (if (> (sampleVal $head) $bestVal)
                (pickBest $tail (sampleVal $head) (sampleStrat $head))
                (pickBest $tail $bestVal $bestName)
            )
        )
    )
)

(= (pickBestSample $samples)
    (car-atom (pickBest $samples -1.0 ()))
)

(= (tsUpdate $strat $r)
    (match &tsState (ts-posterior $strat $alpha $beta)
        (let $_ (remove-atom &tsState (ts-posterior $strat $alpha $beta))
            (add-atom &tsState (ts-posterior $strat (+ $alpha $r) (+ $beta (- 1.0 $r))))
        )
    )
)

(= (bandReward $prevCond $nextCond)
    (clamp01 (+ 0.5 (* 5.0 (- (absValue (- $prevCond 0.5)) (absValue (- $nextCond 0.5))))))
)

(= (rawReward $prevStim $nextStim)
    (+ (+ (* 0.25 (stimNovelty $nextStim))
          (* 0.35 (bandReward (stimConduciveness $prevStim) (stimConduciveness $nextStim))))
       (+ (* 0.10 (- 1.0 (stimRisk $nextStim)))
          (* 0.25 (- 1.0 (stimEffort $nextStim)))))
)

(= (differentialReward $raw $baseline)
    (clamp01 (+ (- $raw $baseline) 0.2))
)

(= (updateBaseline $baseline $raw)
    (+ (* 0.9 $baseline) (* 0.1 $raw))
)
