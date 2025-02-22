; Bind Python time module to get current timestamps
! (bind! time-mod (py-atom time))
! (bind! timeTime (py-dot time-mod time (-> Number)))

; AFRentCollectionAgent - Handles rent collection for atoms in Attentional Focus (AF).
; The agent collects rent from atoms in AF based on elapsed time.
; Rent is deducted from STI and LTI values, ensuring values do not go negative.

(: lastUpdate Number)  
(: firstTime Boolean)
(= (firstTime) True)  ; Initialize firstTime flag
(= (lastUpdate) (timeTime))  ; Initially set to current time.

; Function: selectTargets
; Description: Retrieves the list of atoms currently in attentional focus.
; Returns: A list of atoms in attentional focus.
(: selectAFTargets (-> Expression))
(= (selectAFTargets)
   (let $atomList (getAtomList)
      $atomList  
   ) 
)

; Function: collectRent
; Description: Deducts rent from STI and LTI of atoms in attentional focus.
;              Ensures rent is applied at a controlled frequency.
; Parameters:
;   - $targetSet: List of atoms in attentional focus.
; Returns: None.
(: collectAFRent (-> Expression empty))
(= (collectAFRent $targetSet)
   (let* (
           ($currentTime (timeTime))  ; Get current timestamp.
           ($updateFreq (getAttentionParam AFRentFrequency))  ; Get AF rent update frequency.
           ($elapsedTime (* (- $currentTime (lastUpdate)) 1000000))  ; Compute elapsed time.
           ($timeThreshold (/ 1000000 $updateFreq))
           ($multiplier (/ $updateFreq 1000000))    ; Time threshold for rent collection.
         )
      (if (firstTime)
          ((setLastUpdate $currentTime)  ; Initialize last update time.
           (setFirstTime False))  ; Mark firstTime as false.
          (if (< $elapsedTime $timeThreshold)
              (empty)                   
              (let* (
                      ($w (* $elapsedTime $multiplier))  ; Compute weight factor w.
                    )
                ((collectRentRecursive $targetSet $w)  ; Start recursive rent collection.
                (setLastUpdate (timeTime)))
                 ; Update last collection timestamp.
              )
          )
      )
   )
)

; Function: collectRentRecursive
; Description: Recursively applies rent to each atom in the given list.
; Parameters:
;   - $atoms: The list of atoms to process.
;   - $w: Weight factor based on elapsed time.
; Returns: None.
(: collectRentRecursive (-> Symbol Number empty))
(= (collectRentRecursive $atoms $w)
   (if (== $atoms ())  
       (empty)  ; Base case: If no more atoms, stop recursion.
       (let* (
               ($head (car-atom $atoms))  ; Get the first atom.
               ($tail (cdr-atom $atoms))  ; Get the remaining atoms.
             )
         ((applyRent $head $w)  ; Apply rent to the current atom.
         (collectRentRecursive $tail $w))  ; Recur for the remaining atoms.
       )
   )
)

; Function: applyRent
; Description: Deducts STI and LTI rent from an atom, ensuring it does not go below zero.
; Parameters:
;   - $atom: The atom undergoing rent collection.
;   - $w: Weight factor based on elapsed time.
; Returns: None.
(: applyRent (-> Atom Number empty))
(= (applyRent $atom $w)
   (let* (
           ($sti (getSTI $atom))
           ($lti (getLTI $atom))
           ($stiAtomRent (getAttentionParam StartingAtomStiRent))
           ($ltiAtomRent (getAttentionParam StartingAtomLtiRent))
           ($stiRent (* (calculateStiRent $stiAtomRent) $w))  ; Scale STI rent by weight factor.
           ($ltiRent (* (calculateLtiRent $ltiAtomRent) $w))  ; Scale LTI rent by weight factor.
           ($minstiRent (min-atom ($stiRent $sti)))  ; Ensure STI rent does not exceed available STI.
           ($minltiRent (min-atom ($ltiRent $lti)))
           ($stiDiff (- $sti $minstiRent))
           ($ltiDiff (- $lti $minltiRent))
           ($atomVlti (getVLTI $atom))        ; Ensure LTI rent does not exceed available LTI.
         )
       (setAv $atom ($stiDiff $ltiDiff $atomVlti))  ; Update atom's values.
   )
)

; Function: setLastUpdate
; Description: Updates the last recorded timestamp for rent collection.
; Parameters:
;   - $time: The new timestamp to store.
; Returns: None.
(: setLastUpdate (-> Number empty))
(= (setLastUpdate $time)
     ((match  &self  (lastUpdate $x)
      (let ()
           (remove-atom &self (lastUpdate $x))
           (add-atom &self  (lastUpdate $time))
      )
  ))
)

; Function: setFirstTime
; Description: Sets the firstTime flag to false after initialization.
; Parameters:
;   - $flag: Boolean value to update firstTime.
; Returns: None.
(: setFirstTime (-> Boolean empty))
(= (setFirstTime $flag)
     ((match &self (firstTime $x)
       (let ()
          (remove-atom &self (firstTime $x))
          (add-atom &self (firstTime $flag))
       )
     ))
)