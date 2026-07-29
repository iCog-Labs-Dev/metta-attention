!(import! &self lib/lib_he)
!(import! &self lib/lib_spaces)
!(import! &self ../attention/AttentionParam)
!(import! &self ../attention/baching)
!(import! &self ../attention-bank/utilities/helper-functions)
!(import! &self ../attention-bank/utilities/recentVal)
!(import! &self ../attention-bank/attention-value/getter-and-setter)
!(import! &self ../attention-bank/bank/importance-index/importance-index)
!(import! &self ../attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../attention-bank/bank/attention-bank)
!(import! &self ../attention-bank/bank/stochastic-importance-diffusion/stochastic-importance-diffusion)
!(import! &self ../attention/Neighbors)
!(import! &self ../attention/RentCollectionAgent/RentCollectionBaseAgent/RentCollectionBaseAgent)
!(import! &self ../attention/RentCollectionAgent/AFRentCollectionAgent/AFRentCollectionAgent)
!(import! &self ../attention/RentCollectionAgent/WARentCollectionAgent/WARentCollectionAgent)

; Attention parameters 
!(updateAttentionParam FUNDS_STI               100000.0)
!(updateAttentionParam FUNDS_LTI               100000.0)
!(updateAttentionParam TARGET_STI              5000.0)
!(updateAttentionParam TARGET_LTI              5000.0)
!(updateAttentionParam MAX_AF_SIZE             10.0)
!(updateAttentionParam STI_FUNDS_BUFFER        10000.0)
!(updateAttentionParam LTI_FUNDS_BUFFER        10000.0)
!(updateAttentionParam StartingAtomStiRent     1.0)
!(updateAttentionParam StartingAtomLtiRent     1.0)
!(updateAttentionParam AFRentFrequency         5.0)

; Seed atoms 
; High-STI atoms, serve as AF rent targets
!(stimulate rc-atom-a 3000.0)
!(stimulate rc-atom-b 2500.0)
!(stimulate rc-atom-c 2000.0)
!(stimulate rc-atom-d 1500.0)
!(stimulate rc-atom-e 1000.0)

; Low-STI atoms, serve as WA rent targets
!(stimulate rc-atom-f  290.0)
!(stimulate rc-atom-g  200.0)
!(stimulate rc-atom-h  100.0)
!(stimulate (rc-link-ab rc-atom-a rc-atom-b)  50.0)
!(stimulate (rc-link-cd rc-atom-c rc-atom-d)   5.0)

; =============================================================================
; RentCollectionBaseAgent
; =============================================================================

; calculateStiRent
(= (profileCalculateStiRent $n)
   (if (<= $n 0)
       0
       (let* (
               ($base (getAttentionParam StartingAtomStiRent))
               ($_ (calculateStiRent $base))
               ; Variant: scaled-up rent value
               ($_ (calculateStiRent (* $base 10.0)))
             )
             (profileCalculateStiRent (- $n 1))))
)

; calculateLtiRent
(= (profileCalculateLtiRent $n)
   (if (<= $n 0)
       0
       (let* (
               ($base (getAttentionParam StartingAtomLtiRent))
               ($_ (calculateLtiRent $base))
               ($_ (calculateLtiRent (* $base 10.0)))
             )
             (profileCalculateLtiRent (- $n 1))))
)

; =============================================================================
; AFRentCollectionAgent
; =============================================================================

; applyRent
(= (profileApplyRent $n)
   (if (<= $n 0)
       0
       (let* (
               ; weight = 1.0 simulates one full rent period
               ($_ (applyRent 1.0 rc-atom-a))
               ($_ (applyRent 1.0 rc-atom-b))
               ($_ (applyRent 0.5 (rc-link-ab rc-atom-a rc-atom-b)))
               ; Restore atom values so each iteration has real work to do
               ($_ (stimulate rc-atom-a 1.0))
               ($_ (stimulate rc-atom-b 1.0))
             )
             (profileApplyRent (- $n 1))))
)

; collectAFRent
(= (profileCollectAFRent $n)
   (if (<= $n 0)
       0
       (let* (
               ($targets (getAfAtoms))
               ($_ (collectAFRent $targets))
             )
             (profileCollectAFRent (- $n 1))))
)

; setLastUpdate
; Removes the current lastUpdate timestamp and inserts the new one.
(= (profileSetLastUpdate $n)
   (if (<= $n 0)
       0
       (let* (
               ($t (timeTime))
               ($_ (setLastUpdate $t))
             )
             (profileSetLastUpdate (- $n 1))))
)

; setFirstTime
; Flips the firstTime flag in the &timer space.
(= (profileSetFirstTime $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (setFirstTime False))
               ; Restore to True so subsequent iterations exercise the same path
               ($_ (setFirstTime True))
             )
             (profileSetFirstTime (- $n 1))))
)

; selectAFTargets
; Retrieves the current attentional-focus atom list.
(= (profileSelectAFTargets $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (selectAFTargets))
             )
             (profileSelectAFTargets (- $n 1))))
)

; AFRentCollectionAgent-run
; Full end-to-end AF rent cycle: mutex → getAfAtoms → collectAFRent →
; setLastUpdate.
(= (profileAFRentCollectionAgentRun $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (AFRentCollectionAgent-run))
             )
             (profileAFRentCollectionAgentRun (- $n 1))))
)

; =============================================================================
; WARentCollectionAgent
; =============================================================================

; selectTargets
; Returns getRandomAtomNotInAF — picks one atom from outside the AF.
(= (profileSelectTargets $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (selectTargets))
             )
             (profileSelectTargets (- $n 1))))
)

; collectRent
(= (profileCollectRentWA $n)
   (if (<= $n 0)
       0
       (let* (
               ; rc-atom-f is outside the AF — a valid WA target
               ($_ (collectRent rc-atom-f))
               ($_ (collectRent rc-atom-g))
               ; Restore STI so each iteration has real work to do
               ($_ (stimulate rc-atom-f 1.0))
               ($_ (stimulate rc-atom-g 1.0))
             )
             (profileCollectRentWA (- $n 1))))
)

; WARentCollectionAgent-Run
; Full end-to-end WA rent cycle: mutex → selectTargets → collectRent.
(= (profileWARentCollectionAgentRun $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (WARentCollectionAgent-Run))
             )
             (profileWARentCollectionAgentRun (- $n 1))))
)



; RentCollectionBaseAgent

!(profileCalculateStiRent              5000)
!(profileCalculateLtiRent              5000)

; AFRentCollectionAgent

!(profileSelectAFTargets               2000)
!(profileApplyRent                     1000)
!(profileSetLastUpdate                 2000)
!(profileSetFirstTime                  2000)
!(profileCollectAFRent                  200)
!(profileAFRentCollectionAgentRun       100)

; WARentCollectionAgent

!(profileSelectTargets                 2000)
!(profileCollectRentWA                  500)
!(profileWARentCollectionAgentRun       200)
