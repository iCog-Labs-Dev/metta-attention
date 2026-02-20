; This file containes the type definations for AttentionValue and TruthValue
; AttentionValue is a tuple of three numbers, 
    ; the first number is the short term importance(STI),
    ; the second number is the long term importance(LTI) and
    ; the third number is the value of very long term importance(VLTI).
; TruthValue is a tuple of two numbers, the first number is show the mean of the value and the second number is the confidence of the value.

(: AttentionValue Type)

(: TruthValue Type)

(: AV (-> Number Number Number AttentionValue))

(: STV (-> Number Number TruthValue))



!(bind! &Param (new-space))
!(add-atom &Param  (FUNDS_STI 100))

(= (incriment $val)
   (with_mutex testmutex 
    (let* (
        ($x (match &Param (FUNDS_STI $y) $y))
        ($add (remove-atom &Param (FUNDS_STI $z)))
        ($total (+ $val $x))
   ) 
   (add-atom &Param (FUNDS_STI $total))
)))


; !(match &Param (FUNDS_STI $y) $y)

!(add-atom &temp (cnt 37))

(= (mutexinc)
   (with_mutex testmutex
               (match &temp (cnt $x)
                      ((remove-atom &temp (cnt $x))
                       (let $inc (+ $x 1)
                            (add-atom &temp (cnt $inc))))
                        )))
; !(mutexinc)
; !(match &temp (cnt $y) $y)

; (= (call-hyperpose $num)
;         (if (== $num 0)
;              (finished)
;                 (let*
;                     (
;                         ($hy (mutexinc))
;                         ($pr (println! ($num iteration)))
;                         ($val (- $num 1))
;                     )
;                     (call-hyperpose $val)
;                 )
;     )
; )

; !(call-hyperpose 3)
; !(match &temp (cnt $y) $y)

; !(match &Param (FUNDS_STI $y) $y)


!(hyperpose ((incriment 2) (incriment 2) (incriment 2) (incriment 2) (incriment 2)))

!(match &Param (FUNDS_STI $y) $y)

; !(test (collapse (get-atoms &temp)) ((cnt 42)))
