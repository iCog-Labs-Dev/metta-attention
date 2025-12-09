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



; (: a A)
; (: b B)
; (: A Type)

; ; !(get-type AV) 

; !(get-type a) ; A
; !(get-type b) ; B
; !(get-type c) ; %Undefined%
; !(get-type A) ; Type
; !(get-type B) ; %Undefined%

; (: setAv (-> Atom (Number Number Number) Atom))
; !(get-type setAv) ;     


; (: GroupSize (-> Number))
; (= (GroupSize) 8)
; (: GroupNum (-> Number))
; (= (GroupNum) 12)

; (: ImportanceIndexSize (-> Number))
; (= (ImportanceIndexSize) 104)

; (: importanceBin (-> Number Number))
; (= (importanceBin $impo)
;    (
;     let*
;     (
;       ($groupSize (GroupSize))
;       ($impo_int (trunc-math $impo)) ; Ensure $impo is treated as an integer
;       ($firstCondition (< $impo_int 0))
;       ($secondCondition (< $impo_int (* 2 $groupSize)))
;     )
;     (if $firstCondition
;       0
;       (if $secondCondition
;         $impo_int
;         (let*
;           (
;             ($imp (trunc-math (/ (- $impo_int $groupSize) $groupSize)))
;             ($i (eval (findGroup $imp 0 0)))
;             ($num (- $i 1))
;             ($temp (ceil-math (/ $impo_int (pow-math 2 (- $i 1)))))
;             ($ad (- $groupSize $temp))
;             ($bin (- (* $i $groupSize) $ad))
;           )
;           $bin
;         )
;       )
;     )
;   )
; )

 
; ; Recursive helper to calculate the group index
; (= (findGroup $imp $sum $i)
;    (if ( <= $imp 0)
;     0
;     (
;         let* (
;             ($num (+ $imp 1))
;             ($log_num (log-math 2 $num))
;             ($int_num (ceil-math $log_num))
            
;         )
        
;         (let $x (eval (GroupNum))
;          (if (<= $int_num $x)
;             $int_num
;             $x
;         ))
;     )
;    )
; )
; !(get-type importanceBin)

; (= (test-eval $number)
;         (let $binValue (importanceBin $number) $binValue )
; )

; !(test-eval 100)

; !(let $_ (add-atom &self (hello world)) true)

; !(match &self (hello $x) $x)
; ; -	There shouldn’t be space before ! and the statement like ! (hello)
; ; - We don't have %Undefined% type
; ; - we can't use () as a placeholder
