; Function: selectTargets
; Description: Selects a random atom that is not in attentional focus.
; Returns: A single atom or an empty result if none is found.
(: selectTargets (-> Atom))
(= (selectTargets)
   (let $randomAtom (collapse (getRandomAtomNotInAF))
    
      $randomAtom  ; Return atom if found, else return empty.
   )
)

; Function: collectRent
; Description: Collects rent from the selected target atom.
;              It scales the rent based on elapsed time since last update.
; Parameters:
;   - $target: The selected atom.
; Returns: None.
(: collectRent (-> Atom empty))
(= (collectRent $newtarget)
   (if (== $newtarget ())
       (empty)  ; If no target, do nothing.
       (let* (
               ($target (car-atom $newtarget))
               ($sti (getSTI $target))
               ($lti (getLTI $target))
               ($elapsedTime (elapsedTime $target))
               ($stiAtomRent (getAttentionParam StartingAtomStiRent)); Get last update time.
               ($ltiAtomRent (getAttentionParam StartingAtomLtiRent))
               ($scaledSTIRent (* $stiAtomRent $elapsedTime))  ; Scale rent by elapsed time.
              ($scaledLTIRent (* $ltiAtomRent  $elapsedTime))
               ($stistartRent (calculateStiRent $scaledSTIRent))
               ($ltistartRent (calculateLtiRent $scaledLTIRent))
               ($stiRent (min-atom ($stistartRent $sti)))  ; Ensure rent does not exceed available STI.
               ($ltiRent (min-atom ($ltistartRent $lti)))
               ($newsti (- $sti $stiRent))
               ($newlti (- $lti $ltiRent))
               ($newvlti (getVLTI $target))
             )
            (setAv $target ($newsti $newlti $newvlti))
       )
   )
)




