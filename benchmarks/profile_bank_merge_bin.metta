!(import! &self lib/lib_he)
!(import! &self lib/lib_spaces)
!(import! &self ../attention/AttentionParam)
!(import! &self ../attention-bank/utilities/helper-functions)
!(import! &self ../attention-bank/attention-value/getter-and-setter)
!(import! &self ../attention-bank/bank/importance-index/importance-index)
!(import! &self ../attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../attention-bank/utilities/recentVal)
!(import! &self ../attention-bank/bank/attention-bank)
!(import! &self ../attention-bank/bank/stochastic-importance-diffusion/merge-bin)

; seed bins into spaces 
!(add-atom &past-space (1 ((count 10) (index 1) (Size 100))))
!(add-atom &past-space (2 ((count 20) (index 2) (Size 200))))
!(add-atom &past-space (3 ((count 30) (index 3) (Size 300))))

!(add-atom &recent-space (1 ((count 5) 1 100)))
!(add-atom &recent-space (2 ((count 10) 2 200)))
!(add-atom &recent-space (3 ((count 15) 3 300)))

(= (profileMergeBin $n)
   (if (<= $n 0)
       0
       (let* (
               ; Get current contents of recent-space to pass as argument
               ($recent (collapse (match &recent-space ($index ( (count $count) $indexVal $sizeVal)) ($index ( (count $count) $indexVal $sizeVal)))))
               ($_ (mergeBin $recent 0.5))
             )
             (profileMergeBin (- $n 1)))
   )
)
!(profileMergeBin 500)
