; !(register-module! ../../metta-attention)
; !(import! &self metta-attention:attention-bank:bank:atom-bins:get-min-max-content)
; !(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
; !(import! &self metta-attention:attention-bank:bank:stochastic-importance-diffusion:stochastic-importance-diffusion)

; Function: selectTargets
; Description: Selects a random atom that is not in attentional focus.
; Returns: A single atom or an empty result if none is found.
(: selectTargets (-> Atom))
(= (selectTargets)
    (collapse (getRandomAtomNotInAF))
    
      
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
       (empty)  
       
       (let* (
               ($target (car-atom $newtarget))
               ($sti (getSTI $target))
               ($lti (getLTI $target))
               ($elapsedTime (elapsedTime $target))
               ($stiAtomRent (getAttentionParam StartingAtomStiRent))
               ($ltiAtomRent (getAttentionParam StartingAtomLtiRent))
               ($scaledSTIRent (* $stiAtomRent $elapsedTime))
               ($scaledLTIRent (* $ltiAtomRent  $elapsedTime))
               ($stistartRent (calculateStiRent $scaledSTIRent))
               ($ltistartRent (calculateLtiRent $scaledLTIRent))
               ($stiRent (min-atom ($stistartRent $sti)))
               ($ltiRent (min-atom ($ltistartRent $lti)))
               ($newsti (- $sti $stiRent))
               ($newlti (- $lti $ltiRent))
               ($newvlti (getVLTI $target))
               

             )
            ((setAv $target ($newsti $newlti $newvlti))
            (updateImportance (AtomBinInfo)  $target $sti $newsti)
            (updateBin $target))
       )
   )
)


(= (WARentCollectionAgent-Run) 
   (let $res (selectTargets)
    (if (== $res ())
    (empty)
    (collectRent $res)
    
    
    )
)
)

