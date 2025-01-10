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
