!(register-module! ../../../metta-attention)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:bank:importance-index)
!(import! &self metta-attention:attention-bank:bank:atombins)


; Test atombins functions

!(setAv  E (200 200 0))
!(insertAtom  45 E)
!(assertEqual (match &atom-bin  (45 $x) $x) (E)) 
!(setAv G (200 200 0))
!(insertAtom  45 G)
!(assertEqual (match &atom-bin  (45 $x) $x) (G E))
!(setAv H (200 200 0))
!(insertAtom 45 H)
!(assertEqual (match &atom-bin  (45 $x) $x) (H G E))
!(assertEqual (insertAtom 20 f) (Atom is not valid)) 
!(assertEqual (remove_atom_helper G (E  H Y G J K L)) (E H Y J K L))
!(assertEqual (remove_atom_helper G (G J K L)) (J K L))
!(removeAtom  45 H)
!(assertEqual (match &atom-bin  (45 $x) $x) (G E))
!(assertEqual  (removeAtom  20 H) (Bin is empty))
!(assertEqual (removeAtom  45 L) (Atom is not valid))


