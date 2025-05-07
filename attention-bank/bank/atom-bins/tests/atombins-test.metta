!(register-module! ../../../../../metta-attention)
!(import! &self metta-attention:attention:agents:mettaAgents:AttentionParam) 
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:atom-bins:get-min-max-content)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)

;################ Preparation: inserting atoms for testing ####################

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
!  (setAv (Hebbianlink (Hebbianlink Animal Human) (Hebbianlink Animal Cat)) (200 200 0))

; Prep: Creating a predicate function to test getContentIf
;;; Descripton: an Example predicate function to check if atoms STI is between a range
;;; params:
;;; 	$x: an atom to be checked using predicte function
;;;		$lower: The lower bound of the Atoms STI
;;;		$higher: The upper bound of the Atoms STI
;;; return: True if atom STI is in range of $lower and $higer else false
;(: pred (-> Symbol Number Number Bool))
(= (pred $x $lower $higher)
	(let $sti (getSTI $x) 
      (and 
        (>=  $sti $lower) 
        (<=  $sti $higher)
      )
  )
)

;################################### Testing ###################################

; Test case 01: Tesing that the getRandomAtom function returns one result
! (let $res (collapse (getRandomAtom)) (assertEqual (size-atom $res) 1))

; Test case 02: Testing getContentIf function using pred as a predicate function
!(assertEqual (getContentIf 1 pred 0 10 (collapseAtomBin &atombin) ()) (a))
!(assertEqual (getContentIf 2 pred 0 10 (collapseAtomBin &atombin) (a)) (a d))
!(assertEqual (getContentIf 17 pred 250 350 (collapseAtomBin &atombin) (a)) (a (EvaluationLink a b)))
!(assertEqual (getContentIf 12 pred 0 10 (collapseAtomBin &atombin) ()) ())


; Test case 03: Testing getContent by retriveing values from the atombin space
!(assertEqual (getContent 2 (collapseAtomBin &atombin) (a b)) (a b d Animal (Hebbianlink (Hebbianlink Human Cat) Animal)))
!(assertEqual (getContent 1 (collapseAtomBin &atombin) ()) (a Cat (Hebbianlink Human Cat)))
!(assertEqual (getContent 12 (collapseAtomBin &atombin) ()) ())

; Test case 04: Testing insertAtom can insert atom into the specifed empty index 
!(setAv  E (200 200 0))
!(insertAtom  45 E)
!(assertEqual (match &atombin (45 $x) $x) (E)) 

; Test case 05: Testing insertAtom can insert an atom into the specified non-empty index
!(setAv H (200 200 0))
!(insertAtom  45 H)
!(assertEqual (match &atombin (45 $x) $x) (H E))

!(insertAtom  45 (EvaluationLink a b))
!(assertEqual (match &atombin (45 $x) $x) ((EvaluationLink a b) H E))



;: Test case 08: Testing remove_atom_helper can remove an atom or expression from a list of atoms and expressions
!(assertEqual (removehelp G (E  H Y G J K L)) (L K J Y H E))
!(assertEqual (removehelp G (J K L)) (L K J)) ; remove atom that is not present
!(assertEqual (removehelp G ()) ()) ; remove from empty list
!(assertEqual (removehelp G (L K J (Hebbianlink Human Dog))) ((Hebbianlink Human Dog) J K L)) ; remove atom from list containing expression
!(assertEqual (removehelp (Hebbianlink Human Dog) ((Hebbianlink Human Dog) G J K L)) (L K J G)) ; remove expression from list containing expression

; Test case 09: Testing removeAtom can remove an Atom from an index in the atomBin
!(assertEqual (removeAtom 3 m) ("Atom Removed"))
!(assertEqual (collapse (match &atombin  (3 $x) $x)) ())
!(assertEqual (removeAtom  45 H) ("Atom Removed"))
!(assertEqual (match &atombin  (45 $x) $x) (E (EvaluationLink a b)))
!(assertEqual (removeAtom 29 c) ("Bin is empty"))
!(assertEqual (removeAtom 1 a) ("Atom Removed"))
!(assertEqual (match &atombin  (1 $x) $x) ((Hebbianlink Human Cat) Cat))
!(assertEqual (removeAtom 1 (Hebbianlink Human Dog)) ("Atom Removed"))

; Test case 10: Testing removeAtom to remove an atom not present in the specified index
!(assertEqual (removeAtom  45 L) ("Atom is not valid"))

; Test case 06: Testing intertAtom with an Expression
!(setAv (Hebbianlink Human Dog) (200 200 0))
!(insertAtom 45 (Hebbianlink Human Dog))
!(assertEqual (match &atombin  (45 $x) $x) ((Hebbianlink Human Dog) E (EvaluationLink a b)))
