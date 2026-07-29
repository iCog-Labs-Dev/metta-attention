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
!(import! &self ../attention/HebbianCreationAgent/HebbianCreationAgent)

; Attention parameters 
!(updateAttentionParam FUNDS_STI    100000.0)
!(updateAttentionParam FUNDS_LTI    100000.0)
!(updateAttentionParam TARGET_STI   5000.0)
!(updateAttentionParam TARGET_LTI   5000.0)
!(updateAttentionParam MAX_AF_SIZE  20.0)

; Seed atoms 
; High-STI atoms 
!(setAv hc-atom-a (900.0 800.0 0.0))
!(setAv hc-atom-b (850.0 750.0 0.0))
!(setAv hc-atom-c (800.0 700.0 0.0))
!(setAv hc-atom-d (750.0 650.0 0.0))
!(setAv hc-atom-e (700.0 600.0 0.0))

; Low-STI atoms
!(setAv hc-atom-x (50.0 50.0 0.0))
!(setAv hc-atom-y (40.0 40.0 0.0))
!(setAv hc-atom-z (30.0 30.0 0.0))

; Pre-existing Hebbian links
!(setStv (ASYMMETRIC_HEBBIAN_LINK hc-atom-a hc-atom-b) (0.8 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK hc-atom-a hc-atom-c) (0.6 0.7))
!(setStv (ASYMMETRIC_HEBBIAN_LINK hc-atom-b hc-atom-c) (0.7 0.8))
!(setStv (ASYMMETRIC_HEBBIAN_LINK hc-atom-c hc-atom-d) (0.5 0.6))

; getTargetNeighbors
(= (profileGetTargetNeighbors $n)
   (if (<= $n 0)
       0
       (let* (($_ (getTargetNeighbors hc-atom-a ASYMMETRIC_HEBBIAN_LINK (TypeSpace))))
             (profileGetTargetNeighbors (- $n 1))))
)

; addHebbian
!(setAv hca-src-scratch (600.0 600.0 0.0))
!(setAv hca-tgt-scratch (400.0 400.0 0.0))
(= (profileAddHebbian $n)
   (if (<= $n 0)
       0
       (let* (($_ (addHebbian hca-src-scratch hca-tgt-scratch)))
             (profileAddHebbian (- $n 1))))
)

; addFromOutSideAF
;(= (profileAddFromOutSideAF $n)
;   (if (<= $n 0)
;       0
;       (let* (($_ (addFromOutSideAF hc-atom-a 1 (getAfAtoms))))
;             (profileAddFromOutSideAF (- $n 1))))
;)

(= (profileAddFromOutSideAF $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (addFromOutSideAF hc-atom-a 1 (getAfAtoms)))
               ($_ (collapse (match (TypeSpace)
                               ((ASYMMETRIC_HEBBIAN_LINK hc-atom-a $t) $val)
                               (if (and (not (== $t hc-atom-b)) (not (== $t hc-atom-c)))
                                   (remove-atom &typeSpace ((ASYMMETRIC_HEBBIAN_LINK hc-atom-a $t) $val))
                                   (empty)
                               ))))
             )
             (profileAddFromOutSideAF (- $n 1))))
)

; generateRandom
(= (profileGenerateRandom $n)
   (if (<= $n 0)
       0
       (let* (($_ (generateRandom 2 (getAfAtoms))))
             (profileGenerateRandom (- $n 1))))
)

; setDifference
(= (profileSetDifference $n)
   (if (<= $n 0)
       0
       (let* (
               ($existing (getTargetNeighbors hc-atom-a ASYMMETRIC_HEBBIAN_LINK (TypeSpace)))
               ($_ (setDifference $existing))
             )
             (profileSetDifference (- $n 1))))
)

; getRandomAtomInAF
(= (profileGetRandomAtomInAF $n)
   (if (<= $n 0)
       0
       (let* (($_ (getRandomAtomInAF (getAfAtoms))))
             (profileGetRandomAtomInAF (- $n 1))))
)

; getRandomAtomNotInAF
(= (profileGetRandomAtomNotInAF $n)
   (if (<= $n 0)
       0
       (let* (($_ (getRandomAtomNotInAF (getAfAtoms))))
             (profileGetRandomAtomNotInAF (- $n 1))))
)

; getSourceAtom
(= (profileGetSourceAtom $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (getSourceAtom (ASYMMETRIC_HEBBIAN_LINK hc-atom-a hc-atom-b)))
               ($_ (getSourceAtom (ASYMMETRIC_HEBBIAN_LINK hc-atom-b hc-atom-c)))
             )
             (profileGetSourceAtom (- $n 1))))
)

; removeLinkRecursively
(= (profileRemoveLinkRecursively $n)
   (if (<= $n 0)
       0
       (let* (($_ (removeLinkRecursively 1 (size-atom (getAfAtoms)) (getAfAtoms))))
             (profileRemoveLinkRecursively (- $n 1))))
)

; HebbianCreationAgent-Run
(= (profileHebbianCreationAgentRun $n)
   (if (<= $n 0)
       0
       (let* (($_ (HebbianCreationAgent-Run (TypeSpace))))
             (profileHebbianCreationAgentRun (- $n 1))))
)

!(profileGetTargetNeighbors         500)
!(profileAddHebbian                1000)
;!(profileAddFromOutSideAF           500)  ;taking long 
;!(profileGenerateRandom             500)  ;taking long 
!(profileSetDifference              500)
!(profileGetRandomAtomInAF         2000)
!(profileGetRandomAtomNotInAF       500)
!(profileGetSourceAtom             2000)  
!(profileRemoveLinkRecursively      200)
!(profileHebbianCreationAgentRun    100)

