(: filter (-> Expression (-> $t Bool) Expression))
(= (filter () $predicate) ())
(= (filter $list $predicate)
   (let*
     (
        ($head (car-atom $list))
        ($tail (cdr-atom $list))
        ($res ($predicate $head))
        ($filteredTail (filter $tail $predicate))
     )
     (if $res
        (cons-atom $head $filteredTail)
        $filteredTail
       )
    )
)

(: size (-> Expression Number Number))
(= (size () $s) $s)
(= (size $list $s)
   (let*(
         ($head (car-atom $list))
         ($tail (cdr-atom $list))
        )
     (size $tail (+ 1 $s))
    )
)

; Recursive helper to calculate the group index
(= (findGroup $imp $sum $i)
   (if (or (>= $sum $imp) (>= $i (GroupNum)))
      $i ; Return the group index
      (findGroup $imp (+ $sum (pow 2 $i)) (+ $i 1))
   )
)

;a function to find the ceil
(: ceil (-> Number Number))
(= (ceil $x)
   (let $int_part (truncate $x)
      (if(== $x $int_part)
         $int_part ; $x is already an integer
         (+ $int_part 1)
      )
   )
) ; Otherwise, round up


; Helper function to truncate a number (remove fractional part)
(: truncate (-> Number Number))
(= (truncate $x)
   (truncateHelper $x 0)
)

; Recursive helper to find the integer part of $x
(: truncateHelper (-> Number Number Number)) 
(= (truncateHelper $x $acc)
   (if (< $x (+ $acc 1))
       $acc ; The accumulated integer part
       (truncateHelper $x (+ $acc 1))
   )
)

;function to find power of a number
(: pow (-> Number Number Number))    
(= (pow $base $exp)
   (if(<= $exp 0)
      1 ; Any number to the power of 0 is 1
      (* $base (pow $base (- $exp 1)))
   )
) ; Recursive multiplication
