!(import! &self lib/lib_he)
!(import! &self lib/lib_spaces)
!(import! &self ../attention/AttentionParam)
!(import! &self ../attention-bank/utilities/helper-functions)
!(import! &self ../attention-bank/utilities/recentVal)
!(import! &self ../attention-bank/attention-value/getter-and-setter)
!(import! &self ../attention-bank/bank/importance-index/importance-index)
!(import! &self ../attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../attention-bank/bank/attention-bank)
!(import! &self ../attention/ForgettingAgent/ForgettingAgent)

; Attention parameters
!(updateAttentionParam FUNDS_STI        100000.0)
!(updateAttentionParam FUNDS_LTI        100000.0)
!(updateAttentionParam TARGET_STI       5000.0)
!(updateAttentionParam TARGET_LTI       5000.0)
!(updateAttentionParam MAX_AF_SIZE      20.0)
!(updateAttentionParam FORGET_THRESHOLD 0.1)
!(updateAttentionParam MAX_SIZE         40)
!(updateAttentionParam ACC_DIV_SIZE     5)

; Seed atoms
; High-STI atoms (inside AF, high LTI -- should NOT be forgotten)
!(setAv fa-atom-a (900.0  800.0  0.0))
!(setAv fa-atom-b (850.0  750.0  0.0))
!(setAv fa-atom-c (800.0  700.0  0.0))

; Mid-STI atoms (borderline)
!(setAv fa-atom-f (400.0  200.0  0.0))
!(setAv fa-atom-g (350.0  180.0  0.0))
!(setAv fa-atom-h (300.0  150.0  0.0))

; Low-STI / low-LTI atoms (forgettable candidates, VLTI=0 so eligible)
!(setAv fa-atom-i  (50.0   0.04  0.0))
!(setAv fa-atom-j  (40.0   0.03  0.0))
!(setAv fa-atom-k  (30.0   0.02  0.0))
!(setAv fa-atom-l  (20.0   0.01  0.0))
!(setAv fa-atom-m  (10.0   0.005 0.0))

; Hebbian links (gives atoms an incoming set for globalIncomingSetByType)
!(setStv (ASYMMETRIC_HEBBIAN_LINK fa-atom-a fa-atom-b) (0.8 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK fa-atom-b fa-atom-c) (0.7 0.8))
!(setStv (ASYMMETRIC_HEBBIAN_LINK fa-atom-f fa-atom-g) (0.5 0.5))
!(setStv (ASYMMETRIC_HEBBIAN_LINK fa-atom-g fa-atom-h) (0.5 0.5))

; Helper: representative mixed candidate list
(= (forgettingCandidates)
    (fa-atom-i fa-atom-j fa-atom-k fa-atom-l fa-atom-m
     fa-atom-f fa-atom-g fa-atom-h fa-atom-a fa-atom-b)
)

; filterByLti
(= (profileFilterByLti $n)
   (if (<= $n 0)
       0
       (let* (($_ (filterByLti (forgettingCandidates) 0.1)))
             (profileFilterByLti (- $n 1))))
)

; lessThanLtiThenTV
(= (profileLessThanLtiThenTV $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (lessThanLtiThenTV fa-atom-i fa-atom-j))
               ($_ (lessThanLtiThenTV fa-atom-a fa-atom-b))
             )
             (profileLessThanLtiThenTV (- $n 1))))
)

; greaterThanLtiThenTV
(= (profileGreaterThanLtiThenTV $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (greaterThanLtiThenTV fa-atom-i fa-atom-j))
               ($_ (greaterThanLtiThenTV fa-atom-a fa-atom-b))
             )
             (profileGreaterThanLtiThenTV (- $n 1))))
)

; ForgettingLtiThenTVAscendingSort
(= (profileForgettingSort $n)
   (if (<= $n 0)
       0
       (let* (($_ (ForgettingLtiThenTVAscendingSort (forgettingCandidates))))
             (profileForgettingSort (- $n 1))))
)

; atomBelowForgetThreshold
(= (profileAtomBelowForgetThreshold $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (atomBelowForgetThreshold fa-atom-i 5.0 0.0))
               ($_ (atomBelowForgetThreshold fa-atom-a 5.0 0.0))
             )
             (profileAtomBelowForgetThreshold (- $n 1))))
)

; refundAV
!(setAv fa-refund-scratch (50.0 0.04 0.0))
(= (profileRefundAV $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (refundAV fa-refund-scratch))
               ; Restore so the next iteration has actual work to do
               ($_ (setAv fa-refund-scratch (50.0 0.04 0.0)))
             )
             (profileRefundAV (- $n 1))))
)

; globalIncomingSetByType
(= (profileGlobalIncomingByType $n)
   (if (<= $n 0)
       0
       (let* (($_ (globalIncomingSetByType fa-atom-b ASYMMETRIC_HEBBIAN_LINK)))
             (profileGlobalIncomingByType (- $n 1))))
)

; checkThenRemoveAtom
(= (profileCheckThenRemoveAtom $n)
   (if (<= $n 0)
       0
       (let* (
               ($candidates (ForgettingLtiThenTVAscendingSort (forgettingCandidates)))
               ($_ (checkThenRemoveAtom $candidates 2 0))
             )
             (profileCheckThenRemoveAtom (- $n 1))))
)

; forgettingAgent-Run
(= (profileForgettingAgentRun $n)
   (if (<= $n 0)
       0
       (let* (($_ (forgettingAgent-Run (TypeSpace))))
             (profileForgettingAgentRun (- $n 1))))
)

!(profileFilterByLti               1000)
!(profileLessThanLtiThenTV         5000)
!(profileGreaterThanLtiThenTV      5000)
!(profileForgettingSort             500)
!(profileAtomBelowForgetThreshold  5000)
!(profileRefundAV                   500)
!(profileGlobalIncomingByType      1000)
!(profileCheckThenRemoveAtom        200)
!(profileForgettingAgentRun         100)

