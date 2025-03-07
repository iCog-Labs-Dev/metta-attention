!(register-module! ../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &self metta-attention:attention:ForgettingAgent)

(getAfMaxSTI)
!(setAv a (0.0 1.0 0.0))
!(setAv d (7.0 4.0 0.0))
!(setAv c (0.0 0.0 0.0))
!(setAv A (100.0 200.0 0.0))
!(setAv B (50.0 150.0 0.0))
!(setAv C (200.0 300.0 0.0))
!(setAv D (25.0 125.0 0.0))
!(setAv F (70.0 3.0 0.0))
!(setAv G (300.0 400.0 0.0))
!(setAv H (15.0 1.0 0.0))
!(setAv I (500.0 600.0 0.0))
!(addAtomToAF a)
!(addAtomToAF A)
!(addAtomToAF B)
!(addAtomToAF C)
!(addAtomToAF D)
!(addAtomToAF F)
!(addAtomToAF G)
!(addAtomToAF H)
!(addAtomToAF I)
!(add-atom (AtomBin) (0 (a b (habbianlink a A))))

; check if atoms have been added to the space
(assertEqual (getAtomList) (a A B C D F G H I))

; test ForgettingLTIThenTVAscendingSort sorts by LTI
(assertEqual (ForgettingLTIThenTVAscendingSort (getAtomList)) (a H F D B A C G I))

; Test the removeLinksfromList 
(assertEqual (removeLinksfromList (a A B C D F G H I (habbianlink a A))) (a A B C D F G H I))
(assertEqual (removeLinksfromList (a A B C D F G H I)) (a A B C D F G H I))

; test the forgetAtoms without ASYMMETRIC_HEBBIAN_LINK and check relevant spaces
(forgetAtoms (getAtomList))
(let $atoms (collapse (get-atoms &removeSpace)) (assertEqual $atoms (a H F)))
(let $atoms (collapse (get-atoms &attentionalFocus)) (assertEqual $atoms (A B C D F G H I)))

; Add links 
!(add-atom &attentionalFocus (habbianlink a A))
!(add-atom &attentionalFocus (PlusLink A F))
!(add-atom &attentionalFocus (PlusLink A a))
!(add-atom &attentionalFocus (ASYMMETRIC_HEBBIAN_LINK A a))
!(add-atom &attentionalFocus (ASYMMETRIC_HEBBIAN_LINK A F))
!(setAv (ASYMMETRIC_HEBBIAN_LINK A a) (10.0 10.0 0.0))
!(setAv (ASYMMETRIC_HEBBIAN_LINK A F) (20.0 10.0 0.0))
!(setAv (ASYMMETRIC_HEBBIAN_LINK A C) (20.0 10.0 0.0))

; Test forgetAtoms after inserting ASYMMETRIC_HEBBIAN_LINK
(getAtomList)
(ForgettingLTIThenTVAscendingSort (getAtomList))
(forgetAtoms (getAtomList))
(let $atoms 
		(collapse (get-atoms &removeSpace)) 
		(assertEqual $atoms ((ASYMMETRIC_HEBBIAN_LINK A a) a))
)

(let $atoms 
		(collapse (get-atoms &attentionalFocus)) 
		(assertEqual $atoms ((habbianlink a A) A B C D F G H I (PlusLink A F) (PlusLink A a) (ASYMMETRIC_HEBBIAN_LINK A a) (ASYMMETRIC_HEBBIAN_LINK A F)))
)
(test)
!(getAtomList)
(let $a (ForgettingLTIThenTVAscendingSort (getAtomList)) (checkThenRemoveAtom $a 9 0))
(checkThenRemoveAtom ((habbianlink a E) H a F) 9 0)

(here)
!(get-atoms &removeSpace)
(getAtomList)
(match (AtomBin) $x $x)
(removeAtom (importanceBin (getSTI a)) a) 
(removeAtomBin a 1)


 
(globalRemoveAtom a (getIncomingSetwithoutType $head))
(match (AtomBin) (0 $x) $x)

(setAv (ASYMMETRIC_HEBBIAN_LINK  (ASYMMETRIC_HEBBIAN_LINK A C) a) (12.0 11.0 0.0))
(geeetype)
(getType (link a d))
(getType (link a v))
(getType (link g v))
(getType (ASYMMETRIC_HEBBIAN_LINK A a))
(let $s (collapse (getType (ASYMMETRIC_HEBBIAN_LINK A a))) (size-atom $s))

(clpse)
(collapse (get-type (link a d)))
(collapse (get-type (link n g)))
(collapse (get-type (link a g)))
(collapse (get-type (ASYMMETRIC_HEBBIAN_LINK A a)))
(collapse (get-type (ASYMMETRIC_HEBBIAN_LINK  (ASYMMETRIC_HEBBIAN_LINK A C) a)))

!(getVlTypE)
!(getValueTypes a)
!(getValueType (link a d))
!(getType (link a d))
!(getValueTypes (link a d))
!(getStv (link a d))
(getValueTypes (link a v))
(getValueTypes (link g v))
(getValueType (ASYMMETRIC_HEBBIAN_LINK A a))
(getValueTypes (ASYMMETRIC_HEBBIAN_LINK A a))
(getValueType (ASYMMETRIC_HEBBIAN_LINK  (ASYMMETRIC_HEBBIAN_LINK A C) a))



(let $a (collapse (get-type (ASYMMETRIC_HEBBIAN_LINK A a))) (size-atom $a))
(let $a (collapse (get-type (ASYMMETRIC_HEBBIAN_LINK  (ASYMMETRIC_HEBBIAN_LINK A C) a))) (size-atom $a))

