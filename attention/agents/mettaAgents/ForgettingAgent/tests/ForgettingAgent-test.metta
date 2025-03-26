!(register-module! ../../../../../../metta-attention)
!(import! &self metta-attention:attention:agents:mettaAgents:ForgettingAgent:ForgettingAgent)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)

!(getAfMaxSTI)
!(setAv a (0.0 1.0 0.0))
!(setAv b (7.0 4.0 0.0))
!(setAv c (0.0 0.0 0.0))
!(setStv d (0.1 0.2))
!(setStv e (0.2 0.3))
!(setAv A (100.0 200.0 0.0))
!(setAv B (50.0 150.0 0.0))
!(setAv C (200.0 300.0 0.0))
!(setAv D (25.0 125.0 0.0))
!(setAv F (70.0 3.0 0.0))
!(setAv G (300.0 400.0 0.0))
!(setAv H (15.0 1.0 0.0))
!(setAv I (500.0 600.0 0.0))
!(setAv (ASYMMETRIC_HEBBIAN_LINK A a) (10.0 10.0 0.0))
!(setAv (ASYMMETRIC_HEBBIAN_LINK A F) (20.0 10.0 0.0))
!(setAv (ASYMMETRIC_HEBBIAN_LINK A C) (20.0 10.0 0.0))
!(setAv (habbianlink a A) (21.0 10.0 0.0))
!(setAv (PlusLink A F) (22.0 2.0 0.0))
!(setAv (PlusLink A a) (23.0 10.0 0.0))
!(addAtomToAF a)
!(addAtomToAF A)
!(addAtomToAF B)
!(addAtomToAF C)
!(addAtomToAF D)
!(addAtomToAF F)
!(addAtomToAF G)
!(addAtomToAF H)
!(addAtomToAF I)
!(addAtomToAF (habbianlink a A))
!(addAtomToAF (PlusLink A F))
!(addAtomToAF (PlusLink A a))
!(addAtomToAF (ASYMMETRIC_HEBBIAN_LINK A a))
!(addAtomToAF (ASYMMETRIC_HEBBIAN_LINK A F))
!(add-atom (AtomBin) (0 (a b H)))
!(add-atom (AtomBin) (19.0 ((habbianlink a A))))

; check if atoms have been added to the space
!(assertEqual (getAtomsInTypeSpace) 
	(a b c d e A B C D F G H I (ASYMMETRIC_HEBBIAN_LINK A a) (ASYMMETRIC_HEBBIAN_LINK A F) (ASYMMETRIC_HEBBIAN_LINK A C) (habbianlink a A) (PlusLink A F) (PlusLink A a)))

; test ForgettingLTIThenTVAscendingSort sorts by LTI
!(assertEqual (ForgettingLTIThenTVAscendingSort (getAtomsInTypeSpace))
	(c d e a H (PlusLink A F) F b (ASYMMETRIC_HEBBIAN_LINK A a) (ASYMMETRIC_HEBBIAN_LINK A F) (ASYMMETRIC_HEBBIAN_LINK A C) (habbianlink a A) (PlusLink A a) D B A C G I))

: Test filteredatom
!(assertEqual (filterByLti (getAtomsInTypeSpace)) (a b c d e F H (PlusLink A F)))

!(assertEqual (forgettingAgent-Run) ())
!(let $atoms 
	(collapse (get-atoms &removeSpace)) 
	(assertEqual $atoms 
		(
			(: c ((STV 0.0 0.0) (AV 0.0 0.0 0.0)))
			(: d ((STV 0.0 0.0) (AV 0.0 0.0 0.0)))
			(: e ((STV 0.0 0.0) (AV 0.0 0.0 0.0)))
			(: H ((STV 0.0 0.0) (AV 0.0 0.0 0.0)))
			(: (PlusLink A F) ((STV 0.0 0.0) (AV 0.0 0.0 0.0)))
			(: F ((STV 0.0 0.0) (AV 0.0 0.0 0.0)))
			(: (ASYMMETRIC_HEBBIAN_LINK A F) ((STV 0.0 0.0) (AV 0.0 0.0 0.0)))
			(: b ((STV 0.0 0.0) (AV 0.0 0.0 0.0)))
		)
	)
)

!(let $atoms 
		(collapse (get-atoms &attentionalFocus)) 
		(assertEqual $atoms (a A B C D G I (habbianlink a A) (PlusLink A a) (ASYMMETRIC_HEBBIAN_LINK A a)))
)

!(let*
	(
		($rmvspace (getAtomsInRemoveSpace))	
		($typspace (getAtomsInTypeSpace))
	)
	(intersection-atom $typspace $rmvspace)
)


