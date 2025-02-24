(: filter (-> Expression (-> $t Bool) Expression))
(= (filter $list $predicate)
   (if (== $list ())
    ()
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
)

(: customFilter (-> Expression (-> Symbol Number Number Bool) Number Number Expression))
(= (customFilter $list $predicate $lower $upper)
  (if(== $list ())
    ()
    (let*
      (
       ($head (car-atom $list))
       ($tail (cdr-atom $list))
       ($res ($predicate $head $lower $upper))
       ($filteredTail (customFilter $tail $predicate $lower $upper))
       )
      (if $res
        (cons-atom $head $filteredTail)
        $filteredTail
      )
    )
   )
)

; Binary filter remains unchanged
(: binaryFilter (-> (-> Atom Atom Bool) Atom Expression Expression))
(= (binaryFilter $f $pivot $tuple)
   (if (== $tuple ())  
       ()
       (let* 
            (
               ($head (car-atom $tuple))  
               ($tail (cdr-atom $tuple))  
               ($isValid ($f $head $pivot)) 
               ($filteredTail (binaryFilter $f $pivot $tail)) 
            )
            (if $isValid
               (cons-atom $head $filteredTail) 
               $filteredTail
            ) 
       )
   )
)
(: valuesAtIndex (-> Number Expression Expression))
(= (valuesAtIndex $i $handleSetSeq)
   (if(== $handleSetSeq ())
     ()
     (let*(
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
(: flatten (-> Expression Expression))
(= (flatten $expr)
   (if (== $expr ()) 
       () 
       (let* (($head (car-atom $expr))
              ($tail (cdr-atom $expr))
              ($flattened-head (if (== (get-metatype $head) Expression)
                                   (flatten $head)
                                   (cons-atom $head ())))
              ($flattened-tail (flatten $tail)))
         (concatTuple $flattened-head $flattened-tail)))
)


(= (contains $list $x)
   (if(== $list ())
     False
     (let*
       (
        ($head (car-atom $list))
        ($tail (cdr-atom $list))
        )
       (if(== $head $x)
         True
         (contains $tail $x)
       )
      )
    )
)

(: removeDuplicates (-> Expression Expression))
(= (removeDuplicates $list)
   (if (== $list ())
     ()
     (let*
       (
          ($head (car-atom $list))
          ($tail (cdr-atom $list))
          ($filteredTail (removeDuplicates $tail))
        )
       (if(contains $filteredTail $head)
        $filteredTail
        (cons-atom $head $filteredTail)
       )
    )
  )
)

(= (sort $list)
   (if (== $list ())
       () ; Base case: empty list is already sorted
       (let*
           (
               ($pivot (car-atom $list)) ; Split into pivot and rest
               ($rest (cdr-atom $list))
               ($smaller (filterLess $pivot $rest)) ; Elements smaller than pivot
               ($greater (filterGreaterEqual $pivot $rest)) ; Elements greater or equal to pivot
               ($greaterRemaining (sort $greater))
           )
           (concatTuple (sort $smaller) (cons-atom $pivot $greaterRemaining)) ; Recursively sort and combine
       )
   )
)

(= (filterLess $pivot $list)
   (if (== $list ())
       () ; Base case: empty list
       (let*
           (
              ($head (car-atom $list))
              ($tail (cdr-atom $list))
               ($restFiltered (filterLess $pivot $tail)) ; Recursive filtering
           )
           (if (< $head $pivot)
               (cons-atom $head $restFiltered) ; Include $head if it's less than $pivot
               $restFiltered ; Skip $head otherwise
           )
       )
   )
)

(= (filterGreaterEqual $pivot $list)
   (if (== $list ())
       () ; Base case: empty list
       (let*
           (
              ($head (car-atom $list))
              ($tail (cdr-atom $list))
               ($restFiltered (filterGreaterEqual $pivot $tail)) ; Recursive filtering
           )
           (if (>= $head $pivot)
               (cons-atom $head $restFiltered) ; Include $head if it's greater or equal to $pivot
               $restFiltered ; Skip $head otherwise
           )
       )
   )
)

(: collectContents (-> Expression Expression Expression))
(= (collectContents $list $acc)
   (if(== $list ())
    $acc
    (let*
      (
        (($index $content) (car-atom $list))
        ($tail (cdr-atom $list))
        ($rest (collectContents $tail $acc))
       )
      (concatTuple $content $rest)
      )
    )
)

; Helper function to append an element to the end of a list
(= (append-to-end $list $elem)
   (if (== $list ()) 
       (cons-atom $elem ())
       (let* (
               ($head (car-atom $list))  
               ($tail (cdr-atom $list))  
               ($appended-tail (append-to-end $tail $elem))
             )
           (cons-atom $head $appended-tail) 
       )
   )
)

;function to reverse an expression 
(= (reverseExpr $expr)
   (if (== $expr ())
       ()
       (let* (
               ($head (car-atom $expr))  
               ($tail (cdr-atom $expr))  
               ($reversed-tail (reverseExpr $tail))  
               ($result (append-to-end $reversed-tail $head))
           )
           $result  
       )
   )
)

(: findMaxSTI (-> Expression Number))
(= (findMaxSTI $list)
   (let*
     (
      ($atom (car-atom $list))
      ($max (getSTI $atom))
      ($rest (cdr-atom $list))
      )
     (if(not (== $rest ()))
       (if (> $max (findMaxSTI $rest))
          $max
          (findMaxSTI $rest)
        )
       $max
      )
  )
)

(: findMinSTI (-> Expression Number))
(= (findMinSTI $list)
   (let*
     (
      ($atom (car-atom $list))
      ($min (getSTI $atom))
      ($rest (cdr-atom $list))
      )
     (if(not (== $rest ()))
       (if (<= $min (findMinSTI $rest))
          $min
          (findMinSTI $rest)
        )
       $min
      )
  )
 )


(: update-atom (-> Grounded Atom Atom (->)))
(= (update-atom $space $oatom $natom) (let $_ (remove-atom $space $oatom) (add-atom $space $natom)))

(: getType (-> Grounded Atom Atom))
(= (getType $space $instance) (collapse (get-type-space $space $instance)))
