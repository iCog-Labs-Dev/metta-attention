!(bind! tcDecayRate 0.1)
!(bind! DEFAULT_K 800)

(: HebbianUpdatingAgent-Run (-> Atom))
(= (HebbianUpdatingAgent-Run)
    (let $atoms (getAtomList)
        (if (== $atoms ())
            ()
            (let*
                (
                    ($random (random-int 0 (size-atom $atoms)))
                    ($source (index-atom $atoms $random))
                )
                (updateHebbianLinks $source)
            )
        )
    )
)

(: updateHebbianLinks (-> Atom Atom))
(= (updateHebbianLinks $source)
    (let*
        (
            ($link (let $decomposed (getIncomingSetByType $source ASYMMETRIC_HEBBIAN_LINK ) (superpose $decomposed)))
            ($outgoing (getOutGoingAtoms $link))
        )
        (if (not (== $outgoing ()))
            (let*
                (
                    ($result
                        (if (== $source (car-atom $outgoing))
                            (let*
                                (
                                    ($new-tc (targetConjunction $outgoing))
                                    (($STV $old-tc $conf) (getStv $link))
                                    ($tc (+ (* tcDecayRate $new-tc) (* (- 1.0 tcDecayRate) $old-tc)))
                                    ($create-tv ($tc 0.1))
                                    ($new-tv (mergecalculation $create-tv ($old-tc $conf) PLN_BOOK_REVISION))
                                )
                                    (setStv $link $new-tv)
                            )
                            ("Source != $Outgoing Source")
                        )
                    )
                )
                $result
            )
            ()
        )
    )
)

(: getOutGoingAtoms (-> Atom Atom))
(= (getOutGoingAtoms $link)
    (if (== (size-atom $link) 3)
        (cdr-atom $link)
        ()
    )
)

(: targetConjunction (-> Atom Number))
(= (targetConjunction $outgoing)
    (let*
        (
            (($source $target) $outgoing)
            ($normsti_i (getNormalisedZeroToOneSTI $source True True))
            ($normsti_j (getNormalisedZeroToOneSTI $target True True))
            ($conj (+ (* $normsti_i $normsti_j) (* (- $normsti_j $normsti_i) (abs-math (- $normsti_j $normsti_i)))))
            ($ret_conj (/ (+ $conj 1.0) 2.0))
        )
            $normsti_i
    )
)

;;tobe checked the calculation need to be the same as the
;; c++ test I tested
(: mergecalculation (-> STV STV Symbol STV))
(= (mergecalculation $stv1 $stv2 $formula-to-use)
    (case $formula-to-use
        (
            (PLN_BOOK_REVISION
                (let*
                    (
                        (($mean1 $conf1) $stv1)
                        (($mean2 $conf2) $stv2)
                        ($cf (min-atom ($conf1 0.9999998)))
                        ($count1 (/ (* DEFAULT_K $cf) (- 1.0 $cf)))
                        ($count2 (/ (* DEFAULT_K $conf2) (- 1.0 $conf2)))
                        ($CVAL 0.2)
                        ($count-new (- (+ $count1 $count2) (* $CVAL (min-atom ($count1 $count2)))))
                        ($mean-new (/ (+ (* $mean1 $count1) (* $mean2 $count2)) (+ $count1 $count2)))
                        ($conf-new (/ $count-new (+ $count-new DEFAULT_K)))
                    )
                        ($mean-new $conf-new)
                )
            )
            (HIGHER_CONFIDENCE (higherConfidenceMerge $stv1 $stv2))
            ($else "NO FORMULA PROVIDED")
        )
    )
)

(: higherConfidenceMerge (-> STV STV STV))
(= (higherConfidenceMerge $stv1 $stv2)
    (let*
        (
            (($mean1 $conf1) $stv1)
            (($mean2 $conf2) $stv2)
        )
        (if (> $conf2 $conf1)
            $stv2
            $stv1
        )
    )
)