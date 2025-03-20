(x 1)

(= (test $num)
    (let*
        (
            (($sym $val) (match &self (x $number) (x $number)))
            ($inc (+ $num $val))
            ($_ (let $x (remove-atom &self (x $val)) ()))
        )
        (add-atom &self (x $inc))
    )
)

!(test (superpose (1 2 3 4)))


(= (recursive $values)
    (if (== $values ())
        ()
        ((test (car-atom $values)) (recursive (cdr-atom $values)))
    )
)

; !(recursive (1 2 3 4))

!(match &self (x $num) (x $num))