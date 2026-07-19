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
!(setAv gs-atom-a (2.0   2.0   0.0))
!(setAv gs-atom-b (10.0  10.0  0.0))
!(setAv gs-atom-c (25.0  25.0  0.0))
!(setAv gs-atom-d (50.0  50.0  0.0))
!(setAv gs-atom-e (100.0 100.0 0.0))
!(setAv gs-atom-f (200.0 200.0 0.0))
!(setAv gs-atom-g (300.0 300.0 0.0))
!(setAv gs-atom-h (500.0 500.0 0.0))
!(setAv gs-atom-i (800.0 800.0 0.0))
!(setAv gs-atom-j (1000.0 1000.0 0.0))
!(add-atom &typeSpace ((MemberLink gs-atom-a gs-atom-b) ((AV 150.0 150.0 0) (Bin 15))))
!(add-atom &typeSpace ((MemberLink gs-atom-b gs-atom-c) ((AV 350.0 350.0 0) (Bin 35))))

; setAv
(= (profileSetAv $n)
   (if (<= $n 0)
       (getAv gs-profile-atom)
       (let* (
               ($_ (setAv gs-profile-atom ($n $n 0.0)))
             )
             (profileSetAv (- $n 1)))
   )
)

; getAv
(= (profileGetAv $n)
   (if (<= $n 0)
       (getAv gs-profile-atom)
       (let* (
               ($_ (getAv gs-profile-atom))
             )
             (profileGetAv (- $n 1)))
   )
)

; getSti
(= (profileGetSti $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (getSti gs-atom-f))
             )
             (profileGetSti (- $n 1)))
   )
)

; getLti
(= (profileGetLti $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (getLti gs-atom-f))
             )
             (profileGetLti (- $n 1)))
   )
)

; getVlti
(= (profileGetVlti $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (getVlti gs-atom-f))
             )
             (profileGetVlti (- $n 1)))
   )
)

; setSti
(= (profileSetSti $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (setSti gs-profile-atom $n))
             )
             (profileSetSti (- $n 1)))
   )
)

; setLti
(= (profileSetLti $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (setLti gs-profile-atom $n))
             )
             (profileSetLti (- $n 1)))
   )
)

; setVlti
(= (profileSetVlti $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (setVlti gs-profile-atom $n))
             )
             (profileSetVlti (- $n 1)))
   )
)

; attentionValueChanged
(= (profileAttentionValueChanged $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (attentionValueChanged gs-atom-f (+ 100.0 $n) (+ 100.0 $n) (+ 50.0 $n)))
             )
             (profileAttentionValueChanged (- $n 1)))
   )
)

; getAtomsInTypeSpace / countAtomsInTypeSpace
(= (profileGetAtomsInTypeSpace $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (getAtomsInTypeSpace))
             )
             (profileGetAtomsInTypeSpace (- $n 1)))
   )
)

(= (profileCountAtomsInTypeSpace $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (countAtomsInTypeSpace))
             )
             (profileCountAtomsInTypeSpace (- $n 1)))
   )
)

; getAtomsByBin / getSize / getAllAtomsWithBins
(= (profileGetAtomsByBin $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (getAtomsByBin 2.0))
             )
             (profileGetAtomsByBin (- $n 1)))
   )
)

(= (profileGetSize $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (getSize 2.0))
             )
             (profileGetSize (- $n 1)))
   )
)

(= (profileGetAllAtomsWithBins $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (getAllAtomsWithBins))
             )
             (profileGetAllAtomsWithBins (- $n 1)))
   )
)

; globalIncomingSetByType
(= (profileGlobalIncomingSetByType $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (globalIncomingSetByType gs-atom-b MemberLink))
             )
             (profileGlobalIncomingSetByType (- $n 1)))
   )
)

; computeMinSTI / computeMaxSTI
(= (profileComputeMinSTI $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (computeMinSTI))
             )
             (profileComputeMinSTI (- $n 1)))
   )
)

(= (profileComputeMaxSTI $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (computeMaxSTI))
             )
             (profileComputeMaxSTI (- $n 1)))
   )
)

; sortAtomsDescending
(= (profileSortAtomsDescending $n)
   (if (<= $n 0)
       0
       (let $_ (sortAtomsDescending (gs-atom-a gs-atom-b gs-atom-c gs-atom-d gs-atom-e gs-atom-f gs-atom-g gs-atom-h gs-atom-i gs-atom-j) getSti)
            (profileSortAtomsDescending (- $n 1)))
   )
)

!(profileSetAv 1000)
!(profileGetAv 1000)
!(profileGetSti 5000)
!(profileGetLti 5000)
!(profileGetVlti 5000)
!(profileSetSti 1000)
!(profileSetLti 1000)
!(profileSetVlti 1000)
!(profileAttentionValueChanged 1000)
!(profileGetAtomsInTypeSpace 500)
!(profileCountAtomsInTypeSpace 500)
!(profileGetAtomsByBin 1000)
!(profileGetSize 1000)
!(profileGetAllAtomsWithBins 500)
!(profileGlobalIncomingSetByType 1000)
!(profileComputeMinSTI 200)
!(profileComputeMaxSTI 200)
!(profileSortAtomsDescending 500)
