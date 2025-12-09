!(import! &self ../../../../../PeTTa/lib/lib_he)
!(import! &self ../../../../../metta-attention/attention/AttentionParam)
!(import! &self ../../../../../metta-attention/attention-bank/utilities/helper-functions)
!(import! &self ../../../../../metta-attention/attention-bank/attention-value/getter-and-setter)
!(import! &self ../../../../../metta-attention/attention-bank/bank/attention-bank)
!(import! &self ../../../../../metta-attention/attention-bank/attention-value/get-min-max)
!(import! &self ../../../../../metta-attention/attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../../../../metta-attention/attention-bank/bank/importance-index/importance-index)
!(import! &self ../../../../../metta-attention/attention-bank/utilities/recentVal)
; ##################### Prep: inserting Atoms in attentional focus ####################

; Test attentional focus
!(updateAttentionParam MAX_AF_SIZE 7)

!(setAv a (2.0 0.0 0.0))
!(setAv d (7.0 4.0 0.0))
!(setAv c (1.0 0.0 0.0))
!(setAv A (100.0 200.0 300.0))
!(setAv B (50.0 150.0 250.0))
!(setAv C (200.0 300.0 400.0))
!(getAfAtoms)
!(setAv D (25.0 125.0 225.0))
!(setAv F (70.0 100.0 200.0))
!(getAfAtoms)


!(getAttentionParam MAX_AF_SIZE)

; The test cases were added with setting AV for links but this might not be needed in reality because AVs may not be set for links/expressions

!(setAv (EvaluationLink a b) (100.0 100.0 100.0))

!(setAv (Hebbianlink (Hebbianlink Cat Human) Animal) (200.0 250.0 280.0))

; ################### Testing #################################

; Test case 01: Testing attentionalFocusSize asserting it returns correct number of atom in focus
!(test (getIncomingSetByType Animal Hebbianlink) ((Hebbianlink (Hebbianlink Cat Human) Animal)))

; ; ; ; Test case 02: Testing atomIsInAF asserting it returns True for a given atom in AF

!(test (isAtomInAf C) True)

; ; ; Testing same case for Link

!(test (isAtomInAf (EvaluationLink a b)) True)
!(test (isAtomInAf (Hebbianlink (Hebbianlink Cat Human) Animal)) True)


; ; Test case 03: Testin atomIsInAF asserting it return False foor a give atom not in AF

!(test (isAtomInAf Z) False)

; ; ; Test case 04: Testing getLowestStiAtomInAF returns an atom with lowest Sti
; !(test (getLowestStiAtomInAF) c)


; ; ; ; Test case 05: Testing updateAttentionalFocus by adding new atom to attentional focus

!(setAv G (300.0 400.0 500.0))

!(test (isAtomInAf G) True)

; !(let $x 
;     (getAfAtoms) 
;     (test 
;         (subtraction 
;             (superpose $x) 
;             (superpose (D B F (EvaluationLink a b) A (Hebbianlink (Hebbianlink Cat Human) Animal) C G))
;         ) 
;         (empty)
;     )
; )

; ;; Test case 06: Testing updateAttentionalFocus by changing values of saved atom
!(setAv G (6.0 25.0 35.0))


!(test (isAtomInAf G) False)

; !(let $x 
;     (getAfAtoms) 
;     (test 
;         (subtraction 
;             (superpose $x) 
;             (superpose (G D B F (EvaluationLink a b) A (Hebbianlink (Hebbianlink Cat Human) Animal) C))
;         ) 
;         (empty)
;     )
; )
; ; Test case 07: Testing updateAttentionalFocus adding an atom without AV 

; ; !(assertEqual (updateAttentionalFocus L) False)
; ; !(assertEqual (getAtomList) (a d c A B C D F (EvaluationLink a b) (Hebbianlink (Hebbianlink Cat Human) Animal) G))

; ; ; Test case 09: Testing getRandomAtomNotInAF assure that only one atom is returned
!(let $a (collapse (getRandomAtomNotInAF)) (test (isAtomInAf $a) False))

; ; Test case 10: Testing getAfMaxSTI
!(test (getAllMaxSTI (getAfAtoms)) 200.0)
