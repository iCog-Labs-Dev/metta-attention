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
!(setAv af-atom-a (150.0 150.0 0.0))
!(setAv af-atom-b (250.0 250.0 0.0))
!(setAv af-atom-c (400.0 400.0 0.0))
!(setAv af-atom-d (600.0 600.0 0.0))
!(setAv af-atom-e (900.0 900.0 0.0))

; updateAf
(= (profileUpdateAf $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (updateAf af-atom-a (+ 150.0 $n)))
               ($_ (updateAf af-atom-b (+ 250.0 $n)))
             )
             (profileUpdateAf (- $n 1)))
   )
)

; getAfAtoms
(= (profileGetAfAtoms $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (getAfAtoms))
             )
             (profileGetAfAtoms (- $n 1)))
   )
)

; isAtomInAf
(= (profileIsAtomInAf $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (isAtomInAf af-atom-a))
               ($_ (isAtomInAf af-atom-c))
             )
             (profileIsAtomInAf (- $n 1)))
   )
)

; updateMinAf
(= (profileUpdateMinAf $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (updateMinAf))
             )
             (profileUpdateMinAf (- $n 1)))
   )
)

; getRandomAtomNotInAF
(= (profileGetRandomAtomNotInAF $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (getRandomAtomNotInAF))
             )
             (profileGetRandomAtomNotInAF (- $n 1)))
   )
)

; getIncomingSetByType
!(add-atom &typeSpace ((MemberLink af-atom-a af-atom-b) ((AV 150.0 150.0 0) (Bin 15))))
!(add-atom &typeSpace ((MemberLink af-atom-b af-atom-c) ((AV 350.0 350.0 0) (Bin 35))))

(= (profileGetIncomingSetByType $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (getIncomingSetByType af-atom-b MemberLink ((MemberLink af-atom-a af-atom-b) (MemberLink af-atom-b af-atom-c))))
             )
             (profileGetIncomingSetByType (- $n 1)))
   )
)


!(profileUpdateAf 500)
!(profileGetAfAtoms 5000)
!(profileIsAtomInAf 5000)
!(profileUpdateMinAf 2000)
!(profileGetRandomAtomNotInAF 500)
!(profileGetIncomingSetByType 1000)
