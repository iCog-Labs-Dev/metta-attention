!(register-module! ../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)

##################### Prep: inserting Atoms in attentional focus ####################
; Test attentional focus
!(add-atom &atombin (1 (a)))
!(add-atom &atombin (2 (d)))
!(add-atom &atombin (17 (s c)))
!(add-atom &atombin (18 (g)))
!(add-atom &atombin (37 (f h j k)))
!(getAfMaxSTI)
!(setAv a (0.0 0.0 0.0))
!(setAv d (7.0 4.0 0.0))
!(setAv c (0.0 0.0 0.0))
!(setAv A (100.0 200.0 300.0))
!(setAv B (50.0 150.0 250.0))
!(setAv C (200.0 300.0 400.0))
!(setAv D (25.0 125.0 225.0))
!(setAv F (70.0 100.0 200.0))
!(addAtomToAF a)
!(addAtomToAF A)
!(addAtomToAF B)
!(addAtomToAF C)
!(addAtomToAF D)
!(addAtomToAF F)

; below two test cases fail due to the use of getType function introducing non-determinism
(addAtomToAF (EvaluationLink a b))
(addAtomToAF (Hebbianlink (Hebbianlink Cat Human) Animal))

################### Testing #################################

; Test case 01: Testing attentionalFocusSize asserting it returns correct number of atom in focus
!(assertEqual(attentionalFocusSize) 6)

; Test case 02: Testing atomIsInAF asserting it returns True for a given atom in AF
!(assertEqual (atomIsInAF C) True)

; Test case 03: Testin atomIsInAF asserting it return False foor a give atom not in AF
!(assertEqual (atomIsInAF Z) False)

; Test case 04: Testing sortAtomsBySti sorts atoms and returns sorted list
!(assertEqual (sortAtomsBySti  (getAtomList)) (a D B F A C))

; Test case 05: Testing getLowestStiAtomInAF returns an atom with lowest Sti
!(assertEqual (getLowestStiAtomInAF) a)

; Test case 06: Testing updateAttentionalFocus by adding new atom to attentional focus
!(setAv G (300.0 400.0 500.0))
!(assertEqual (updateAttentionalFocus G) ("Atom Added"))
!(assertEqual (getAtomList) (a A B C D F G))

; Test case 07: Testing updateAttentionalFocus by changing values of saved atom
!(setAv G (15.0 25.0 35.0))
!(assertEqual (updateAttentionalFocus G) ("Atom Added"))
!(assertEqual (getAtomList) (a A B C D F G))

; Test case 08: Testing updateAttentionalFocus adding an atom without AV 
!(assertEqual (updateAttentionalFocus L) ("Atom is not valid"))
!(assertEqual (getAtomList) (a A B C D F G))

; Test case 09; Testing sortAtomsBySti checking new order of atoms
!(assertEqual (sortAtomsBySti  (getAtomList)) (a G D B F A C))

; Test case 10: Testing getRandomAtomNotInAF assure that only one atom is returned
!(let $res (collapse (getRandomAtomNotInAF)) (assertEqual (size-atom $res) 1))
!(getRandomAtomNotInAF)

!(assertEqual(getAfMaxSTI) 200.0)
!(assertEqual(sortAtomsByStiDescending  (getAtomList)) (C A F B D G a))
;This should be removed temporary Population for test
 (habbianlink abebe kebede) 
!(add-atom &attentionalFocus (habbianlink challa abebe))
!(add-atom &attentionalFocus (PlusLink abebe kebede))

! (assertEqual (getIncomingSet abebe habbianlink) ((habbianlink challa abebe)))
! (assertEqual (nodeMatch (ConceptNode abebe) (ConceptNode abebe)) False) ;False snce (ConceptNode abebe) is not in the attentional focus

!(assertEqual (linkMatch (habbianlink challa abebe) (habbianlink challa abebe)) True)


!(add-atom &attentionalFocus ( CHOICE_LINK A B))
!(add-atom &attentionalFocus ( ORLink A B))
!(add-atom &attentionalFocus ( AndLink C D))

!(assertEqual (linkMatch (CHOICE_LINK A B ) (ORLink A B )) True) ; if choice_link return True 
!(assertEqual (linkMatch (ORLink A B ) (AndLink C D )) False) ; if first type differ return False 

!(add-atom &attentionalFocus (AndLink A B C  ))
!(add-atom &attentionalFocus (AndLink X Y  ))

!(assertEqual (tupleCount (AndLink A B C  )) 4)
!(assertEqual (tupleCount (AndLink X Y  )) 3)

!(assertEqual (getArity (AndLink A B C  )) 3)
!(assertEqual (getArity (AndLink X Y  )) 2)


!(assertEqual (termMatchMixinLinkMatch (AndLink A B C ) (AndLink X Y  ))False)

!(assertEqual (linkMatch (AndLink A B C ) (AndLink X Y  )) False)  ;arity is different

!(assertEqual (linkMatch (AndLink A B) (AndLink J C)) False) ; Atom not in AF


!(add-atom &attentionalFocus ( AndLink E F))

!(assertEqual (linkMatch (AndLink A B) (AndLink E F)) True) ;This works 

!(add-atom &attentionalFocus (SCOPE_LINK  $x $y ))
!(add-atom &attentionalFocus (SCOPE_LINK $z $w))


!(assertEqual (getVariables (SCOPE_LINK $x $y ) ) ($x ($y ()))) 
!(assertEqual (getVariables (SCOPE_LINK $z $w) )  ($z ($w ())))


!(assertEqual (linkMatch (SCOPE_LINK $x $y ) (SCOPE_LINK $z $w)) False) ;because of different variables
!(assertEqual (linkMatch (SCOPE_LINK $x $y ) (SCOPE_LINK $x $y)) True) ;because of same variables



