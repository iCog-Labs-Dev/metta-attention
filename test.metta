(x 1)

(= (test $num)
    (let*
        (
            (($sym $val) (match &self (x $number) (x $number)))
            ($inc (+ 1 $val))
            ($_ (let $x (remove-atom &self (x $val)) ()))
        )
        (add-atom &self (x $inc))
    )
)

; !(test (superpose (1 2 3 4)))
!(test 1)
!(test 2)
!(test 3)
!(test 4)

(= (recursive $values)
    (if (== $values ())
        ()
        ((test (car-atom $values)) (recursive (cdr-atom $values)))
    )
)

!(recursive (1 2 3 4))

!(match &self (x $num) (x $num))