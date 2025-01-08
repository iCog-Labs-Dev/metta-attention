!(register-module! ../../../metta-attention)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:bank:importance-index)
!(import! &self metta-attention:attention-bank:bank:atombins)


; Test insertAtom function
!(setAv E (200 200 0))
!(setStv E (0.1 0))
!(get-type E)

;!(insertAtom E)
;!(assertEqual (match &atom-bin  (45 $x) $x) (E)) 
;!(setAv G (200 200 0))
;!(insertAtom G)
;!(assertEqual (match &atom-bin  (45 $x) $x) (G E))
;!(setAv H (200 200 0))
;!(insertAtom H)
;!(assertEqual (match &atom-bin  (45 $x) $x) (H G E))
;!(setAv f (200 200 0))
;!(insertAtom f)
;!(assertEqual (match &atom-bin  (45 $x) $x) (f H G E))
;!(assertEqual (remove_atom_helper G (E  H Y G J K L)) (E H Y J K L))
;!(assertEqual (remove_atom_helper G (G J K L)) (J K L))
;!(removeAtom  (45 H))
;!(assertEqual (match &atom-bin  (45 $x) $x) (f G E))
;!(assertEqual (removeAtom  (60 E)) (Bin is empty))
;!(assertEqual (match &atom-bin  (45 $x) $x) (f G E))


