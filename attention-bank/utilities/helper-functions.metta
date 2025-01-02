; Recursive helper to calculate the group index
(= (find_group $imp $sum $i)
   (if (>= $sum $imp)
       $i ; Return the group index
       (find_group $imp (+ $sum (pow 2 $i)) (+ $i 1))))

;a function to find the ceil
(= (ceil $x)
   (let $int_part (truncate $x)
      (if (== $x $int_part)
          $int_part ; $x is already an integer
          (+ $int_part 1)))) ; Otherwise, round up


; Helper function to truncate a number (remove fractional part)
(= (truncate $x)
   (truncate_helper $x 0))

; Recursive helper to decrement $x until it is less than the next integer
(= (truncate_helper $x $acc)
   (if (< $x (+ $acc 1))
       $acc ; The accumulated integer part
       (truncate_helper $x (+ $acc 1))))

;function to find power of a number    
(= (pow $base $exp)
   (if (<= $exp 0)
       1 ; Any number to the power of 0 is 1
       (* $base (pow $base (- $exp 1))))) ; Recursive multiplication