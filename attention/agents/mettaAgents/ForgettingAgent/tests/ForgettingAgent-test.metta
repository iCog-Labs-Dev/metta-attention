!(register-module! ../../../../../../metta-attention)
!(import! &self metta-attention:attention:agents:mettaAgents:ForgettingAgent:ForgettingAgent)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)

!(stimulate a 0.02)
!(stimulate b 0)
!(stimulate c 0.2)
!(stimulate d 2)
!(stimulate e 5)
!(stimulate A 3)
!(stimulate B 0.3)
!(stimulate C 10)
!(stimulate D 7)
!(stimulate F 0.12)
!(stimulate G 17)
!(stimulate H 18)
!(stimulate I 12)
!(stimulate (ASYMMETRIC_HEBBIAN_LINK A a) 12)
!(stimulate (ASYMMETRIC_HEBBIAN_LINK A F) 2)
!(stimulate (ASYMMETRIC_HEBBIAN_LINK A C) 13)
!(stimulate (habbianlink a A) 8)
!(stimulate (PlusLink A F) 0.1)
!(stimulate (PlusLink A a) 10)

; check if atoms have been added to the space
!(assertEqual (let $a (collapseBin (AtomBin)) (size-atom $a)) 19)

; test ForgettingLTIThenTVAscendingSort sorts by LTI
!(assertEqual (ForgettingLTIThenTVAscendingSort (collapseBin (AtomBin)))
	(b a (PlusLink A F) F c B (ASYMMETRIC_HEBBIAN_LINK A F) d A e D (habbianlink a A) (PlusLink A a) C (ASYMMETRIC_HEBBIAN_LINK A a) I (ASYMMETRIC_HEBBIAN_LINK A C) G H))

: Test filteredatom
!(assertEqual (let $a (filterByLti (collapseBin (AtomBin))) (size-atom $a)) 5)
!(forgettingAgent-Run (AtomBin))

(let $atoms 
		(collapse (get-atoms &attentionalFocus)) 
		(assertEqual $atoms (a d e A B C D G I (ASYMMETRIC_HEBBIAN_LINK A a) (ASYMMETRIC_HEBBIAN_LINK A C) (habbianlink a A) (PlusLink A a)))
)

!(assertEqual (let $atoms (collapse (get-atoms &attentionalFocus)) (size-atom $atoms)) 14) 
!(let*
	(
		($rmvspace (getAtomsInRemoveSpace))	
		($typspace (getAtomsInTypeSpace))
	)
	(intersection-atom $typspace $rmvspace)
)

