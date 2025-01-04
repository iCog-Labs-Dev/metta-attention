!(register-module! ../../../metta-attention)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:bank:importance-index)
!(import! &self metta-attention:attention-bank:bank:atombins)


; Test insertAtom function
!(set_av E (200 200 0))
!(insertAtom E)
!(assertEqual (match &atom-bin  (45 $x) $x) E) 
!(set_av G (200 200 0))
!(insertAtom G)
!(assertEqual (match &atom-bin  (45 $x) $x) (G E))