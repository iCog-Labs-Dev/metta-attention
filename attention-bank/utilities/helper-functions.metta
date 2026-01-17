(= (filter $array $func)
   (if (== $array ())
       () 
       ($func $array)
   )
)

; (: notEmpty (-> Expression Expression))
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

; (: customFilter (-> Expression (-> Symbol Number Number Bool) Number Number Expression))
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

;Function: binaryFilter
;Description: Recursively filters atoms from a list based on a comparison function.
;Parameters:
;          $f: A function that determines whether an atom should be included.
;          $pivot: The reference atom for comparison.
;          $tuple: A list of atoms to filter.
;Returns: A filtered list of atoms satisfying the comparison condition.
; (: binaryFilter (-> (-> Atom Atom Bool) Atom Expression Expression))
(= (binaryFilter $f $pivot $tuple $fun)
   (if (== $tuple ())  
       ()
       (let* 
            (
               ($head (car-atom $tuple))  
               ($tail (cdr-atom $tuple))  

               ($isValid  ($f $head $pivot $fun))
               ($filteredTail (binaryFilter $f $pivot $tail $fun)) 
            )
            (if $isValid
               (cons-atom $head $filteredTail) 
               $filteredTail
            ) 
       )
   )
)


;a function to find the ceil
; (: ceil (-> Number Number))
(= (ceil $x)
   (let $int_part (trunc-math $x)
      (if(== $x $int_part)
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

; (: flattener (-> Expression Expression))
(= (flattener $expr)
   (if (== $expr ()) 
       () 
       (let* (($head (car-atom $expr))
              ($tail (cdr-atom $expr))
              ($flattened-head (if (== (get-metatype $head) Expression)
                                   (flattener $head)
                                   (cons-atom $head ())))
              ($flattened-tail (flattener $tail)))
         (union-atom $flattened-head $flattened-tail)))
)


(= (contains $list $x)
   (not (== (collapse (intersection (superpose ($x)) (superpose $list))) ()))
)

; (: removeDuplicates (-> Expression Expression))
(= (removeDuplicates $list)
   (collapse (unique (superpose $list)))
)

(= (sorter $list)
   (if (== $list ())
       () ; Base case: empty list is already sorted
       (let*
           (
               ($pivot (car-atom $list)) ; Split into pivot and rest
               ($rest (cdr-atom $list))
               ($smaller (filterLess $pivot $rest)) ; Elements smaller than pivot
               ($greater (filterGreaterEqual $pivot $rest)) ; Elements greater or equal to pivot
               ($greaterRemaining (sorter $greater))
               ($x (sorter $smaller))
               ($y (cons-atom $pivot $greaterRemaining))
           )
           (union-atom $x $y) ; Recursively sort and combine
       )
   )
)

(= (sortDecend $list)
   (if (== $list ())
       () ; Base case: empty list is already sorted
       (let*
           (
               ($pivot (car-atom $list)) ; Split into pivot and rest
               ($rest (cdr-atom $list))
               ($smaller (filterLess $pivot $rest)) ; Elements smaller than pivot 2 7 3 3
               ($greater (filterGreaterEqual $pivot $rest)) ; Elements greater or equal to pivot 9 7 3
               ($greaterRemaining (sortDecend $greater))
               ($x (sortDecend $smaller))
               ($y (cons-atom $pivot $x))
           )
           (union-atom $greaterRemaining $y) ; Recursively sort and combine
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
; (: abs (-> Number Number))
(= (abs $x)
    (if (< $x 0) (- 0 $x) $x)
)

; Define approximate equality
; (: approxEqual (-> Number Number Number Bool))
(= (approxEqual $a $b $tol)
    (<= (abs (- $a $b)) $tol)
)

; (: extractAndFlatten (-> Expression Expression))
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

; (: collectContents (-> Expression Expression Expression))
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

(= (reverseExpr $list) (foldl-atom $list () $i $c (cons-atom $c $i)))
; Description: the function takes a list of atoms and experessions 
;              and returns a new list wich contatins only symobls
; params:
;    $atoms: list of symbols and expressions
; return: list of symbols
; (: removeLinksfromList (-> List List))
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



;;; Function: getOutGoingAtoms
;;; Description: Retrieves the outgoing atoms of a given link.
;;; Parameters:
;;;   $link: The link for which to find outgoing atoms.
;;; Returns: A list of outgoing atoms.
;;; Example: (getOutGoingAtoms (LINK A B))
;;;          Returns (A B)

; (: getOutGoingAtoms (-> Atom Atom))
(= (getOutGoingAtoms $link)
    (if (== (size-atom $link) 3)
        (cdr-atom $link)
        ()
    )
)

; (= (sortAtomsDescending $atoms $fun) 
;     (if (== $atoms ())
; 		()
; 		(let*
; 			(
; 				($pivot (car-atom $atoms))
; 				($tail (cdr-atom $atoms))
; 				($lesser (binaryFilter lessThanSti  $pivot $tail $fun))
; 				($greater (binaryFilter greaterThanSti  $pivot $tail $fun))
;                 ($sortedLesser (sortAtomsDescending $lesser $fun))
;                 ($sortedGreater (sortAtomsDescending $greater $fun))
; 			)	
;            (concatTuple $sortedGreater (cons-atom $pivot $sortedLesser))
; 		)
; 	)

; )

(= (lessThanSti $elem $pivot $fun)
    (if (or (== $elem ()) (== $pivot ()))
		False
	    (<= ($fun $elem) ($fun $pivot))
    )   
)

(= (greaterThanSti $elem $pivot $fun)
    (if (or (== $elem ()) (== $pivot ()))
		False
	    (> ($fun $elem) ($fun $pivot))
    )   
)

(= (lessEqBy $elem $pivot $fun)
   (<= ($fun $elem) ($fun $pivot)))

(= (greaterBy $elem $pivot $fun)
   (> ($fun $elem) ($fun $pivot)))

(= (sortAtomsDescending () $fun)
   ())

(= (sortAtomsDescending $atoms $fun)
   (let*
     (
       ($pivot (car-atom $atoms))
       ($tail  (cdr-atom $atoms))

       ($greater
         (sortAtomsDescending
           (binaryFilter greaterBy $pivot $tail $fun)
           $fun))

       ($lesser
         (sortAtomsDescending
           (binaryFilter lessEqBy $pivot $tail $fun)
           $fun))
     )
     (concatTuple $greater (cons-atom $pivot $lesser))
   )
)
