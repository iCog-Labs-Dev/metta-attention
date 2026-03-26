(= (defaultEmbd $n)
  (if (> 0.0 $n)
    (1.0)
    (cons-atom 1.0 (defaultEmbd (- $n 1)))
  )
)

(= (getEmbd $atom)
  (unify &vecEmbd ($atom $embd) $embd (defaultEmbd 385)) 
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

(= (greaterScore ($atom $score) ($head $hscore) $any)
  (>= $score $hscore)
)

(= (lesserScore ($atom $score) ($head $hscore) $any)
  (< $score $hscore)
)

(= (acesndingScore ()) ())

(= (acesndingScore (cons $pivot $tail))
		(let*
			(
				($lesser (binaryFilter lesserScore $pivot $tail ()))
				($greater (binaryFilter greaterScore $pivot $tail ()))
        ($sortedLesser (acesndingScore $lesser))
        ($sortedGreater (acesndingScore $greater))
			)	
      (concatTuple $sortedGreater (cons-atom $pivot $sortedLesser))
		)
)

(= (topk $atom $atoms $k)
   (getNatoms (acesndingScore (calculateCosine $atom $atoms ())) $k)
)

(= (topNeighbours $atom $k)
  (topk $atom (collapse (match (VecSpace) ($s $embd) $s)) $k)
)
