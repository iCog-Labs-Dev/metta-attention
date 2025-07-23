!(register-module! ../../../../metta-attention)
!(import! &self metta-attention:attention:ForgettingAgent/ForgettingAgent)
!(import! &self metta-attention:attention-bank:utilities/helper-functions)
!(import! &self metta-attention:attention:AttentionParam)
!(import! &self metta-attention:attention-bank:attention-value/getter-and-setter)
!(import! &self metta-attention:attention-bank:bank/atom-bins/atombins)
!(import! &self metta-attention:attention-bank:bank/attention-bank)
!(import! &self metta-attention:attention-bank:bank/attentional-focus/attentional-focus)
!(import! &self metta-attention:attention-bank:bank/importance-index/importance-index)

; stimualte 0.25 translated to lti 5

!(stimulate a 1)
!(stimulate b 0.4)
!(stimulate c 0.2)
!(stimulate d 0.15)
!(stimulate e 0.41)
!(stimulate f 0.62)
!(stimulate g 0.13)
!(stimulate h 0.02)
!(stimulate i 0.43)
!(stimulate j 0.52)
!(stimulate k 0.13)
!(stimulate l 0.02)
!(stimulate A 1)
!(stimulate B 0.4)
!(stimulate C 0.2)
!(stimulate D 0.15)
!(stimulate E 0.41)
!(stimulate F 0.62)
!(stimulate G 0.13)
!(stimulate H 0.02)
!(stimulate I 0.43)
!(stimulate J 0.52)
!(stimulate K 0.13)
!(stimulate L 0.02)
!(stimulate M 0.1)
!(stimulate N 0.1)

!(stimulate O 0.1)
!(stimulate o 2.1)
!(setStv p (0.1 0.2))

; only stv, source > 5, target > 5
!(setStv (ASYMMETRIC_HEBBIAN_LINK a b) (0.5 0.45))

; only stv, source < 5, target < 5
!(setStv (ASYMMETRIC_HEBBIAN_LINK c d) (0.4 0.45))

; stv & av, lit > 5, source > 5, target > 5
!(stimulate (ASYMMETRIC_HEBBIAN_LINK e f) 2)

; stv &av, lit > 5, source < 5, target < 5
!(stimulate (ASYMMETRIC_HEBBIAN_LINK g h) 13)

; stv & av, lit < 5, source > 5, target > 5
!(stimulate (ASYMMETRIC_HEBBIAN_LINK i j) 0.2)

; stv &av, lit < 5, source < 5, target < 5
!(stimulate (ASYMMETRIC_HEBBIAN_LINK k l) 0.1)

; only stv, source > 5, target > 5
!(setStv (SYMMETRIC_HEBBIAN_LINK A B) (0.5 0.45))

; only stv, source < 5, target < 5
!(setStv (SYMMETRIC_HEBBIAN_LINK C D) (0.4 0.45))

; stv & av, lit > 5, source > 5, target > 5
!(stimulate (SYMMETRIC_HEBBIAN_LINK E F) 2)

; stv &av, lit > 5, source < 5, target < 5
!(stimulate (SYMMETRIC_HEBBIAN_LINK G H) 13)

; stv & av, lit < 5, source > 5, target > 5
!(stimulate (SYMMETRIC_HEBBIAN_LINK I J) 0.2)

; stv &av, lit < 5, source < 5, target < 5
!(stimulate (SYMMETRIC_HEBBIAN_LINK K L) 0.1)

; stv &av, lit < 5, source < 5, target < 5, link lti above source & target lti
!(stimulate (SYMMETRIC_HEBBIAN_LINK M N) 0.2)

!(assertEqual (match &space (fundsSTI $x) $x) 99174.80000000002)


!(forgettingAgent-Run (atomBin))


!(let*
    (
        ($rmvspace (getAtomsInRemoveSpace))	
        ($typspace (getAtomsInTypeSpace)) 
        ($newAtomInAV (getNewAtomInAVList))
        ($assertTypespace (assertEqual (intersection-atom $typspace $rmvspace) ()))
        ($assertNewtoAvspace (assertEqual (intersection-atom $newAtomInAV $rmvspace) ()))
    )
    ()
) 

!(assertEqual (match &space (fundsSTI $x) $x) 99468.40000000002)

!(assertEqual (let $a (getAtomsInRemoveSpace) (size-atom $a)) 15)