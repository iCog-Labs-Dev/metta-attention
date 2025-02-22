(= (forgetThreshold) 200)
(= (maxSize) 2)
(= (accDivSize) 1)


;takes two atoms and return false if either is empty, if pivot has larger lti, if lit equal return false if pivot has larger mean
(: lessThanLtiThenTV (-> Atom Atom Bool))
(= (lessThanLtiThenTV $elem $pivot)
    (if (or (== $elem ()) (== $pivot ())) 
		False
		(if (== (getLTI $elem) (getLTI $pivot))
			(< (getMean $elem) (getMean $pivot))
			(< (getLTI $elem) (getLTI $pivot))
		)
	)
)

;takes two atoms and returns false if either is empty if pivot has lower lti, if lit equal return false if pivot has lower mean 
(: greaterThanLtiThenTV (-> Atom Atom Bool))
(= (greaterThanLtiThenTV $elem $pivot)
	(if (or (== $elem ()) (== $pivot ())) 
		False
		(if (== (getLTI $elem) (getLTI $pivot))
			(>= (getMean $elem) (getMean $pivot))
			(> (getLTI $elem) (getLTI $pivot))
		)
	)
)

(= (ForgettingLTIThenTVAscendingSort $atoms)
	(if (== $atoms ())
		()
		(let*
			(
				($pivot (car-atom $atoms))
				($tail (cdr-atom $atoms))
				($lesser (binaryFilter lessThanLtiThenTV $pivot $tail))
				($greater (binaryFilter greaterThanLtiThenTV $pivot $tail))
                ($sortedLesser (ForgettingLTIThenTVAscendingSort $lesser))
                ($sortedGreater (ForgettingLTIThenTVAscendingSort $greater))
			)	
           (concatTuple $sortedLesser (cons-atom $pivot $sortedGreater))
		)
	)
)

;1. get atoms from space
;2. size of space greater than max allowed size
;3. sort atoms by Lti and mean
;4. loop over sorted atoms
;5. if lti below treshold not enough atoms removed and vlti is disposable
;6. check for hebbian links 
;7. set sti to 0
;8. remove atom
(= (forgetHelper $atoms $removalAmount) 
	(if (== $atoms ())
		()
		(let*
			(
				($count 0)
				($sortedatoms (ForgettingLTIThenTVAscendingSort $atoms))
			)
			(checkThenRemoveAtom $sortedatoms $removalAmount $count)
		
		)
	)
)

(= (checkThenRemoveAtom $sortedatoms $removalAmount $count)
	(let* 
		(	
			($head (car-atom $sortedatoms))
			($isValid (atomBelowForgetThreshold $head $removalAmount $count))
			($iset (getIncomingSet $head ASYMMETRIC_HEBBIAN_LINK))
		)
		(if (and $isValid (== $iset ()))
			(let*
				(
					($temp (removeLtiAtom $head))
					($newCount (+ 1 $count ))
					($tail (cdr-atom $sortedatoms))
				)
				(checkThenRemoveAtom $tail $removalAmount $newCount)
			)
			(can not remove $head $removalAmount $count)	
		)
	)

)

(= (removeLtiAtom $atom)
	(let $_ (setAv $atom (0.0 0.0 0.0)) (removing $atom))
)

(= (forgetAtoms $atoms)
	(let* 
		(
			($size (size-atom $atoms)) 
			($removalAmount (- $size (- (maxSize) (accDivSize))))
		)
		(if (< $size (+ (maxSize) (accDivSize)))
			()  
			(forgetHelper $atoms $removalAmount)
		)
	)
)

(= (atomBelowForgetThreshold $head $removalAmount $count) 
	(if (and (<= (getLTI $head) (forgetThreshold)) (< $count $removalAmount))
		(if (>= (getVLTI $head) 0 ) ; change to (== (getVLTI $atom) 0)
			True
			False
		)
		False
	)
)

