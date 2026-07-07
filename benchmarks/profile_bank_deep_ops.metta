!(import! &self lib/lib_he)
!(import! &self lib/lib_spaces)
!(import! &self ../attention/AttentionParam)
!(import! &self ../attention-bank/utilities/helper-functions)
!(import! &self ../attention-bank/attention-value/getter-and-setter)
!(import! &self ../attention-bank/bank/importance-index/importance-index)
!(import! &self ../attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../attention-bank/utilities/recentVal)
!(import! &self ../attention-bank/bank/attention-bank)
!(import! &self ../attention-bank/bank/stochastic-importance-diffusion/stochastic-importance-diffusion)

!(setAv node-1 (100.0 100.0 0.0))
!(setAv node-2 (500.0 500.0 0.0))
!(setAv node-3 (250.0 250.0 0.0))
!(add-atom &typeSpace ((MemberLink node-1 node-2) ((AV 150.0 150.0 0) (Bin 15))))
!(add-atom &typeSpace ((MemberLink node-2 node-3) ((AV 350.0 350.0 0) (Bin 35))))

(= (profileUpdateAttentionParam $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (updateAttentionParam FUNDS_STI $n))
             )
             (profileUpdateAttentionParam (- $n 1)))
   )
)


(= (profileAttentionValueChanged $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (attentionValueChanged node-1 (+ 100 $n) (+ 100 $n) (+ 50 $n)))
             )
             (profileAttentionValueChanged (- $n 1)))
   )
)


; (= (profileUpdateBin $n)
;   (if (<= $n 0)
;       0
;       (let* (
;               ($_ (updateBin node-1))
;               ($_ (updateBin node-2))
;             )
;             (profileUpdateBin (- $n 1)))
;   )
; )
; Note: this will only run correctly if Python/janus is configured.
; !(profileUpdateBin 500)

(= (profileDiffusedValue $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (diffusedValue node-1 0.05))
               ($_ (diffusedValue node-2 0.05))
             )
             (profileDiffusedValue (- $n 1)))
   )
)

(= (profileComputeExtremes $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (computeMinSTI))
               ($_ (computeMaxSTI))
             )
             (profileComputeExtremes (- $n 1)))
   )
)

(= (profileGlobalIncomingSet $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (globalIncomingSetByType node-2 MemberLink))
             )
             (profileGlobalIncomingSet (- $n 1)))
   )
)
!(profileGlobalIncomingSet 1000)

(= (profileSetStiLti $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (setSti node-3 $n))
               ($_ (setLti node-3 $n))
             )
             (profileSetStiLti (- $n 1)))
   )
)
!(profileUpdateAttentionParam 5000)
!(profileAttentionValueChanged 1000)
!(profileDiffusedValue 1000)
!(profileComputeExtremes 200)

!(profileSetStiLti 1000)
