(= (filter $array $func)
   (if (== $array ())
       () 
       ($func $array)
   )
)

(: notEmpty (-> Expression Expression))
(= (notEmpty $list)

   (collapse 
        (let $x (superpose $list)
            (if (== $x ()) 
                (empty) 
                $x
            )
        ) 
   )
)

(: customFilter (-> Expression (-> Symbol Number Number Bool) Number Number Expression))
(= (customFilter $list $predicate $lower $upper)
  (if (== $list ())
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

;Function: binaryFilter
;Description: Recursively filters atoms from a list based on a comparison function.
;Parameters:
;          $f: A function that determines whether an atom should be included.
;          $pivot: The reference atom for comparison.
;          $tuple: A list of atoms to filter.
;Returns: A filtered list of atoms satisfying the comparison condition.
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
   (if (== $handleSetSeq ())
     ()
    (let $seq (collapse (let ($index $val) (superpose $handleSetSeq)
        (if (== $i $index)
            $val
            (empty)
        )
     
        )
        )
        (if (== $seq ())
            ()
            (car-atom $seq)
        )
    )
   )
)


(= (log' $x $y)
    (if (<= $y 0)
        (empty)
        (let*
            (
                ($y-low -1000)
                ($y-high 1000)
                ($epsilon 0.000000000001)
                ($max-iter 1000)
                ($iter 0)
            )
            (loop $x $y $y-low $y-high $epsilon $max-iter $iter)
        )
    )
)

(= (loop $x $y $y-low $y-high $epsilon $max-iter $iter)
    (if (or (> $iter $max-iter) (== $iter $max-iter))
        (/ (+ $y-low $y-high) 2)
        (let* 
            (
                ($y-mid (/ (+ $y-low $y-high) 2))
                ($e-mid (pow-math $x $y-mid))
                ($new-iter (+ 1 $iter))
            )
            (if (< (abs-math (- $e-mid $y)) $epsilon)
                $y-mid
                (if (> $e-mid $y)
                    (loop $x $y $y-low $y-mid $epsilon $max-iter $new-iter)
                    (loop $x $y $y-mid $y-high $epsilon $max-iter $new-iter)
                )
            )
        )           
    )
)

; Recursive helper to calculate the group index
(= (findGroup $imp $sum $i)
   (if ( <= $imp 0)
    0
    (
        let* (
            ($num (+ $imp 1))
            ($log_num (log' 2 $num))
            ($int_num (+ (floor-math $log_num) 1))
            
        )
        
        (if (<= $int_num (GroupNum))
            $int_num
            (GroupNum)
        )
    )
   )
)

;a function to find the ceil
(: ceil (-> Number Number))
(= (ceil $x)
   (let $int_part (trunc-math $x)
      (if (== $x $int_part)
         $int_part ; $x is already an integer
         (+ $int_part 1)
      )
   )
) ; Otherwise, round up




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
         (union-atom $flattened-head $flattened-tail)))
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
           (union-atom (sort $smaller) (cons-atom $pivot $greaterRemaining)  ) ; Recursively sort and combine
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
; Define absolute difference
(: abs (-> Number Number))
(= (abs $x)
    (if (< $x 0) (- 0 $x) $x)
)

; Define approximate equality
(: approxEqual (-> Number Number Number Bool))
(= (approxEqual $a $b $tol)
    (<= (abs (- $a $b)) $tol)
)

(: extractAndFlatten (-> Expression Expression))
(= (extractAndFlatten $expr)
   (if (== $expr ())
       ()
       (let* (($head (car-atom $expr))
              ($tail (cdr-atom $expr))
            
              ($firstElem (car-atom $head))
              ($rest (cdr-atom $head))
              ($processedHead (if (== (get-type $firstElem) Number) 
                                  $rest  ; Remove the number, keep the rest
                                  $head)) ; If not a number, keep the whole expression
              ($flattenedTail (extractAndFlatten $tail))
        )
        (union-atom $processedHead $flattenedTail))
    )
)

(: collectContents (-> Expression Expression Expression))
(= (collectContents $list $acc)
   (if (== $list ())
    $acc
    (let*
      (
        ($content (car-atom $list))
        ($tail (cdr-atom $list))
        ($rest (collectContents $tail $acc))
       )
      (union-atom $content $rest)
      )
    )
)

;function to reverse an expression 

(= (reverseExpr $x ) (collapse (union (superpose $x) (superpose ())))) 

; Description: the function takes a list of atoms and experessions 
;              and returns a new list wich contatins only symobls
; params:
;		$atoms: list of symbols and expressions
; return: list of symbols
(: removeLinksfromList (-> List List))
(= (removeLinksfromList $atoms)
	(if (== $atoms ())
		()
		(let* 
			(
				($head (car-atom $atoms))
				($tail (cdr-atom $atoms))
			)
			(if (== (get-metatype $head) Symbol)
				(concatTuple ($head) (removeLinksfromList $tail))	
				(removeLinksfromList $tail)
			)
		)
	)
)


(= (getStiHelper $atoms)
    (let* (
        ($vals (getSti (superpose $atoms)))
    )
    $vals
    )
)

; a function that find the maximum STI value of the  given atoms
(: getAllMaxSTI  (-> Expression Number))
(= (getAllMaxSTI $atoms)
   (if (== $atoms ())
            0.0
            (let* (
                ($stiValues (collapse (getStiHelper $atoms)))
                ($maxSTI (max-atom $stiValues))
            )
            $maxSTI
            )
        )
    
)
; a function that find the minimum STI value of the  given atoms
(: getAllMinSTI  (-> Expression Number))
(= (getAllMinSTI $atoms)
    (if (== $atoms ())
            0.0
            (let* (
                ($stiValues (collapse (getStiHelper $atoms)))
                ($minSTI (min-atom $stiValues))
            )
            $minSTI
            )
        )
    
)


;;; Function: getOutGoingAtoms
;;; Description: Retrieves the outgoing atoms of a given link.
;;; Parameters:
;;;   $link: The link for which to find outgoing atoms.
;;; Returns: A list of outgoing atoms.
;;; Example: (getOutGoingAtoms (LINK A B))
;;;          Returns (A B)

(: getOutGoingAtoms (-> Atom Atom))
(= (getOutGoingAtoms $link)
    (if (== (size-atom $link) 3)
        (cdr-atom $link)
        ()
    )
)
