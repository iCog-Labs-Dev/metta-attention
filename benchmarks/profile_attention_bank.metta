!(import! &self lib/lib_he)
!(import! &self lib/lib_spaces)
!(import! &self ../attention/AttentionParam)
!(import! &self ../attention-bank/utilities/helper-functions)
!(import! &self ../attention-bank/attention-value/getter-and-setter)
!(import! &self ../attention-bank/bank/importance-index/importance-index)
!(import! &self ../attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../attention-bank/utilities/recentVal)
!(import! &self ../attention-bank/bank/attention-bank)

; This file is a profiling workload, not a correctness test.
; It repeats small attention-bank operations enough times for SWI-Prolog's
; profiler to show meaningful hotspots.

(= (profileCalculateSTIWage $n)
   (if (<= $n 0)
       0
       (let $_wage (calculateSTIWage)
            (profileCalculateSTIWage (- $n 1)))
   )
)

(= (profileCalculateLTIWage $n)
   (if (<= $n 0)
       0
       (let $_wage (calculateLTIWage)
            (profileCalculateLTIWage (- $n 1)))
   )
)

(= (profileStimulate $n)
   (if (<= $n 0)
       (getAv profile-atom)
       (let $_stim (stimulate profile-atom 1.0)
            (profileStimulate (- $n 1)))
   )
)

!(setAv profile-atom (200.0 200.0 0.0))
!(profileCalculateSTIWage 20000)
!(profileCalculateLTIWage 20000)
!(profileStimulate 1000)



