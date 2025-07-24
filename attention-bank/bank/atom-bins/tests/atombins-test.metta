!(register-module! ../../../../../metta-attention)
!(import! &self metta-attention:attention:AttentionParam) 
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:atom-bins:get-min-max-content)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)

;################ Preparation: inserting atoms for testing ####################
; Prep: Setting values in the atombin space prior to testing
!(add-atom &atombin (1 (a Cat (Hebbianlink Human Cat))))
!(add-atom &atombin (2 (d Animal (Hebbianlink (Hebbianlink Human Cat) Animal))))
!(add-atom &atombin (3 (m)))
!(add-atom &atombin (17 (s c Human (EvaluationLink a b))))
!(add-atom &atombin (18 (g Dog)))
!(add-atom &atombin (37 (f h j k (Hebbianlink (Hebbianlink Animal Human) (Hebbianlink Animal Cat)))))
!(trunc-math 50)
: Prep: Setting Attentionvalue for the below symobls
!(setAv a (0.0 0.0 0.0))
!(setAv c (7.0 4.0 0.0))
!(setAv d (0.0 0.0 0.0))
!(setAv m (3.0 0.0 0.0))

; Prep: setting Attentionvalue for Symobls with multiple characters
!(setAv Cat (400 400 1))  
!(setAv Animal (40 40 1))
!(setAv Human (40 40 1))
!(setAv Dog (30 40 1))
!(setAv Hebbianlink (30 40 1))


; Prep: Setting Attentionvalue for Expressions
! (setAv (EvaluationLink a b) (300 200 0))
! (setAv (Hebbianlink Human Cat) (200 200 0))
! (setAv  (Hebbianlink Human Dog) (200 20 0))
! (setAv (Hebbianlink (Hebbianlink Human Cat) Animal) (300 200 0))
! (setAv (Hebbianlink (Hebbianlink Animal Human) (Hebbianlink Animal Cat)) (200 200 0))
!(setAv  E (200 200 0))



;################################### Testing ###################################

; Test case 01: Tesing that the getRandomAtom function returns one result
! (let $res (collapse (getRandomAtom)) (assertEqual (size-atom $res) 1))

; Test case 04: Testing insertAtom can insert atom into the specifed empty index 

!(assertEqual (insertAtom  20.0 E) True)
!(assertEqual (match &atombin (20.0 $x) $x) (E)) 

; Test case 05: Testing insertAtom can insert an atom into the specified non-empty index
!(setAv H (200 200 0))
!(insertAtom  20.0 H)
!(assertEqual (match &atombin (20.0 $x) $x) (H E))

; Test case 06: Testing insertAtom can insert an Expression into the specified non-empty index
!(insertAtom  20.0 (EvaluationLink a b))
!(assertEqual (match &atombin (20.0 $x) $x) ((EvaluationLink a b) H E))



;: Test case 07: Testing remove_atom_helper can remove an atom or expression from a list of atoms and expressions
!(assertEqual (removeAtomHelper G (E  H Y G J K L)) (L K J Y H E))
!(assertEqual (removeAtomHelper G (J K L)) (L K J)) ; remove atom that is not present
!(assertEqual (removeAtomHelper G ()) ()) ; remove from empty list
!(assertEqual (removeAtomHelper G (L K J (Hebbianlink Human Dog))) ((Hebbianlink Human Dog) J K L)) ; remove atom from list containing expression
!(assertEqual (removeAtomHelper (Hebbianlink Human Dog) ((Hebbianlink Human Dog) G J K L)) (L K J G)) ; remove expression from list containing expression

; Test case 08: Testing removeAtom can remove an Atom from an index in the atomBin
!(assertEqual (removeAtom 3 m) True)
!(assertEqual (collapse (match &atombin  (3 $x) $x)) ())
!(assertEqual (removeAtom  20.0 H) True)
!(assertEqual (match &atombin  (20.0 $x) $x) (E (EvaluationLink a b)))
!(assertEqual (removeAtom 29 c) False)
!(assertEqual (removeAtom 1 a) True)
!(assertEqual (match &atombin  (1 $x) $x) ((Hebbianlink Human Cat) Cat))
!(assertEqual (removeAtom 1 (Hebbianlink Human Cat)) True)

; Test case 09: Testing removeAtom to remove an atom not present in the specified index
!(assertEqual (removeAtom  45 L) False)

; Test case 10: Testing intertAtom with an Expression and see that it checks if the atom is already inserted
!(setAv (Hebbianlink Human Dog) (200 200 0))
!(assertEqual (insertAtom 45.0 (Hebbianlink Human Dog)) False)
