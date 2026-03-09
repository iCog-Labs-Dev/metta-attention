; (bind! tcDecayRate 0.1)
; (bind! DEFAULT_K 800)
(= (tcDecayRate) 0.1)
(= (DEFAULT_K) 800)

;;; Function: HebbianUpdatingAgent-Run
;;; Description: Main Function to run the Hebbian Updating Agent.
;;; Parameters: None
;;; Returns: update the Hebbian link of Randomly selected atom.
;;; Example: (HebbianUpdatingAgent-Run)
;;;          Returns: update STV for the Hebbian link between A and some atom

; (: HebbianUpdatingAgent-Run (-> Grounded Atom))
(= (HebbianUpdatingAgent-Run $space)
   (with_mutex humutex 
    (let $atoms (getAfAtoms)
        (if (== $atoms ())
            ()
            (let $randomAtom (getRandomAtomInAF $atoms)
                (updateHebbianLinks $randomAtom $space)
            )
        )
    )
)
)

;;; Function: updateHebbianLinks
;;; Description: Updates the weight of incoming Hebbian links to a given atom.
;;; Parameters:
;;;   $source: The source atom for which to update the Hebbian link.
;;; Returns: update the Hebbian link.
;;; Example: (updateHebbianLinks A)
;;;          Returns: updates STV for the Hebbian link between A and some atom

; (: updateHebbianLinks (-> Atom Grounded Atom))
(= (updateHebbianLinks $source $space)
    (let*
        (
            ($iset (getAllIncomingSetsForHUAgent $source $space ASYMMETRIC_HEBBIAN_LINK))
            ($outgoing (getOutGoingAtoms $iset))
            ($head (if (== $outgoing ()) () (car-atom $outgoing)))
        )
        (if (not (== $outgoing ()))
            (let*
                (
                    ($result
                        (if (== $source $head)
                            (let*
                                (
                                    ($tcDecayRate (getAttentionParam TC_DECAY_RATE))
                                    ($new-tc (targetConjunction $outgoing))
                                    ; ($_ (println! (tc decay $tcDecayRate)))
                                    ; ($_ (println! (target out $new-tc)))

                                    (($STV $old-tc $conf) (getStv $iset))
                                    ($tc (+ (* $tcDecayRate $new-tc) (* (- 1.0 $tcDecayRate) $old-tc)))
                                    ($create-tv ($tc 0.1))
                                    ($new-tv (mergeCalculation $create-tv ($old-tc $conf) PLN_BOOK_REVISION))
                                )
                                    (setStv $iset $new-tv)
                            )
                            ($source "!=" $head)
                        )
                    )
                )
                $result
            )
            ()
        )
        
    )
)


;;; Function: targetConjunction
;;; Description: Calculates the target conjunction of a given link.
;;; Parameters:
;;;   $outgoing: The outgoing atoms for which to calculate the target conjunction.
;;; Returns: The target conjunction of the outgoing atoms.
;;; Example: (targetConjunction (A B))
;;;          Returns Number

; (: targetConjunction (-> Atom Number))
(= (targetConjunction $outgoing)
    (let*
        (
            (($source $target) $outgoing)
            ($normsti_i (getNormalisedZeroToOneSTI (getSti $source) True True))
            ; ($_ (println! (normalised i $source $normsti_i)))

            ($normsti_j (getNormalisedZeroToOneSTI (getSti $target) True True))
            ; ($_ (println! (normalised j $normsti_j)) )
            ; ($_ (println! (target $target)))

            ($conj (+ (* $normsti_i $normsti_j) (* (- $normsti_j $normsti_i) (abs-math (- $normsti_j $normsti_i)))))
            ($ret_conj (/ (+ $conj 1.0) 2.0))
        )
            $ret_conj
    )
)

;;; Function: mergeCalculation
;;; Description: Merges two STVs using a given formula.
;;; Parameters:
;;;   $stv1: The first STV to merge.
;;;   $stv2: The second STV to merge.
;;;   $formula-to-use: The formula to use for merging the STVs.
;;; Returns: The merged STV.
;;; Example: (mergeCalculation (STV 0.1 0.9) (STV 0.3 0.9) PLN_BOOK_REVISION)
;;;          Returns (STV 0.0105976 0.9)

; (: mergeCalculation (-> STV STV Symbol STV))
(= (mergeCalculation $stv1 $stv2 $formula-to-use)
    (case $formula-to-use
        (
            (PLN_BOOK_REVISION
                (let*
                    (
                        ($defaultK (getAttentionParam DEFAULT_K))
                        (($mean1 $conf1) $stv1)
                        (($mean2 $conf2) $stv2)
                        ($cf (min-atom ($conf1 0.9999998)))
                        ($count1 (/ (* $defaultK $cf) (- 1.0 $cf)))
                        ($count2 (/ (* $defaultK $conf2) (- 1.0 $conf2)))
                        ($CVAL 0.2)
                        ($count-new (- (+ $count1 $count2) (* $CVAL (min-atom ($count1 $count2)))))
                        ($mean-new (/ (+ (* $mean1 $count1) (* $mean2 $count2)) (+ $count1 $count2)))
                        ($conf-new (/ $count-new (+ $count-new $defaultK)))
                    )
                        ($mean-new $conf-new)
                )
            )
            (HIGHER_CONFIDENCE (higherConfidenceMerge $stv1 $stv2))
            ($else "NO FORMULA PROVIDED")
        )
    )
)

;;; Function: higherConfidenceMerge
;;; Description: Merges two STVs by selecting the one with the higher confidence.
;;; Parameters:
;;;   $stv1: The first STV to merge.
;;;   $stv2: The second STV to merge.
;;; Returns: The STV with the higher confidence.
;;; Example: (higherConfidenceMerge (STV 0.1 0.8) (STV 0.3 0.9))
;;;          Returns (STV 0.3 0.9)

; (: higherConfidenceMerge (-> STV STV STV))
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

;; This function will return the incoming set of an atom
;; Parameters $atom: The atom that will be used to find the incoming set
;;            $type: The type that will be used to find the incoming set
;; Return : The incoming set of the atom
; (: getAllIncomingSetsForHUAgent (-> Atom Grounded Atom List))
(= (getAllIncomingSetsForHUAgent $atom $space $type)
    (match $space (($type $atom $x) $AV) ($type $atom $x))
)
