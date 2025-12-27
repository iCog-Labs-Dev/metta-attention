!(import! &self ../../../../PeTTa/lib/lib_he)
!(import! &self ../../../../metta-attention/attention/AttentionParam)
!(import! &self ../../../../metta-attention/attention-bank/utilities/helper-functions)
!(import! &self ../../../../metta-attention/attention-bank/attention-value/getter-and-setter)
!(import! &self ../../../../metta-attention/attention-bank/bank/attention-bank)
!(import! &self ../../../../metta-attention/attention-bank/bank/importance-index/importance-index)
!(import! &self ../../../../metta-attention/attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../../../metta-attention/attention-bank/utilities/recentVal)

; Example usage to compute STI and LTI wages
!(test (calculateSTIWage) 20.0)
!(test (calculateLTIWage) 20.0)

; Initial AttentionValues
!(setAv x (200.0 200.0 0.0))
!(setAv y (200.0 200.0 0.0))
!(setAv z (200.0 200.0 1.0))


; Stimulate the atom with a stimulus of 1.5
!(stimulate x 1.5)

; Retrieve the updated AttentionValue
!(test (getAv x) (AV 230.0 230.0 0.0))

; Check updated funds
!(test (getAttentionParam FUNDS_STI) 99370.0)
!(test (getAttentionParam FUNDS_LTI) 99370.0)

; Stimulate the atom with a stimulus of 2
!(stimulate x 2)

; Retrieve the updated AttentionValue
!(test (getAv x) (AV 270.0 270.0 0.0))

; Check updated funds
!(test (getAttentionParam FUNDS_STI) 99330.0)
!(test (getAttentionParam FUNDS_LTI) 99330.0)

; Check the  attentional focus  is updated  when an atom is stimulated

!(stimulate y 2)

; Check new Atom is added to bin 0
!(stimulate w 0)

!(let $afAtoms
    (getAfAtoms)
    (test (subtraction-atom $afAtoms (x y z w)) ())
)
