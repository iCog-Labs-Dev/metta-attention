!(register-module! ../../../../../../metta-attention)
!(import! &self metta-attention:attention:agents:mettaAgents:ForgettingAgent:ForgettingAgent)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)

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
!(add-atom &attentionalFocus (habbianlink a A))
!(add-atom &attentionalFocus (PlusLink A F))
!(add-atom &attentionalFocus (PlusLink A a))
!(add-atom &attentionalFocus (ASYMMETRIC_HEBBIAN_LINK A a))
!(add-atom &attentionalFocus (ASYMMETRIC_HEBBIAN_LINK A F))
!(setAv (ASYMMETRIC_HEBBIAN_LINK A a) (10.0 10.0 0.0))
!(setAv (ASYMMETRIC_HEBBIAN_LINK A F) (20.0 10.0 0.0))
!(setAv (ASYMMETRIC_HEBBIAN_LINK A C) (20.0 10.0 0.0))
!(add-atom (AtomBin) (0 (a b (habbianlink a A))))

; ; check if atoms have been added to the space
!(assertEqual (getAtomList) 
	(a d c A B C D F G H I (habbianlink a A) (PlusLink A F) (PlusLink A a) (ASYMMETRIC_HEBBIAN_LINK A a) (ASYMMETRIC_HEBBIAN_LINK A F) (ASYMMETRIC_HEBBIAN_LINK A C)))

; ; test ForgettingLTIThenTVAscendingSort sorts by LTI
!(assertEqual (ForgettingLTIThenTVAscendingSort (getAtomList))
 	(c (habbianlink a A) (PlusLink A F) (PlusLink A a) a H F d (ASYMMETRIC_HEBBIAN_LINK A a) (ASYMMETRIC_HEBBIAN_LINK A F) (ASYMMETRIC_HEBBIAN_LINK A C) D B A C G I))

; ; ; Test the removeLinksfromList 
 !(assertEqual (removeLinksfromList (a A B C D F G H I (habbianlink a A))) (a A B C D F G H I))
 !(assertEqual (removeLinksfromList (a A B C D F G H I)) (a A B C D F G H I))

; ; Add links 

; ; Test forgetAtoms after inserting ASYMMETRIC_HEBBIAN_LINK
!(forgetAtoms (getAtomList))
!(let $atoms 
 		(collapse (get-atoms &removeSpace)) 
		(assertEqual $atoms (c (habbianlink a A) (PlusLink A F) (PlusLink A a) a (ASYMMETRIC_HEBBIAN_LINK A a) H F (ASYMMETRIC_HEBBIAN_LINK A F) d))
 )

!(let $atoms 
		(collapse (get-atoms &attentionalFocus)) 
		(assertEqual $atoms (A B C D G I (ASYMMETRIC_HEBBIAN_LINK A C)))
)

