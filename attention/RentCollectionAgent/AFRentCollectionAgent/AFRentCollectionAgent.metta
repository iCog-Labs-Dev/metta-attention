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
    (getAfAtoms)
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
          ($updateFreq (getAttentionParam AFRentFrequency))
          ($lastUpdate  (match  &timer (lastUpdate $x) $x) )
          ($elapsedTime (* (- $currentTime $lastUpdate) 1000000))
          ($timeThreshold (/ 1000000 $updateFreq))
          ($multiplier (/ $updateFreq 1000000))
          ($timeres (match &timer (firstTime $bool) $bool))
      )
      (if $timeres
          (setFirstTime False)
          (if (< $elapsedTime $timeThreshold)
              (empty)
              (let*
                  (
                    ($w (* $elapsedTime $multiplier))
                    ($lists (superpose $targetSet))
                  )
                  (applyRent $w $lists)
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
          ($sti (getSti $atom))
          ($lti (getLti $atom))
          ($stiAtomRent (getAttentionParam StartingAtomStiRent))
          ($ltiAtomRent (getAttentionParam StartingAtomLtiRent))
          
          ($calculatestirent  (calculateStiRent $stiAtomRent))
          ($calculateltirent  (calculateLtiRent $ltiAtomRent))

        )
        (if (and (== $calculatestirent  0.0) (== $calculateltirent 0.0))
          (empty)
          (let*
            (
              ($stiRent (* $calculatestirent $w))
              ($ltiRent (* $calculateltirent $w))
              ($minstiRent (min-atom ($stiRent $sti)))
              ($minltiRent (min-atom ($ltiRent $lti)))
              ($stiDiff (- $sti $minstiRent))
              ($ltiDiff (- $lti $minltiRent))
              ($atomVlti (getVlti $atom ))
            )
            (setAv $atom ($stiDiff $ltiDiff $atomVlti))
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
    (let*
        (
            ($bool (remove-atom &timer (lastUpdate $x)))
            ($val $time)
        )
        (add-atom &timer (lastUpdate $val))
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
        (let $bool
            (remove-atom  &timer (firstTime $x))
            (add-atom  &timer (firstTime $flag))
        )
    )
)

(= (AFRentCollectionAgent-run)
    (let $res 
        (getAfAtoms) 
        (if (== $res ()) 
            (empty) 
            (let $x
                (collapse (collectAFRent $res))
                (setLastUpdate (timeTime))
            )
      )
    )
)
