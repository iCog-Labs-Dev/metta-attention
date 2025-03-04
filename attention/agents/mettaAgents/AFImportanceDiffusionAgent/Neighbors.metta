; !(register-module! ../../metta-attention)
; !(import! &self metta-attention:attention-bank:utilities:helper-functions)
; !(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
; !(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
; !(import! &self metta-attention:attention-bank:bank:attention-bank)
; !(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
; !(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)


(= (getTargetNeighbors $atom $type $match-subtype)
    (if (== $type UNORDERED_LINK)
        ()
        (let*
            (
                (($link $source $target) (let $tmp (getIncomingSet $atom $type) (superpose $tmp)))
                ($answer
                    (if (== $link $type)
                        (if (== $source $atom)
                            $target
                            ()
                        )
                        ()
                    )
                )
            )
            $answer
        )
    )
)

(= (getSourceNeighbors $atom $type $match-subtype)
    (if (== $type UNORDERED_LINK)
        ()
        (let*
            (
                (($link $source $target) (let $tmp (getIncomingSet $atom $type) (superpose $tmp)))
                ($answer
                    (if (== $link $type)
                        (if (not (== $source $atom))
                            $source
                            ()
                        )
                        ()
                    )
                )
            )
            $answer
        )
    )
)

; !(add-atom &attentionalFocus (UNORDERED_LINK A B))
; !(add-atom &attentionalFocus (UNORDERED_LINK B A))
; !(add-atom &attentionalFocus (ASYMMETRIC_HEBBIAN_LINK C D))
; !(add-atom &attentionalFocus (ASYMMETRIC_HEBBIAN_LINK C F))
; !(add-atom &attentionalFocus (HEBBIAN_LINK G H))
; !(add-atom &attentionalFocus (HEBBIAN_LINK I J))
; !(add-atom &attentionalFocus (HEBBIAN_LINK K L))

; !(getTargetNeighbors C ASYMMETRIC_HEBBIAN_LINK True)
; !(getSourceNeighbors D ASYMMETRIC_HEBBIAN_LINK True)