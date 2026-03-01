!(bind! &af (new-space))


(= (updateAf $atom $sti)
    (let* (
            ($minsti (getAttentionParam MIN_AF_STI))
            ($maxSize (getAttentionParam MAX_AF_SIZE) )
            ($size (match-count &af ($x $val)))
            ($re (if (isAtomInAf $atom)
                         (let $o (remove-atom &af ($atom $oldSti)) 
                                (add-atom &af ($atom $sti)))
                        (if (< $size $maxSize)
                            (add-atom &af ($atom $sti))
                            (if (< $minsti $sti) 
                                (let $o (remove-atom &af ($lowAtom $minsti)) 
                                    (add-atom &af ($atom $sti)))
                                    ()
                            )
                        )
                    )
            )
        ) (updateMinAf))
)


(= (getAfAtoms)
    (let $x (collapse (match &af $all $all)) (trace! (write_csv_wrapper $x) (collapse (car-atom (superpose $x)))))
)
(= (isAtomInAf $pattern) 
    (> (match-count &af ($pattern $val)) 0)
)
(= (updateMinAf)
    (let $sti (collapse (match &af ($atom $sti) $sti))
            (if (= sti ()) () (updateAttentionParam MIN_AF_STI (min-atom $sti))))
)
(= (getRandomAtomNotInAF)
    (let* (
            ($min (getAttentionParam MIN_AF_STI) )
            ($all (getAllAtomsWithBins))
            ($lessThan (collapse (subtraction (superpose $all) (superpose (getAfAtoms))) ))
    ) (if (= $lessThan ()) () (py-call (random.choice $lessThan))))
)

(= (getRandomAtomInAF)
    (let $atoms (getAfAtoms) (py-call (random.choice $atoms)))
)

(= (getIncomingSetByType $atom $type $list)
    (collapse 
        (let*
            (
                ($x (superpose $list))
                ($y (unify ($type $elem $atom) $x ($type $elem $atom) ()))
                ($l (unify ($type $atom $z) $x ($type $atom $z) ()))
            ) 
            (if (and (== $y ()) (== $l ())) (empty) (union-atom $y $l))
        )
    )
)