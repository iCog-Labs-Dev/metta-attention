!(register-module! ../../../../../metta-attention)
!(import! &self metta-attention:attention:agents:mettaAgents:AttentionParam)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
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


; Test case 04: Testing sortAtomsBySti sorts atoms and returns sorted list

!(assertEqual (sortAtomsBySti  (getAtomList)) (c a d D B F A (EvaluationLink a b) C (Hebbianlink (Hebbianlink Cat Human) Animal)))

; Test case 05: Testing getLowestStiAtomInAF returns an atom with lowest Sti

!(assertEqual (getLowestStiAtomInAF) a)


; Test case 06: Testing updateAttentionalFocus by adding new atom to attentional focus

!(setAv G (300.0 400.0 500.0))
!(assertEqual (updateAttentionalFocus G True) ("Atom Added"))
!(assertEqual (getAtomList) (a d c A B C D F (EvaluationLink a b) (Hebbianlink (Hebbianlink Cat Human) Animal) G))


; Test case 07: Testing updateAttentionalFocus by changing values of saved atom

!(setAv G (15.0 25.0 35.0))
!(assertEqual (updateAttentionalFocus G True) ("Atom Added"))
!(assertEqual (getAtomList) (a d c A B C D F (EvaluationLink a b) (Hebbianlink (Hebbianlink Cat Human) Animal) G))

; Test case 08: Testing updateAttentionalFocus adding an atom without AV 

!(assertEqual (updateAttentionalFocus L True) ("Atom is not valid"))
; !(assertEqual (getAtomList) (a A B C D F G))


; Test case 09; Testing sortAtomsBySti checking new order of atoms

!(assertEqual (sortAtomsBySti  (getAtomList)) (c a d G D B F A (EvaluationLink a b) C (Hebbianlink (Hebbianlink Cat Human) Animal)))


; Test case 10: Testing getRandomAtomNotInAF assure that only one atom is returned

!(let $res (collapse (getRandomAtomNotInAF)) (assertEqual (size-atom $res) 1))


; Test case 11: Testing getAfMaxSTI, lessthanSti and geraterequalsti to get the updated values

!(assertEqual (let $atoms (getAtomList)
(getAllMaxSTI $atoms)) 200.0)
!(assertEqual (lessThanSti B C) True)
!(assertEqual (greaterEqualSti B (Hebbianlink (Hebbianlink Cat Human) Animal)) False)

; Test case 12: Testing sortAtomsByStiDescending to check if it sorts atoms in descending STI

!(assertEqual(sortAtomsByStiDescending  (getAtomList)) ((Hebbianlink (Hebbianlink Cat Human) Animal) C (EvaluationLink a b) A F B D G d a c))


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


; Test case 13: Testing getIncomingSet function 
!(assertEqual (getIncomingSet abebe habbianlink) ((habbianlink abebe kebede) (habbianlink challa abebe)))


; Test case 14: Testing nodeMatch against values in and out of attentionalFocus 

!(assertEqual (nodeMatch  (PlusLink abebe kebede) (PlusLink abebe kebede)) True) 
!(assertEqual (nodeMatch  (PlusLink abebe kebede) (PlusLink kebede abebe)) False) 
!(assertEqual (nodeMatch (ConceptNode abebe) (ConceptNode abebe)) False)
!(assertEqual (nodeMatch () ()) False)


; Test case 15: Testing linkMatch

!(assertEqual (linkMatch (habbianlink challa abebe) (habbianlink challa abebe)) True)
!(assertEqual (linkMatch (CHOICE_LINK A B ) (ORLink A B )) True) ; if choice_link return True 
!(assertEqual (linkMatch (ORLink A B ) (AndLink C D )) False) ; if first type differ return False 
!(assertEqual (linkMatch (AndLink A B C ) (AndLink X Y  )) False)  ;arity is different
!(assertEqual (linkMatch (AndLink A B) (AndLink J C)) False) ; Atom not in AF
!(assertEqual (linkMatch (AndLink A B) (AndLink E F)) True) ;This works 
!(assertEqual (linkMatch (SCOPE_LINK $x $y ) (SCOPE_LINK $z $w)) False) ;because of different variables
!(assertEqual (linkMatch (SCOPE_LINK $x $y ) (SCOPE_LINK $x $y)) True) ;because of same variables


; Test case 16: Testing termMatchMixinLinkMatch using various links

!(assertEqual (termMatchMixinLinkMatch (a) (a)) True)
!(assertEqual (termMatchMixinLinkMatch (z) (z)) True)
!(assertEqual (termMatchMixinLinkMatch (a) (b)) False)
!(assertEqual (termMatchMixinLinkMatch (CHOICE_LINK A B) (a)) True)
!(assertEqual (termMatchMixinLinkMatch (a) (CHOICE_LINK A B)) False)
!(assertEqual (termMatchMixinLinkMatch (a b c) (a A B)) True)
!(assertEqual (termMatchMixinLinkMatch (SCOPE_LINK b c) (SCOPE_LINK A B)) True)
!(assertEqual (termMatchMixinLinkMatch (SCOPE_LINK $b c) (SCOPE_LINK A $B)) False)
!(assertEqual (termMatchMixinLinkMatch (SCOPE_LINK $b c) (SCOPE_LINK A $b)) True)
!(assertEqual (termMatchMixinLinkMatch (SCOPE_LINK $b c) (SCOPE_LINK A $b)) True)


; Test case 17: Testing tupleCount Function

!(assertEqual (tupleCount (AndLink A B C)) 4)
!(assertEqual (tupleCount (AndLink)) 1)
!(assertEqual (tupleCount ()) 0)


; Test case 18: Testing getArity Function 

!(assertEqual (getArity (AndLink A B C)) 3)
!(assertEqual (getArity (AndLink X Y)) 2)
!(assertEqual (getArity ()) 0)


; Test case 19: Testing getVariables with different list inputs

!(assertEqual (getVariables (SCOPE_LINK $x $y ) ) ($x ($y ()))) 
!(assertEqual (getVariables (SCOPE_LINK $z $w) )  ($z ($w ())))
!(assertEqual (getVariables (SCOPE_LINK z w) )  ())
!(assertEqual (getVariables ())  ())


;Test case 20: Testing filterLinksInAF method

!(assertEqual (filterLinksInAF ((Hebbianlink (Hebbianlink Cat Human) Animal) (Hebbianlink (Hebbianlink Cat Human) Dog) (EvaluationLink a b))) ((Hebbianlink (Hebbianlink Cat Human) Animal) (emtpy) (EvaluationLink a b)))