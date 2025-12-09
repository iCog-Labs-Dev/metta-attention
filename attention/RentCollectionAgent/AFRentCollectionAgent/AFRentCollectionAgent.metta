; Bind Python time module to get current timestamp
; ! (bind! time-mod (py-atom time))
; ! (bind! timeTime (py-dot time-mod time (-> Number)))
(= (timeTime) (let $time (py-call (time.time)) $time) )



; AFRentCollectionAgent - Handles rent collection for atoms in Attentional Focus (AF).
; The agent collects rent from atoms in AF based on elapsed time.
; Rent is deducted from STI and LTI values, ensuring values do not go negative.
!(bind! &timer (new-space))
!(add-atom &timer  (firstTime True))
; !(add-reduct &timer (lastUpdate (timeTime)))
!(let $time (timeTime) (add-atom &timer (lastUpdate $time)))

; Function: selectTargets
; Description: Retrieves the list of atoms currently in attentional focus.
; Returns: A list of atoms in attentional focus.
; (: selectAFTargets (-> Expression))
(= (selectAFTargets)
    (eval (getAfAtoms))
)

; Function: collectRent
; Description: Deducts rent from STI and LTI of atoms in attentional focus.
;              Ensures rent is applied at a controlled frequency.
; Parameters:
;   - $targetSet: List of atoms in attentional focus.
; Returns: None.
; (: collectAFRent (-> Expression empty))
(= (collectAFRent $targetSet)
  (let*
      (
          ($currentTime  (timeTime))
          ($updateFreq (eval (getAttentionParam AFRentFrequency)))
          ($lastUpdate  (match  &timer (lastUpdate $x) $x) )
          ($elapsedTime (* (- $currentTime $lastUpdate) 1000000))
          ($timeThreshold (/ 1000000 $updateFreq))
          ($multiplier (/ $updateFreq 1000000))
          ($timeres (let $resul (match &timer (firstTime $bool) $bool) $resul))
      )
      (if $timeres
          (let $x
            (setFirstTime False)
            (setLastUpdate $currentTime)
          )
          (if (< $elapsedTime $timeThreshold)
              (empty)
              (let*
                  (
                    ($w (* $elapsedTime $multiplier))
                    ($lists (superpose $targetSet))
                  )
                  (
                    (applyRent $w $lists)
                    (setLastUpdate (timeTime))
                  )
              )
          )
      )
   )
)


; Function: applyRent
; Description: Deducts STI and LTI rent from an atom, ensuring it does not go below zero.
; Parameters:
;   - $atom: The atom undergoing rent collection.
;   - $w: Weight factor based on elapsed time.
; Returns: None.
; (: applyRent (->  Number Atom empty))
(= (applyRent  $w $atom)
   (let*
        (
          ($sti (eval (getSti $atom)))
          ($atomss (println! (this is atom $atom)))
          ($lti (eval (getLti $atom)))
          ($stiAtomRent (eval (getAttentionParam StartingAtomStiRent)))
          ($ltiAtomRent (eval (getAttentionParam StartingAtomLtiRent)))
          
          ($calculatestirent  (calculateStiRent $stiAtomRent))
          ($calculateltirent  (calculateLtiRent $ltiAtomRent))

        )
        (if (and (== $calculatestirent  0.0) (== $calculateltirent 0.0))
          ()
          (let*
            (
              ($stiRent (* $calculatestirent $w))
              ($ltiRent (* $calculateltirent $w))
              ($minstiRent (min-atom ($stiRent $sti)))
              ($minltiRent (min-atom ($ltiRent $lti)))
              ($stiDiff (- $sti $minstiRent))
              ($ltiDiff (- $lti $minltiRent))
              ($atomVlti (eval (getVlti $atom )))
            )
            (eval (setAv $atom ($stiDiff $ltiDiff $atomVlti)))
          )
          
        )
   )
)

; Function: setLastUpdate
; Description: Updates the last recorded timestamp for rent collection.
; Parameters:
;   - $time: The new timestamp to store.
; Returns: None.
; (: setLastUpdate (-> Number empty))
(= (setLastUpdate $time)
  ( (match  &timer (lastUpdate $x)
                  (let ()
                        (remove-atom &timer (lastUpdate $x))
                        (add-atom &timer  (lastUpdate $time))
                  )
    )
  )
)

; Function: setFirstTime
; Description: Sets the firstTime flag to false after initialization.
; Parameters:
;   - $flag: Boolean value to update firstTime.
; Returns: None.
; (: setFirstTime (-> Bool empty))
(= (setFirstTime $flag)
  (
    ; (match  &timer (firstTime $x)
                  (let $x
                    (remove-atom  &timer (firstTime $x))
                    (add-atom  &timer (firstTime $flag))
                  )
    ; )
  )
)

(= (AFRentCollectionAgent-run)
   (let*
    (  ($time (py-call (time.time)))
       ($time2 (timeTime))
       ($res (selectAFTargets) )
    )
      (if (== $res ()) (empty) (collectAFRent $res))
    )
)
