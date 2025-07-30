; Function: calculateStiRent
; Description: Adjusts STI rent based on the difference between target and current STI funds.
; Parameters:
;   $STIAtomRent - Base STI rent value or scaled STI rent value
; Returns: Adjusted STI rent.
(: calculateStiRent (->  Number Number))
(= (calculateStiRent $STIAtomRent)
   (let*
      (
         ($funds (getAttentionParam FUNDS_STI))
         ($targetSti (getAttentionParam TARGET_STI))
         ($stiFundsBuffer (getAttentionParam STI_FUNDS_BUFFER))
         ($diff (- $targetSti $funds))
      )
      (if  (<= $diff 0)
            0.0
            (let*
                  (
                     ($ndiff (/ $diff $stiFundsBuffer))
                     ($minDiffr (min-atom ($ndiff 1.0)))
                     ($maxDiffr (max-atom ($minDiffr -0.99)))
                     ($res (+ $STIAtomRent (* $STIAtomRent $maxDiffr)))
                  )
                  $res
            )
      )
   )
)

; Function: calculateLtiRent
; Description: Adjusts LTI rent based on the difference between target and current LTI funds.
; Parameters:
;   $LTIAtomRent - Base LTI rent value or scaled LTI rent value
; Returns: Adjusted LTI rent.
(: calculateLtiRent (->Number  Number))
(= (calculateLtiRent $LTIAtomRent)
   (let*
      (
         ($funds (getAttentionParam FUNDS_STI))
         ($targetLti (getAttentionParam TARGET_STI))
         ($ltiFundsBuffer (getAttentionParam LTI_FUNDS_BUFFER))
         ($diff (- $targetLti $funds))
      )
      (if (<= $diff 0)
            0.0
            (let*
               (
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
