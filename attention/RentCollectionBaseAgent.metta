; Function: calculate_STI_Rent
; Description: Computes STI rent based on the available STI funds and target STI.
;              If the difference between target and current STI funds is non-positive, return 0.
;              Otherwise, adjust STI rent based on the normalized difference, clamping it between -0.99 and 1.0.
; Returns: The adjusted STI rent value.
(: calculateStiRent (->  Number Number))
(= (calculateStiRent $STIAtomRent)
   (let* (
          ($funds (getAttentionBank  fundsSTI))                    ; Current STI funds from the bank.
          ($targetSTI (getAttentionParam TargetStiFunds)) ; Retrieve target STI funds.
          ($stiFundsBuffer (getAttentionParam StiFundsBuffer)) ; Retrieve STI buffer.
        
          ($diff (- $targetSTI $funds))              ; Difference: targetSTI - current funds.
         )
      (if (<= $diff 0)
          0.0
          (let* (
                 ($ndiff (/ $diff $stiFundsBuffer))  ; Normalize the difference by the buffer.
                 ($minDiffr (min-atom ($ndiff 1.0)))    ; Clamp upper bound to 1.0.
                 ($maxDiffr (max-atom ($minDiffr -0.99)))  ; Clamp lower bound to -0.99.
                 ($res (+ $STIAtomRent (* $STIAtomRent $maxDiffr))) ; Adjust STI rent by the factor.
                )
             $res
          )
      )
   )
)

; Function: calculate_LTI_Rent
; Description: Computes LTI rent based on the available LTI funds and target LTI.
;              If the difference between target and current LTI funds is non-positive, return 0.
;              Otherwise, adjust LTI rent based on the normalized difference, clamping it between -1.0 and 1.0.
; Returns: The adjusted LTI rent value.
(: calculateLtiRent (->Number  Number))
(= (calculateLtiRent $LTIAtomRent)
   (let* (
          ($funds (getAttentionBank fundsLTI))                    ; Current LTI funds from the bank.
          ($targetLTI (getAttentionParam TargetLtiFunds)) ; Retrieve target LTI funds.
          ($ltiFundsBuffer (getAttentionParam LtiFundsBuffer)) ; Retrieve LTI buffer.
          ($diff (- $targetLTI $funds))              ; Difference: targetLTI - current funds.
         )
      (if (<= $diff 0)
          0.0
          (let* (
                 ($ndiff (/ $diff $ltiFundsBuffer))
                 ($minDiffr (min-atom ($ndiff 1.0)))
                 ($maxDiffr (max-atom ($minDiffr -1.0))) 
                 ($res (+ $LTIAtomRent (* $LTIAtomRent $maxDiffr))) 
                )
             $res 
          )
      )
   )
)
