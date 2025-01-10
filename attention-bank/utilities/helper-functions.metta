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

