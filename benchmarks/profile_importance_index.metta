!(import! &self lib/lib_he)
!(import! &self lib/lib_spaces)
!(import! &self ../attention/AttentionParam)
!(import! &self ../attention-bank/utilities/helper-functions)
!(import! &self ../attention-bank/attention-value/getter-and-setter)
!(import! &self ../attention-bank/bank/importance-index/importance-index)
!(import! &self ../attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../attention-bank/utilities/recentVal)
!(import! &self ../attention-bank/bank/attention-bank)


;  Seed atoms
!(setAv ii-atom-a (2.0   2.0   0.0))
!(setAv ii-atom-b (10.0  10.0  0.0))
!(setAv ii-atom-c (25.0  25.0  0.0))
!(setAv ii-atom-d (50.0  50.0  0.0))
!(setAv ii-atom-e (100.0 100.0 0.0))
!(setAv ii-atom-f (200.0 200.0 0.0))
!(setAv ii-atom-g (300.0 300.0 0.0))
!(setAv ii-atom-h (500.0 500.0 0.0))
!(setAv ii-atom-i (800.0 800.0 0.0))
!(setAv ii-atom-j (1000.0 1000.0 0.0))

; importanceBin
(= (profileImportanceBin $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (importanceBin $n))
               ($_ (importanceBin (* $n 2)))
               ($_ (importanceBin (* $n 3)))
             )
             (profileImportanceBin (- $n 1)))
   )
)

; findGroup
(= (profileFindGroup $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (findGroup $n))
               ($_ (findGroup (* $n 10)))
             )
             (profileFindGroup (- $n 1)))
   )
)

; getHandleSet
(= (profileGetHandleSet $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (getHandleSet 5.0 100.0))
               ($_ (getHandleSet 20.0 300.0))
             )
             (profileGetHandleSet (- $n 1)))
   )
)

; getContent
(= (profileGetContent $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (getContent 2.0 20.0))
               ($_ (getContent 10.0 50.0))
             )
             (profileGetContent (- $n 1)))
   )
)

; filterContents
(= (profileFilterContents $n)
   (if (<= $n 0)
       0
       (let* (
               ($contents (getContent 0.0 104.0))
               ($_ (filterContents $contents 5.0 100.0))
               ($_ (filterContents $contents 20.0 300.0))
             )
             (profileFilterContents (- $n 1)))
   )
)


; getNormalisedZeroToOneSTI
(= (profileNormZeroOne $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (getNormalisedZeroToOneSTI (getSti ii-atom-f) True True))
               ($_ (getNormalisedZeroToOneSTI (getSti ii-atom-c) False False))
             )
             (profileNormZeroOne (- $n 1)))
   )
)

; getNormalisedSTI (1-arg)
(= (profileNormSTI $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (getNormalisedSTI (getSti ii-atom-f)))
             )
             (profileNormSTI (- $n 1)))
   )
)

; getNormalisedSTI (3-arg, with clip)
(= (profileNormSTIClip $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (getNormalisedSTI (getSti ii-atom-f) True True))
               ($_ (getNormalisedSTI (getSti ii-atom-c) False False))
             )
             (profileNormSTIClip (- $n 1)))
   )
)


!(profileImportanceBin 5000)
!(profileFindGroup 5000)
!(profileGetHandleSet 500)
!(profileGetContent 500)
!(profileFilterContents 500)
!(profileNormZeroOne 5000)
!(profileNormSTI 2000)
!(profileNormSTIClip 2000)
