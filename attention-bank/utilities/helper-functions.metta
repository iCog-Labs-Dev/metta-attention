(: filter (-> Expression (-> $t Bool) Expression Expression))
(= (filter $list $predicate $acc)
   (if (== $list ())
    $acc
    (let*
      (
          ($head (car-atom $list))
          ($tail (cdr-atom $list))
          ($res ($predicate $head))
          ($filteredTail (filter $tail $predicate $acc))
      )
      (if $res
          (cons-atom $head $filteredTail)
          $filteredTail
        )
      )
   )
)

; Binary filter for filtering atoms based on a binary predicate
(: binaryFilter (-> (-> Atom Atom Bool) Atom Expression Expression))
(= (binaryFilter $f $pivot $tuple)
   (if (== $tuple ())  
       ()
       (let* 
            (
               ($head (car-atom $tuple))  
               ($tail (cdr-atom $tuple))  
               ($is-valid ($f $pivot $head)) 
               ($filtered-tail (binaryFilter $f $pivot $tail)) 
            )
            (if $is-valid
               (cons-atom $head $filtered-tail) 
               $filtered-tail
            ) 
       )
   )
)

(: valuesAtIndex (-> Number Expression Expression))
(= (valuesAtIndex $i ()) ())
(= (valuesAtIndex $i $handleSetSeq)
   (
    let*(
         (($index $val) (car-atom $handleSetSeq))
         ($tail (cdr-atom $handleSetSeq))
         ($newTail (valuesAtIndex $i $tail))
        )
    (
     if(== $i $index)
      $val
      $newTail
    )
  )
)

(: size (-> Expression Number))
(= (size $list)
   (if (== $list ())
      0
      (let $tail (cdr-atom $list) (+ 1 (size $tail)))
    )
)

(= (Max $numbers) 
    (let* (
        ($max (car-atom $numbers))
        ($rest (cdr-atom $numbers))
    )
        (if (not (== $rest ()))
            (if (> $max (Max $rest))
                $max
                (Max $rest)
            )
            $max
        )
    )
)

(= (Min $numbers) 
    (let* (
        ($min (car-atom $numbers))
        ($rest (cdr-atom $numbers))
    )
        (if (not (== $rest ()))
            (if (< $min (Min $rest))
                $min
                (Min $rest)
            )
            $min
        )
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

(= (firstElement ($x $xs)) $x)
(= (maxValue $max ()) $max)
(= (maxValue $max ($x $xs))
    (if (> $max $x)
        (maxValue $max $xs)
        (maxValue $x $xs)
    )
)
(= (maxList $list)
    (maxValue -1 $list)
)

(= (minValue $min ()) $min)
(= (minValue $min ($x $xs))
    (if (< $min $x)
        (minValue $min $xs)
        (minValue $x $xs)
    )
)
(= (minList $list)
    (minValue (firstElement $list) $list)
)

;Function for concatinating
(= (concatTuple $xs $ys)
    (if (== $xs ())
        $ys
        (let* ( ($head (car-atom $xs))
                ($tail (cdr-atom $xs))
                ($tailNew (concatTuple $tail $ys)))
            (cons-atom $head $tailNew))
    )
)
