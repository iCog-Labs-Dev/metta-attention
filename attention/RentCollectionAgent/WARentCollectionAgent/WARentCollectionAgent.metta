; Function: selectTargets
; Description: Selects a random atom that is not in attentional focus.
; Returns: A single atom or an empty result if none is found.
(: selectTargets (-> Atom))
(= (selectTargets)
    (getRandomAtomNotInAF)
)

; Function: collectRent
; Description: Collects rent from the selected target atom.
;              It scales the rent based on elapsed time since last update.
; Parameters:
;   - $target: The selected atom.
; Returns: None.
;(: collectRent (-> Atom empty))
(= (collectRent $target)
   (if (== $target ())
        (empty)
        (let*
            (
               
               ($sti (getSti $target))
               ($lti (getLti $target))
               ($elapsedTime (elapsedTime $target))
               ($stiAtomRent (getAttentionParam StartingAtomStiRent))
                ($ltiAtomRent (getAttentionParam StartingAtomLtiRent))
               ($scaledSTIRent (* $stiAtomRent $elapsedTime))
               ($scaledLTIRent (* $ltiAtomRent  $elapsedTime))
               ($updateScaledSTIRent (updateAttentionParam StartingAtomStiRent $scaledSTIRent))
               ($updateScaledLTIRent (updateAttentionParam StartingAtomLtiRent $scaledLTIRent))
               ($stistartRent (calculateStiRent $scaledSTIRent))
               ($ltistartRent (calculateLtiRent $scaledLTIRent))
               ($stiRent (min-atom ($stistartRent $sti)))
               ($ltiRent (min-atom ($ltistartRent $lti)))
               ($newsti (- $sti $stiRent))
               ($newlti (- $lti $ltiRent))
               ($newvlti (getVlti $target))
            )
            (

               (setAv $target ($newsti $newlti $newvlti))

               
            )
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
