!(register-module! ../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &test-kb metta-attention:attention-bank:bank:attentional-focus:tests:test-kb)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)

; Test attentional focus
!(add-atom &atombin (1 (node_a)))
!(add-atom &atombin (2 (node_d)))
!(add-atom &atombin (17 (node_s node_c)))
!(add-atom &atombin (18 (node_g)))
!(add-atom &atombin (37 (node_f node_h node_j node_k)))
;!(getAfMaxSTI &test-kb)
!(addAtomToAF node_a &test-kb)
!(addAtomToAF node_A &test-kb)
!(addAtomToAF node_B &test-kb)
!(addAtomToAF node_C &test-kb)
!(addAtomToAF node_D &test-kb)
!(addAtomToAF node_F &test-kb)
;
!(assertEqual(attentionalFocusSize) 6)
!(assertEqual(atomIsInAF node_C) True)
!(assertEqual (sortAtomsBySti (getAtomList) &test-kb) (node_a node_D node_B node_F node_A node_C))
!(assertEqual (getLowestStiAtomInAF &test-kb) node_a)
!(updateAttentionalFocus node_G &test-kb) 
!(assertEqual (getAtomList) (node_a node_A node_B node_C node_D node_F node_G))
!(updateAttentionalFocus node_H &test-kb) 
!(assertEqual (getAtomList) (node_a node_A node_B node_C node_D node_F node_G node_H))

!(updateAttentionalFocus node_I &test-kb) 
!(setAV &test-kb node_A (600.0 200.0 300.0))
!(updateAttentionalFocus node_A &test-kb)

!(assertEqual (updateAttentionalFocus L &test-kb) ("Atom is not valid"))
!(assertEqual (getAtomList) (node_a node_A node_B node_C node_D node_F node_G node_H node_I))
!(assertEqual (sortAtomsBySti (getAtomList) &test-kb) (node_a node_H node_D node_B node_F node_C node_G node_I node_A))
!(let $res (collapse (getRandomAtomNotInAF)) (assertEqual (size $res) 1))

!(assertEqual(getAfMaxSTI &test-kb) 600.0)
;!(assertEqual(sortAtomsByStiDescending  (getAtomList)) (A I G C F B D H a))
;;This should be removed temporary Population for test
; (habbianlink abebe kebede) 
;!(add-atom &attentionalFocus (habbianlink challa abebe))
;!(add-atom &attentionalFocus (PlusLink abebe kebede))
;
;! (assertEqual (getIncomingSet abebe habbianlink) ((habbianlink challa abebe)))
;! (assertEqual (nodeMatch (ConceptNode abebe) (ConceptNode abebe)) False) ;False snce (ConceptNode abebe) is not in the attentional focus
;This should be removed temporary Population for test
; (habbianlink abebe kebede) 
;!(add-atom &attentionalFocus (habbianlink challa abebe))
;!(add-atom &attentionalFocus (PlusLink abebe kebede))
;
;! (assertEqual (getIncomingSet abebe habbianlink) ((habbianlink challa abebe)))
;! (assertEqual (nodeMatch (ConceptNode abebe) (ConceptNode abebe)) False) ;False snce (ConceptNode abebe) is not in the attentional focus
;
;!(assertEqual (linkMatch (habbianlink challa abebe) (habbianlink challa abebe)) True)
;
;
;!(add-atom &attentionalFocus ( CHOICE_LINK A B))
;!(add-atom &attentionalFocus ( ORLink A B))
;!(add-atom &attentionalFocus ( AndLink C D))
;
;!(assertEqual (linkMatch (CHOICE_LINK A B ) (ORLink A B )) True) ; if choice_link return True 
;!(assertEqual (linkMatch (ORLink A B ) (AndLink C D )) False) ; if first type differ return False 
;
;!(add-atom &attentionalFocus (AndLink A B C  ))
;!(add-atom &attentionalFocus (AndLink X Y  ))
;
;!(assertEqual (tupleCount (AndLink A B C  )) 4)
;!(assertEqual (tupleCount (AndLink X Y  )) 3)
;
;!(assertEqual (getArity (AndLink A B C  )) 3)
;!(assertEqual (getArity (AndLink X Y  )) 2)
;
;
;!(assertEqual (termMatchMixinLinkMatch (AndLink A B C ) (AndLink X Y  ))False)
;
;!(assertEqual (linkMatch (AndLink A B C ) (AndLink X Y  )) False)  ;arity is different
;
;!(assertEqual (linkMatch (AndLink A B) (AndLink J C)) False) ; Atom not in AF
;
;
;!(add-atom &attentionalFocus ( AndLink E F))
;
;!(assertEqual (linkMatch (AndLink A B) (AndLink E F)) True) ;This works 
;
;!(add-atom &attentionalFocus (SCOPE_LINK  $x $y ))
;!(add-atom &attentionalFocus (SCOPE_LINK $z $w))
;
;
;!(assertEqual (getVariables (SCOPE_LINK $x $y ) ) ($x ($y ()))) 
;!(assertEqual (getVariables (SCOPE_LINK $z $w) )  ($z ($w ())))
;
;
;!(assertEqual (linkMatch (SCOPE_LINK $x $y ) (SCOPE_LINK $z $w)) False) ;because of different variables
;!(assertEqual (linkMatch (SCOPE_LINK $x $y ) (SCOPE_LINK $x $y)) True) ;because of same variables
