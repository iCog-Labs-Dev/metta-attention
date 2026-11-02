!(import! &self ./adagram)

(= (pair ())
    ()
)

(= (pair (cons $atom $rest))
    (cons ($atom (collapse (match &self ((SimilarityLink $source $atom) $val) (SimilarityLink $source $atom)))) (pair $rest))
)


(= (pair2 ())
    ()
)

(= (pair2 (cons $atom $rest))
    (cons ($atom (collapse (match &self (($link $atom $target) $val) ($link $atom $target)))) (pair2 $rest))
)

!(let*
    (
        ($source (collapse (match &self ((SimilarityLink $source $target) $val) $target)))
        ($uni (unique-atom $source))
        ($atom (pair $uni))
    )
    $atom
)

!(let*
    (
        ($source (collapse (match &self (($link $source $target) $val) $source)))
        ($uni (unique-atom $source))
        ($atom (pair2 $uni))
    )
    $atom
)
