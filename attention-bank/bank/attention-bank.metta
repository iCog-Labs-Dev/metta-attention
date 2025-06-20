(bind! &space (new-space))
(add-atom &space (startingFundsSTI 100000))
(add-atom &space (fundsSTI 100000))
(add-atom &space (startingFundsLTI 100000))
(add-atom &space (fundsLTI 100000))
(add-atom &space (stiFundsBuffer 10000))
(add-atom &space (ltiFundsBuffer 10000))
(add-atom &space (targetSTI 10000))
(add-atom &space (targetLTI 10000))
(add-atom &space (STIAtomWage 10))
(add-atom &space (LTIAtomWage 10))


; Function to calculate STI wage
; Description: Calculates the adjustment factor for Short-Term Importance (STI)
;    - Compute the normalized difference between current funds and the target.
;    - Limit the adjustment factor between -1.0 and 1.0.
;    - Return the adjusted STI wage.
; Parameters: None.
; Returns: The adjusted STI wage value.
(: calculateSTIWage (-> Number))
(= (calculateSTIWage)
   (let* (
           ($funds (getAttentionParam FundsSTI))
           ($targetSTI (getAttentionParam TargetSTI))
           ($stiFundsBuffer (getAttentionParam StiFundsBuffer))
           ($STIAtomWage (getAttentionParam STIAtomWage))
           ($diff (- $funds $targetSTI))
           ($ndiff-raw (/ $diff $stiFundsBuffer))
           ($ndiff-clamped-min (min-atom ($ndiff-raw 1.0)))
           ($ndiff (max-atom ($ndiff-clamped-min -1.0)))
           ($atom-wage $STIAtomWage)
         )
         (+ $atom-wage (* $atom-wage $ndiff))
   )
)

; Function to calculate LTI wage
; Description:
;   Calculates the adjustment factor for Long-Term Importance (LTI)
;    - Compute the normalized difference between current funds and the target.
;    - Limit the adjustment factor between -1.0 and 1.0.
;    - Return the adjusted LTI wage.
; Parameters: None.
; Returns: The adjusted LTI wage value
(: calculateLTIWage (-> Number))
(= (calculateLTIWage)
   (let* (
           ($funds (getAttentionParam FundsLTI))
           ($targetLTI (getAttentionParam TargetLTI))
           ($ltiFundsBuffer (getAttentionParam LtiFundsBuffer))
           ($LTIAtomWage (getAttentionParam LTIAtomWage))
           ($diff (- $funds $targetLTI))
           ($ndiff-raw (/ $diff $ltiFundsBuffer))
           ($ndiff-clamped-min (min-atom ($ndiff-raw 1.0)))
           ($ndiff (max-atom ($ndiff-clamped-min -1.0)))
           ($atom-wage $LTIAtomWage)
         )
         (+ $atom-wage (* $atom-wage $ndiff))
   )
)

; Function to stimulate an atom with a given stimulus
; Description:
;    Adjusts the AttentionValue (STI, LTI, VLTI) of an atom based on:
;    - Calculate the new STI and LTI values using the wages and stimulus.
;    - Calculate the changes in STI and LTI funds.
;    - Call attentionValueChanged to apply the updates.
;Parameters:
;     $pattern: The atom receiving the stimulus.
;     $stimulus: The factor by which STI and LTI will be adjusted.
;Returns: Nothing (updates the atom and related values)
(: stimulate (-> Atom Number empty))
(= (stimulate $pattern $stimulus)
   (let* (
           ($sti (getSTI $pattern))
           ($lti (getLTI $pattern))
           ($vlti (getVLTI $pattern))
           ($sti-wage (* (calculateSTIWage) $stimulus))
           ($lti-wage (* (calculateLTIWage) $stimulus))
           ($new-sti (+ $sti $sti-wage))
           ($new-lti (+ $lti $lti-wage))
           ($new-av ($new-sti $new-lti $vlti))
           ($res (setAv $pattern $new-av))
         )
		 ("Updated")
   )
)

; Function to handle attention value changes and update global funds
; Description:
;    Updates the AttentionValue of an atom and adjusts the global STI and LTI funds
;    -set the new attention value of the atom 
;    - Remove the current fundsSTI and fundsLTI values from the AtomSpace.
;    - Add the updated fundsSTI and fundsLTI values to the AtomSpace.
;    - Inserts the atom to the attentional focus if possible
;    - Updates the Bin placement of the atom
;Parameters:
;     $pattern: The atom whose AttentionValue is being updated.
;     $newSTIFund: The new STI fund value.
;     $newLTIFund: The new LTI fund value.
;     $newAv: The new AttentionValue to be set for the atom.
;Returns: The result of updating the AtomBin.


(: attentionValueChanged (-> Atom Number Number empty))
(= (attentionValueChanged $pattern $newSTIFund $newLTIFund)
   (let*(
         ($one (updateAttentionParam FundsLTI $newLTIFund))
         ($two (updateAttentionParam FundsSTI $newSTIFund))
         ($atombin (AtomBin))
         ($r (update $atombin))
         ($three (updateAttentionalFocus $pattern True))
        )
        $r
    )
)

;Function: updateLTIFunds
;Description: Updates the global LTI funds by replacing the old value with a new one
;Parameters:
;     $old: The previous LTI fund value
;     $new: The new LTI fund value
;Returns: Nothing (updates the fund in the AtomSpace)
(: updateLTIFunds (-> Number Number empty))
(= (updateLTIFunds $old $new)
  (match  &space  (fundsLTI $old)
      (let ()
           (remove-atom &space (fundsLTI $old))
           (add-atom &space (fundsLTI $new))
      )
  )
)

;Function: updateSTIFunds
;Description: Updates the global STI funds by replacing the old value with a new one.
;Parameters:
;      $old: The previous STI fund value.
;      $new: The new STI fund value.
;Returns: Nothing (updates the fund in the AtomSpace).
(: updateSTIFunds (-> Number Number empty))
(= (updateSTIFunds $old $new)
  (match  &space  (fundsSTI $old)
      (let ()
           (remove-atom &space (fundsSTI $old))
           (add-atom &space (fundsSTI $new))
      )
  )
)
(: getAttentionBank  (-> Symbol Number))
(= (getAttentionBank $param)
   (match &space ($param $x) $x)
)

; Alias for &space
(= (space) &space)
