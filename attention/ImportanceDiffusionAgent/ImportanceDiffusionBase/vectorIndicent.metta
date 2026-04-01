!(bind! &cache (new-space))
(= (cacheSpace) &cache)

(= (defaultEmbd $n)
    (if (> 0.0 $n)
        (0.1)
        (cons-atom 0.1 (defaultEmbd (- $n 1)))
    )
)

(= (getEmbd $atom)
    (let $space
        (VecSpace)
        (unify $space ($atom $embd) $embd (defaultEmbd 385)) 
    )
)

(= (atominVec $atom)
    (let $space
        (VecSpace)
        (unify $space ($atom $embd) True False) 
    )
)

(= (getAtom ()) ())
(= (getAtom (cons $atom $tail))
   (cons-atom (match (VecSpace) ($atom $embd) $atom) (getAtom $tail))
)

(= (calculateCosine $atom () $out)
    $out
)

(= (calculateCosine $atom (cons $head $tail) $out)
    (calculateCosine $atom $tail 
        (cons-atom
            ($head (cosine (getEmbd $atom) (getEmbd $head))) $out
        )
    )
)

(= (greaterScore ($atom $score) ($head $hscore))
    (<= $score $hscore)
)

(= (lesserScore ($atom $score) ($head $hscore))
    (> $score $hscore)
)

(= (FilterScore $f $pivot () $out) $out)
(= (FilterScore $f $pivot (cons $head $tail) $out)
    (if ($f $pivot $head)
        (FilterScore $f $pivot $tail (cons-atom $head $out))
        (FilterScore $f $pivot $tail $out)
    )
)

(= (acesndingScore ()) ())
(= (acesndingScore (cons $pivot $tail))
    (let*
        (
            ($lesser (FilterScore lesserScore $pivot $tail ()))
            ($greater (FilterScore greaterScore $pivot $tail ()))
            ($sortedLesser (acesndingScore $lesser))
            ($sortedGreater (acesndingScore $greater))
        )
        (union-atom $sortedGreater (cons-atom $pivot $sortedLesser))
    )
)

(= (getCappedNatoms () $k $out) $out)
(= (getCappedNatoms (cons $head $tail) $k $out)
    (if (>= $k 1)
        (cons-atom $head (getCappedNatoms $tail (- $k 1) $out))
        $out
    )
)

(= (topk $atom $atoms $k)
    (getNatoms (cdr-atom (acesndingScore (calculateCosine $atom $atoms ()))) $k)
)

(= (getVectorIncident $atom $k)
    (let $cache 
        (cacheSpace)
        (unify $cache ($atom $target) $target
            (let*  
                (
                    ($targets (topk $atom (collapse (match (VecSpace) ($s $embd) $s)) $k)); -> ant 
                    ($added (add-atom $cache ($atom $targets)))
                )
                $targets
            )
        )
    )
)
