(= (edgeFirst (similarityLink $x $y)) $x)
(= (edgeSecond (similarityLink $x $y)) $y)

(= (linksOf $atom)
    (collapse (match &incident ($atom $inc) $inc))
)

(= (allSeedEdges $seeds)
    (if (== $seeds ())
        ()
        (let*
            (
                ($head (car-atom $seeds))
                ($tail (cdr-atom $seeds))
                ($incidents (linksOf $head))
            )
            (union-atom $incidents (allSeedEdges $tail))
        )
    )
)

(= (collectRelated $seeds)
    (if (== $seeds ())
        ()
        (let $edges 
            (allSeedEdges $seeds)
            (let $all (union-atom $seeds $edges)
                (removeDuplicates $all)
            )
        )
    )
)

(= (weight $atom $related)
    (if (contains $related $atom) 1.0 0.75)
)

(= (weightedNew $atoms $related)
    (if (== $atoms ())
        0.0
        (let* 
            (
                ($head (car-atom $atoms))
                ($tail (cdr-atom $atoms))
            )
            (+ (weight $head $related) (weightedNew $tail $related))
        )
    )
)
