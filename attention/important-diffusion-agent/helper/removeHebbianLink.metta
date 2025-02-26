
;this function will be implemented in the attention-bank in the future 
;this function will be used to remove the Hebbian link from the given Expression
; on this time we use this one for simulation part  look like the following
; and it work fine

!(bind! &heabinLink (new-space))
;function removeHebbianLink
;param: Expression
;return Expression that is the result of removing the Hebbian link from the given Expression

(: removeHebbianLink (-> Expression Expression))

(= (removeHebbianLink $atoms)
    (if (== $atoms ())
        ()
        (let* (
            ($head (car-atom $atoms))
            ($tail (cdr-atom $atoms))
            ($hebbian (collapse (match &heabinLink ($head HebbianLink) ($head))))
            ($recursive (removeHebbianLink $tail))
            )
            (if (== $hebbian ())
                (cons-atom $head $recursive)
                (removeHebbianLink $tail)
            )
            

        )
    )
)
