; Define initial variables and insert them in newspace called space
!(bind! &space (new-space))
!(add-atom &space (startingFundsSTI 100000))
!(add-atom &space (fundsSTI 100000))
!(add-atom &space (startingFundsLTI 100000))
!(add-atom &space (fundsLTI 100000))
!(add-atom &space (stiFundsBuffer 10000))
!(add-atom &space (ltiFundsBuffer 10000))
!(add-atom &space (targetSTI 10000))
!(add-atom &space (targetLTI 10000))
!(add-atom &space (STIAtomWage 10))
!(add-atom &space (LTIAtomWage 10))


; Function to compute the minimum of two values
(: min (-> Number Number Number))
(= (min $a $b)
    (if (< $a $b) $a $b)
)

; Function to compute the maximum of two values
(: max (-> Number Number Number))
(= (max $a $b)
    (if (> $a $b) $a $b)
)

; Function to calculate STI wage
; Purpose:
;    Calculates the adjustment factor for Short-Term Importance (STI) based on:
;    - Current STI funds
;    - Target STI funds
;    - The buffer for STI adjustments
; Logic:
;    - Compute the normalized difference between current funds and the target.
;    - Limit the adjustment factor between -1.0 and 1.0.
;    - Return the adjusted STI wage.
(: calculateSTIWage (-> Number))
(= (calculateSTIWage)
   (let* (
           ($funds (match  &space  (fundsSTI $x) $x))
           ($targetSTI (match  &space  (targetSTI $y) $y))
           ($stiFundsBuffer (match  &space  (stiFundsBuffer $z) $z))
           ($STIAtomWage (match  &space  (STIAtomWage $z) $z))
           ($diff (- $funds $targetSTI))
           ($ndiff-raw (/ $diff $stiFundsBuffer))
           ($ndiff-clamped-min (min $ndiff-raw 1.0))
           ($ndiff (max $ndiff-clamped-min -1.0))
           ($atom-wage $STIAtomWage)
         )
         (+ $atom-wage (* $atom-wage $ndiff))
   )
)

; Function to calculate LTI wage
; Purpose:
;    Calculates the adjustment factor for Long-Term Importance (LTI) based on:
;    - Current LTI funds
;    - Target LTI funds
;    - The buffer for LTI adjustments
; Logic:
;    - Compute the normalized difference between current funds and the target.
;    - Limit the adjustment factor between -1.0 and 1.0.
;    - Return the adjusted LTI wage.
(: calculateLTIWage (-> Number))
(= (calculateLTIWage)
   (let* (
           ($funds (match  &space  (fundsLTI $x) $x))
           ($targetLTI (match  &space  (targetLTI $y) $y))
           ($ltiFundsBuffer (match  &space  (ltiFundsBuffer $z) $z))
           ($LTIAtomWage (match  &space (LTIAtomWage $z) $z))
           ($diff (- $funds $targetLTI))
           ($ndiff-raw (/ $diff $ltiFundsBuffer))
           ($ndiff-clamped-min (min $ndiff-raw 1.0))
           ($ndiff (max $ndiff-clamped-min -1.0))
           ($atom-wage $LTIAtomWage)
         )
         (+ $atom-wage (* $atom-wage $ndiff))
   )
)

; Function to stimulate an atom with a given stimulus
; Purpose:
;    Adjusts the AttentionValue (STI, LTI, VLTI) of an atom based on:
;    - Calculated STI and LTI wages
;    - A stimulus factor
; Logic:
;    - Calculate the new STI and LTI values using the wages and stimulus.
;    - Calculate the changes in STI and LTI funds.
;    - Call attentionValueChanged to apply the updates.
(: stimulate (-> Atom Number Grounded empty))
(= (stimulate $pattern $stimulus $space)
   (let* (
           ($sti (getSTI (getType $space $pattern)))
           ($lti (getLTI (getType $space $pattern)))
           ($vlti (getVLTI (getType $space $pattern)))
           ($sti-wage (* (calculateSTIWage) $stimulus))
           ($lti-wage (* (calculateLTIWage) $stimulus))
           ($new-sti (+ $sti $sti-wage))
           ($new-lti (+ $lti $lti-wage))
           ($new-av ($new-sti $new-lti $vlti))
           ($stiDiff (- $sti $new-sti))
           ($ltiDiff (- $lti $new-lti))
           ($fundsSTI (match &space  (fundsSTI $x) $x))
           ($fundsLTI (match  &space  (fundsLTI $x) $x))
           ($newstifund (+ $fundsSTI $stiDiff))
           ($newltifund (+ $fundsLTI $ltiDiff))
           ($res (updateImportance $space $pattern $sti $new-sti $space))
         )
         (attentionValueChanged $pattern $newstifund $newltifund $new-av $space)
   )
)

; Function to handle attention value changes and update global funds
; Purpose:
;    Updates the AttentionValue of an atom and adjusts the global STI and LTI funds.
; Logic:
;    -set the new attention value of the atom 
;    - Remove the current fundsSTI and fundsLTI values from the AtomSpace.
;    - Add the updated fundsSTI and fundsLTI values to the AtomSpace.

(: attentionValueChanged (-> Atom Number Number Atom Grounded empty))
(= (attentionValueChanged $pattern $newSTIFund $newLTIFund $newAv $space)
   (let*(
         ($res (setAv $pattern $newAv))
         ($oldSTIFund (match &space (fundsSTI $fundsSTI) $fundsSTI))
         ($oldLTIFund (match &space (fundsLTI $fundsLTI) $fundsLTI))
         ($_ (updateLTIFunds $oldLTIFund $newLTIFund))
         ($_ (updateSTIFunds $oldSTIFund $newSTIFund))
         ($_ (updateAttentionalFocus $pattern $space))
         ($atombin (AtomBin))
         ($r (update $atombin))
        )
        $r
    )
)

(: updateLTIFunds (-> Number Number empty))
(= (updateLTIFunds $old $new)
  (match  &space  (fundsLTI $old)
      (let ()
           (remove-atom &space (fundsLTI $old))
           (add-atom &space (fundsLTI $new))
      )
  )
)

(: updateSTIFunds (-> Number Number empty))
(= (updateSTIFunds $old $new)
  (match  &space  (fundsSTI $old)
      (let ()
           (remove-atom &space (fundsSTI $old))
           (add-atom &space (fundsSTI $new))
      )
  )
)
