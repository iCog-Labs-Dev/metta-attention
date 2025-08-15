!(register-module! ../../../../../metta-attention)
!(import! &self metta-attention:attention:AttentionParam)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter-2)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)

; ##################### Prep: inserting Atoms in attentional focus ####################
; Test attentional focus
!(setAv a (1.0 0.0 0.0))
!(setAv d (7.0 4.0 0.0))
!(setAv c (0.0 0.0 0.0))
!(setAv A (100.0 200.0 300.0))
!(setAv B (50.0 150.0 250.0))
!(setAv C (200.0 300.0 400.0))
!(setAv D (25.0 125.0 225.0))
!(setAv F (70.0 100.0 200.0))
!(getAttentionParam MAX_AF_SIZE)
; The test cases were added with setting AV for links but this might not be needed in reality because AVs may not be set for links/expressions
!(setAv (EvaluationLink a b) (100.0 100.0 100.0))
!(setAv (Hebbianlink (Hebbianlink Cat Human) Animal) (200.0 250.0 280.0))


; ################### Testing #################################


; Test case 01: Testing attentionalFocusSize asserting it returns correct number of atom in focus

!(assertEqual(attentionalFocusSize) 10)


; Test case 02: Testing atomIsInAF asserting it returns True for a given atom in AF

!(assertEqual (atomIsInAF C) True)


; Testing same case for Link

!(assertEqual (atomIsInAF (EvaluationLink a b)) True)
!(assertEqual (atomIsInAF (Hebbianlink (Hebbianlink Cat Human) Animal)) True)


; Test case 03: Testin atomIsInAF asserting it return False foor a give atom not in AF

!(assertEqual (atomIsInAF Z) False)

; Test case 04: Testing getLowestStiAtomInAF returns an atom with lowest Sti

!(assertEqual (getLowestStiAtomInAF) c)


; Test case 05: Testing updateAttentionalFocus by adding new atom to attentional focus

!(setAv G (300.0 400.0 500.0))
!(assertEqual (updateAttentionalFocus G) True)
!(assertEqual (getAtomList) (a d c A B C D F (EvaluationLink a b) (Hebbianlink (Hebbianlink Cat Human) Animal) G))


; Test case 06: Testing updateAttentionalFocus by changing values of saved atom

!(setAv G (15.0 25.0 35.0))
!(assertEqual (updateAttentionalFocus G) True)
!(assertEqual (getAtomList) (a d c A B C D F (EvaluationLink a b) (Hebbianlink (Hebbianlink Cat Human) Animal) G))

; Test case 07: Testing updateAttentionalFocus adding an atom without AV 

!(assertEqual (updateAttentionalFocus L) False)
!(assertEqual (getAtomList) (a d c A B C D F (EvaluationLink a b) (Hebbianlink (Hebbianlink Cat Human) Animal) G))

; Test case 09: Testing getRandomAtomNotInAF assure that only one atom is returned

!(let $res (collapse (getRandomAtomNotInAF)) (assertEqual (size-atom $res) 1))


; Test case 10: Testing getAfMaxSTI

!(assertEqual (let $atoms (getAtomList) (getAllMaxSTI $atoms)) 200.0)

;################ Prep: adding to attensionalfocus space to test link match ####################

!(add-atom &attentionalFocus (habbianlink challa abebe))
!(add-atom &attentionalFocus (habbianlink abebe kebede))
!(add-atom &attentionalFocus (PlusLink abebe kebede))
!(habbianlink abebe challa) ; used to show getIncomingSet only searchs in attentionalFocus
!(add-atom &attentionalFocus ( CHOICE_LINK A B))
!(add-atom &attentionalFocus ( ORLink A B))
!(add-atom &attentionalFocus ( AndLink C D))
!(add-atom &attentionalFocus (AndLink A B C  ))
!(add-atom &attentionalFocus (AndLink X Y  ))
!(add-atom &attentionalFocus ( AndLink E F))
!(add-atom &attentionalFocus (SCOPE_LINK  $x $y ))
!(add-atom &attentionalFocus (SCOPE_LINK $z $w))


; ########################### Testing ##################################


; Test case 11: Testing getIncomingSet function 
!(assertEqual (getIncomingSetByType abebe habbianlink) ((habbianlink abebe kebede) (habbianlink challa abebe)))

