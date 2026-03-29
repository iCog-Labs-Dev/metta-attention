(= (defaultEmbd $n)
  (if (> 0.0 $n)
    (0.001)
    (cons-atom 0.0001 (defaultEmbd (- $n 1)))
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
  (>= $score $hscore)
)

(= (lesserScore ($atom $score) ($head $hscore))
  (< $score $hscore)
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
        (concatTuple $sortedGreater (cons-atom $pivot $sortedLesser))
    )
)

(= (topk $atom $atoms $k)
    (if (atominVec $atom)
        (getNatoms (cdr-atom (acesndingScore (calculateCosine $atom $atoms ()))) $k)
        (getNatoms (acesndingScore (calculateCosine $atom $atoms ())) $k)
    )
)

(= (getVectorIncident $atom $k)
   (topk $atom (collapse (match (VecSpace) ($s $embd) $s)) $k)
)
