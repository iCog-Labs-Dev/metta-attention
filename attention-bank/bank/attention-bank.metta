!(bind! &space (new-space))

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
           ($funds (getAttentionParam FUNDS_STI))
           ($targetSTI (getAttentionParam TARGET_STI))
           ($stiFundsBuffer (getAttentionParam STI_FUNDS_BUFFER))
           ($STIAtomWage (getAttentionParam STI_ATOM_WAGE))
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
           ($funds (getAttentionParam FUNDS_LTI))
           ($targetLTI (getAttentionParam TARGET_LTI))
           ($ltiFundsBuffer (getAttentionParam LTI_FUNDS_BUFFER))
           ($LTIAtomWage (getAttentionParam LTI_ATOM_WAGE))
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
           ($sti (getSti $pattern))
           ($lti (getLti $pattern))
           ($vlti (getVlti $pattern))
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
;    - Remove the current FUNDS_STI and FUNDS_LTI values from the AtomSpace.
;    - Add the updated FUNDS_STI and FUNDS_LTI values to the AtomSpace.
;    - Inserts the atom to the attentional focus if possible
;    - Updates the Bin placement of the atom
;Parameters:
;     $pattern: The atom whose AttentionValue is being updated.
;     $newSTIFund: The new STI fund value.
;     $newLTIFund: The new LTI fund value.
;     $newAv: The new AttentionValue to be set for the atom.
;Returns: The result of updating the atomBin.


(: attentionValueChanged (-> Atom Number Number Expression))
(= (attentionValueChanged $pattern $newSTIFund $newLTIFund)
   (let*(
         ($stiUpdated (updateAttentionParam FUNDS_STI $newSTIFund))
         ($ltiUpdated (updateAttentionParam FUNDS_LTI $newLTIFund))
         ($globalUpdate (update &typeSpace))
        )
        ()
    )
)
