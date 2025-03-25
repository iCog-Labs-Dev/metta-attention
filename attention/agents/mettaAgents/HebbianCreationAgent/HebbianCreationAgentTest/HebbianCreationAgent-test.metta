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


; add two atoms to the attentional focus
!(add-atom (attentionalFocus) (ASYMMETRIC_HEBBIAN_LINK source target2))
!(add-atom (attentionalFocus) (ASYMMETRIC_HEBBIAN_LINK abebe source))

!(setAv ATOMFROMBINS (0 0 0))  ; set the attention value of the atom to 0
; !(insertAtom 1 ATOMFROMBINS) ; insert the atom into the atom bins of index 1 

; !(assertEqual (getSourceAtom (HEBBIAN_LINK a b)) a) ; source atom is the second atom from the left

; !(assertEqual (setDifference  ((ASYMMETRIC_HEBBIAN_LINK source target2))) ((ASYMMETRIC_HEBBIAN_LINK abebe source)) ) ;atoms that are in the attentional focus but not in the incoming list


; !(add-atom (attentionalFocus) (ASYMMETRIC_HEBBIAN_LINK source1 target))
; !(add-atom (attentionalFocus) (ASYMMETRIC_HEBBIAN_LINK source2 target))
; !(add-atom (attentionalFocus) (ASYMMETRIC_HEBBIAN_LINK source target1))

; !(assertEqual (removeLinkRecursively 0) ()) ; If num is 0, nothing should be removed
; !(removeLinkRecursively 2) ; Two links are removed from the attetnional focus

; !(assertEqual (attentionalFocusSize) 3)

; !(addHebbian source3 target3)
; !(assertEqual (atomIsInAF (ASYMMETRIC_HEBBIAN_LINK source3 target3 ) ) True)

; !(assertEqual (addFromOutSideAF A 0) ()) ; If farlinks is 0, nothing should be added

; !(addFromOutSideAF A 1) ; If farlinks is 1, one link should be added, increasing the attentional focus size by 1

; !(assertEqual (attentionalFocusSize) 5) ; add hebbian and addFromOutSideAF should increase the attentional focus size by 1 each 



; !(add-atom (attentionalFocus) (ASYMMETRIC_HEBBIAN_LINK a b))
; !(add-atom (attentionalFocus) (ASYMMETRIC_HEBBIAN_LINK b c))
; !(add-atom (attentionalFocus) (ASYMMETRIC_HEBBIAN_LINK c d))
; !(add-atom (attentionalFocus) (ASYMMETRIC_HEBBIAN_LINK d e))
; !(add-atom (attentionalFocus) (ASYMMETRIC_HEBBIAN_LINK e f))
; !(add-atom (attentionalFocus) (ASYMMETRIC_HEBBIAN_LINK f g))
; !(add-atom (attentionalFocus) (ASYMMETRIC_HEBBIAN_LINK g a))
; !(add-atom (attentionalFocus) (ASYMMETRIC_HEBBIAN_LINK g b))

; !(add-atom (attentionalFocus) target1)
; !(add-atom (attentionalFocus) target2)
; !(add-atom (attentionalFocus) source1)
; !(add-atom (attentionalFocus) source2)

; !(add-atom (attentionalFocus) (HEBBIAN_LINK a b))
; !(add-atom (attentionalFocus) (HEBBIAN_LINK b c))
; !(add-atom (attentionalFocus) (HEBBIAN_LINK c d))
; !(add-atom (attentionalFocus) (HEBBIAN_LINK d e))
; !(add-atom (attentionalFocus) (HEBBIAN_LINK e f))
; !(add-atom (attentionalFocus) (HEBBIAN_LINK f g))
; !(add-atom (attentionalFocus) (HEBBIAN_LINK g a))

; !(HebbianCreationAgent-Run (TypeSpace) (attentionalFocus))

; !(attentionalFocusSize) ;Check if more Hebbian links are created 


