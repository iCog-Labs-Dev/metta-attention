
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

(= (length ()) 0)
(= (length $atoms) 
    (
        let* (
            ($rest (cdr-atom $atoms))
        )
        (+ 1 (length $rest))
        )
)
