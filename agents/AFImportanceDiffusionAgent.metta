; !(register-module! ../../metta-attention)
; !(import! &self metta-attention:attention-bank:utilities:helper-functions)
; !(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
; !(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
; !(import! &self metta-attention:attention-bank:bank:attention-bank)
; !(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
; !(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
; !(import! &self metta-attention:agents:Neighbors)
; !(import! &self metta-attention:agents:ImportanceDiffusionBase)

; !(add-atom (attentionalFocus) (UNORDERED_LINK A B))
; !(add-atom (attentionalFocus) (UNORDERED_LINK B A))
; !(add-atom (attentionalFocus) (ASYMMETRIC_HEBBIAN_LINK C D))
; !(add-atom (attentionalFocus) (ASYMMETRIC_HEBBIAN_LINK C F))
; !(add-atom (attentionalFocus) (INHERITANCE_LINK B C))
; !(add-atom (attentionalFocus) (HEBBIAN_LINK A C))
; !(add-atom (attentionalFocus) (HEBBIAN_LINK G H))
; !(add-atom (attentionalFocus) (HEBBIAN_LINK I J))
; !(add-atom (attentionalFocus) (HEBBIAN_LINK K L))

; !(add-atom (attentionalFocus) (HEBBIAN_LINK (HEBBIAN_LINK K L) L))
; !(add-atom (attentionalFocus) (HEBBIAN_LINK G (HEBBIAN_LINK K L)))

; !(bind! hebbianMaxAllocationPercentage 0.1)
; !(bind! maxSpreadPercentage 0.1)
; !(bind! spreadHebbianOnly False)


; !(setAv C (200 0.5 5))

; (= (HebbianUpdatingAgent-Run)
;     (spreadImportance)
; )

; (= (spreadImportance)
;     (let $diffusionSourceVector (diffusionSourceVector (attentionalFocus))
;             (diffuseAtom $diffusionSourceVector (attentionalFocus))
;     )
; )

; (= (calculateDiffusionAmount $atom)
;     (* (getSTI $atom) maxSpreadPercentage)
; )

; !(diffuseAtom C (attentionalFocus))
; !(HebbianUpdatingAgent-Run)
