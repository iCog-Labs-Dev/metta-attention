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
;TODO: Figure out why when types are added to this function, It returns []
;(: valuesAtIndex (-> Number $list_t $list_t))
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

;(: size (-> Expression Number))
(= (size $list)
    (if (== $list ())
        0
        (+ 1 (size (cdr-atom $list)))
    )
)
(: Max (-> Expression Number))
( = (Max $numbers)
  (let* (
    ($top (car-atom $numbers))
    ($rest (cdr-atom $numbers))
    )
    (if (== $rest ())
      $top
      (let* (
        ($nextTop (car-atom $rest))
        ($tail (cdr-atom $rest))
        ($mergeList (cons-atom $top $tail))
        )
        (if (> $top $nextTop)
          (Max $mergeList)
          (Max $rest)
        )
      )
    
    )

  )
)
(: Min (-> Expression Number))
( = (Min $numbers)
  (let* (
    ($top (car-atom $numbers))
    ($rest (cdr-atom $numbers))
    )
    (if (== $rest ())
      $top
      (let* (
        ($nextTop (car-atom $rest))
        ($tail (cdr-atom $rest))
        ($mergeList (cons-atom $top $tail))
        )
        (if (< $top $nextTop)
          (Min $mergeList)
          (Min $rest)
        )
      )
    
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
       (truncateHelper $x (+ $acc 1.0))
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
        (let* ( 
                ($head (car-atom $xs))
                ($tail (cdr-atom $xs))
                ($tailNew (concatTuple $tail $ys))
              )
            (cons-atom $head $tailNew)
        )
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
   (not (== (collapse (intersection (superpose ($x)) (superpose $list))) ()))
)

(: removeDuplicates (-> Expression Expression))
(= (removeDuplicates $list)
   (collapse (unique (superpose $list)))
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
           (concatTuple (sort $smaller) (cons-atom $pivot $greaterRemaining)  ) ; Recursively sort and combine
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

;function to reverse an expression 

(= (reverseExpr $x ) (collapse (union (superpose $x) (superpose ())))) 


; a function that find the maximum STI value of the  given atoms
(: findMaxSTI (-> Expression Number))
(= (findMaxSTI $list)
  (let* (
    ($atom (car-atom $list))
    ($max (getSTI $atom))
    ($rest (cdr-atom $list))
    )
    (if (== $rest ())
      $max
      (let* (
        ($nextTop (car-atom $rest))
        ($secondMax (getSTI $nextTop))
        ($tail (cdr-atom $rest))
        ($mergeList (cons-atom $atom $tail))
        )
        (if (> $max $secondMax)
          (findMaxSTI $mergeList)
          (findMaxSTI $rest)
        )
      )
    )
  )
)
; a function that find the minimum STI value of the  given atoms
(: findMinSTI (-> Expression Number))
(= (findMinSTI $list)
  (let* (
    ($atom (car-atom $list))
    ($max (getSTI $atom))
    ($rest (cdr-atom $list))
    )
    (if (== $rest ())
      $max
      (let* (
        ($nextTop (car-atom $rest))
        ($secondMax (getSTI $nextTop))
        ($tail (cdr-atom $rest))
        ($mergeList (cons-atom $atom $tail))
        )
        (if (< $max $secondMax)
          (findMinSTI $mergeList)
          (findMinSTI $rest)
        )
      )
    )
  )
 )

             