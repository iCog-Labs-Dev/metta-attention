!(register-module! ../../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &self metta-attention:attention-bank:utilities:recentVal)
!(import! &self metta-attention:attention:agents:mettaAgents:Neighbors)

!(import! &self metta-attention:attention:agents:mettaAgents:HebbianCreationAgent:HebbianCreationAgent)

!(stimulate (ASYMMETRIC_HEBBIAN_LINK A B) 200 )
!(stimulate (ASYMMETRIC_HEBBIAN_LINK A c) 200 )
!(stimulate (INHERITANCE A D) 100)
!(stimulate (INHERITANCE D A) 100)
!(stimulate (ASYMMETRIC_HEBBIAN_LINK B c) 200 )


!(add-atom (attentionalFocus) a)
!(add-atom (attentionalFocus) b)
!(add-atom (attentionalFocus) c)
!(add-atom (attentionalFocus) d)
!(add-atom (attentionalFocus) e)
!(add-atom (attentionalFocus) f)
!(add-atom (attentionalFocus) g)
!(add-atom (attentionalFocus) (ASYMMETRIC_HEBBIAN_LINK a b))
!(add-atom (attentionalFocus) (ASYMMETRIC_HEBBIAN_LINK b c))
!(add-atom (attentionalFocus) (ASYMMETRIC_HEBBIAN_LINK c d))
!(add-atom (attentionalFocus) (ASYMMETRIC_HEBBIAN_LINK d e))
!(add-atom (attentionalFocus) (ASYMMETRIC_HEBBIAN_LINK e f))
!(add-atom (attentionalFocus) (ASYMMETRIC_HEBBIAN_LINK f g))
!(add-atom (attentionalFocus) (ASYMMETRIC_HEBBIAN_LINK g a))
!(add-atom (attentionalFocus) (HEBBIAN_LINK a b))
!(add-atom (attentionalFocus) (HEBBIAN_LINK b c))
!(add-atom (attentionalFocus) (HEBBIAN_LINK c d))
!(add-atom (attentionalFocus) (HEBBIAN_LINK d e))
!(add-atom (attentionalFocus) (HEBBIAN_LINK e f))
!(add-atom (attentionalFocus) (HEBBIAN_LINK f g))
!(add-atom (attentionalFocus) (HEBBIAN_LINK g a))




; !(attentionalFocusSize)
;  !(HebbianCreationAgent-Run)

!( collapse (getSourceNeighborsHelper a ASYMMETRIC_HEBBIAN_LINK True))

; !(match (attentionalFocus) $x $x)

; !(getAtomList)

; !(getIncomingSet b ASYMMETRIC_HEBBIAN_LINK)