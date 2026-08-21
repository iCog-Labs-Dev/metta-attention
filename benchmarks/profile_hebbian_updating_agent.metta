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
!(import! &self ../attention/HebbianUpdatingAgent/HebbianUpdatingAgent)

; Attention parameters 
!(updateAttentionParam FUNDS_STI     100000.0)
!(updateAttentionParam FUNDS_LTI     100000.0)
!(updateAttentionParam TARGET_STI    5000.0)
!(updateAttentionParam TARGET_LTI    5000.0)
!(updateAttentionParam MAX_AF_SIZE   20.0)
!(updateAttentionParam TC_DECAY_RATE 0.1)
!(updateAttentionParam DEFAULT_K     800)

; Seed atoms 
!(setAv hu-atom-a (900.0 800.0 0.0))
!(setAv hu-atom-b (850.0 750.0 0.0))
!(setAv hu-atom-c (800.0 700.0 0.0))
!(setAv hu-atom-d (750.0 650.0 0.0))

; Hebbian links 
; These are the links getAllIncomingSetsForHUAgent and updateHebbianLinks query.
!(setStv (ASYMMETRIC_HEBBIAN_LINK hu-atom-a hu-atom-b) (0.8 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK hu-atom-a hu-atom-c) (0.6 0.7))
!(setStv (ASYMMETRIC_HEBBIAN_LINK hu-atom-b hu-atom-c) (0.7 0.8))
!(setStv (ASYMMETRIC_HEBBIAN_LINK hu-atom-c hu-atom-d) (0.5 0.6))

; getAllIncomingSetsForHUAgent
(= (profileGetAllIncomingSets $n)
   (if (<= $n 0)
       0
       (let* (($_ (collapse (getAllIncomingSetsForHUAgent hu-atom-a (TypeSpace) ASYMMETRIC_HEBBIAN_LINK))))
             (profileGetAllIncomingSets (- $n 1))))
)

; getOutGoingAtoms
(= (profileGetOutGoingAtoms $n)
   (if (<= $n 0)
       0
       (let* (($_ (getOutGoingAtoms (ASYMMETRIC_HEBBIAN_LINK hu-atom-a hu-atom-b))))
             (profileGetOutGoingAtoms (- $n 1))))
)

; targetConjunction
(= (profileTargetConjunction $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (targetConjunction (hu-atom-a hu-atom-b)))
               ($_ (targetConjunction (hu-atom-c hu-atom-d)))
             )
             (profileTargetConjunction (- $n 1))))
)

; mergeCalculation -- PLN_BOOK_REVISION
(= (profileMergeCalculation $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (mergeCalculation (0.6 0.1) (0.5 0.9) PLN_BOOK_REVISION))
               ($_ (mergeCalculation (0.3 0.5) (0.7 0.8) PLN_BOOK_REVISION))
             )
             (profileMergeCalculation (- $n 1))))
)

; higherConfidenceMerge
(= (profileHigherConfidenceMerge $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (higherConfidenceMerge (0.6 0.9) (0.4 0.7)))
               ($_ (higherConfidenceMerge (0.2 0.3) (0.8 0.95)))
             )
             (profileHigherConfidenceMerge (- $n 1))))
)

; updateHebbianLinks
(= (profileUpdateHebbianLinks $n)
   (if (<= $n 0)
       0
       (let* (($_ (updateHebbianLinks hu-atom-a (TypeSpace))))
             (profileUpdateHebbianLinks (- $n 1))))
)

; bachUpdateHeb
(= (profileBachUpdateHeb $n)
   (if (<= $n 0)
       0
       (let* (($_ (bachUpdateHeb hu-atom-a ((ASYMMETRIC_HEBBIAN_LINK hu-atom-a hu-atom-b) (TypeSpace)))))
             (profileBachUpdateHeb (- $n 1))))
)

; HebbianUpdatingAgent-Run
(= (profileHebbianUpdatingAgentRun $n)
   (if (<= $n 0)
       0
       (let* (($_ (HebbianUpdatingAgent-Run (TypeSpace))))
             (profileHebbianUpdatingAgentRun (- $n 1))))
)

!(profileGetAllIncomingSets         500)
!(profileGetOutGoingAtoms          5000)
!(profileTargetConjunction         2000)
!(profileMergeCalculation          2000)
!(profileHigherConfidenceMerge     5000)
!(profileUpdateHebbianLinks         500)
!(profileBachUpdateHeb              500)
!(profileHebbianUpdatingAgentRun    100)

