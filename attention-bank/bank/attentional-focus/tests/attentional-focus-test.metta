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

(assertEqual (sortAtomsBySti  (getAtomList)) (a A B C D F))


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


; Test case 11: Testing getAfMaxSTI to get the updated max STI

!(assertEqual(getAfMaxSTI) 200.0)


; Test case 12: Testing sortAtomsByStiDescending to check if it sorts atoms in descending STI

!(assertEqual(sortAtomsByStiDescending  (getAtomList)) (C A F B D G a))


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


########################### Testing ##################################


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


; Test casae 19: Testing getVariables with different list inputs

!(assertEqual (getVariables (SCOPE_LINK $x $y ) ) ($x ($y ()))) 
!(assertEqual (getVariables (SCOPE_LINK $z $w) )  ($z ($w ())))
!(assertEqual (getVariables (SCOPE_LINK z w) )  ())
!(assertEqual (getVariables ())  ())