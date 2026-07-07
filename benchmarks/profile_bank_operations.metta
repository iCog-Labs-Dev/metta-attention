!(import! &self lib/lib_he)
!(import! &self lib/lib_spaces)
!(import! &self ../attention/AttentionParam)
!(import! &self ../attention-bank/utilities/helper-functions)
!(import! &self ../attention-bank/attention-value/getter-and-setter)
!(import! &self ../attention-bank/bank/importance-index/importance-index)
!(import! &self ../attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../attention-bank/utilities/recentVal)
!(import! &self ../attention-bank/bank/attention-bank)


; Sample spread of atoms with varying STI to populate bins
!(setAv atom-a (2.0 2.0 0.0))
!(setAv atom-b (10.0 10.0 0.0))
!(setAv atom-c (25.0 25.0 0.0))
!(setAv atom-d (50.0 50.0 0.0))
!(setAv atom-e (100.0 100.0 0.0))
!(setAv atom-f (200.0 200.0 0.0))
!(setAv atom-g (300.0 300.0 0.0))
!(setAv atom-h (500.0 500.0 0.0))
!(setAv atom-i (800.0 800.0 0.0))
!(setAv atom-j (1000.0 1000.0 0.0))

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

(= (profileSetGetAv $n)
   (if (<= $n 0)
       (getAv profile-sv-atom)
       (let* (
               ($_ (setAv profile-sv-atom ($n $n 0.0)))
               ($_ (getAv profile-sv-atom))
             )
             (profileSetGetAv (- $n 1)))
   )
)

(= (profileGetStiLti $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (getSti atom-f))
               ($_ (getLti atom-f))
               ($_ (getVlti atom-f))
             )
             (profileGetStiLti (- $n 1)))
   )
)

(= (profileUpdateAf $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (updateAf af-atom-1 (+ 100.0 $n)))
               ($_ (updateAf af-atom-2 (+ 200.0 $n)))
             )
             (profileUpdateAf (- $n 1)))
   )
)
!(setAv af-atom-1 (150.0 150.0 0.0))
!(setAv af-atom-2 (250.0 250.0 0.0))

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


(= (profileNormZeroOne $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (getNormalisedZeroToOneSTI (getSti atom-f) True True))
               ($_ (getNormalisedZeroToOneSTI (getSti atom-c) False False))
             )
             (profileNormZeroOne (- $n 1)))
   )
)

(= (profileNormSTI $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (getNormalisedSTI (getSti atom-f)))
               ($_ (getNormalisedSTI (getSti atom-c) True True))
             )
             (profileNormSTI (- $n 1)))
   )
)

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

(= (profileBinOps $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (getAtomsByBin 2.0))
               ($_ (getSize 2.0))
               ($_ (getAllAtomsWithBins))
             )
             (profileBinOps (- $n 1)))
   )
)

(= (profileSort $n)
   (if (<= $n 0)
       0
       (let $_ (sortAtomsDescending (atom-a atom-b atom-c atom-d atom-e atom-f atom-g atom-h atom-i atom-j) getSti)
            (profileSort (- $n 1)))
   )
)

!(profileImportanceBin 5000)
!(profileSetGetAv 1000)
!(profileGetStiLti 5000)
!(profileUpdateAf 500)
!(profileGetHandleSet 500)
!(profileNormZeroOne 5000)
!(profileNormSTI 2000)
!(profileFindGroup 5000)
!(profileBinOps 1000)
!(profileSort 500)

