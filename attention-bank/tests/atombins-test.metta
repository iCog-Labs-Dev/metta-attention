!(register-module! ../../../metta-attention)
!(import! &self metta-attention:attention-bank:bank:atombins)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:attention-bank)

!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:bank:get-min-max-content)

;
!(add-atom &atombin (1 (a)))
!(add-atom &atombin (2 (d)))
!(add-atom &atombin (3 (c)))
!(add-atom &atombin (17 (s c)))
!(add-atom &atombin (18 (g j)))
!(add-atom &atombin (37 (f h j k)))
!(setAv a (0 0 0))
!(setAv d (7 4 0))
!(setAv c (0 0 0))

!(let $res (collapse (getRandomAtom)) (assertEqual (size $res 0) 1))
;
;;; Example Predicate function
(= (pred $x) (
    let $sti (getSTI $x) 
      (and 
        (>=  $sti 0) 
        (<=  $sti 10)
      )
  )
)
!(setAv  E (200 200 0))
!(insertAtom  45 E)
!(assertEqual (match &atombin (45 $x) $x) (E)) 
!(setAv G (200 200 0))
!(insertAtom  45 G)
!(assertEqual (match &atombin (45 $x) $x) (G E))
!(setAv H (200 200 0))
!(insertAtom 45 H)
!(assertEqual (match &atombin  (45 $x) $x) (H G E))
!(assertEqual (insertAtom 20 f) (Atom is not valid)) 
!(assertEqual (remove_atom_helper G (E  H Y G J K L)) (E H Y J K L))
!(assertEqual (remove_atom_helper G (G J K L)) (J K L))
!(removeAtom  45 H)
!(assertEqual (match &atombin  (45 $x) $x) (G E))
!(assertEqual  (removeAtom  20 H) (Bin is empty))
!(assertEqual (removeAtom  45 L) (Atom is not valid))
!(assertEqual (getContentIf 2 pred ()) (d))
!(assertEqual (getContentIf 1 pred ()) (a))

!(assertEqual (getContent 2 ()) (d))
!(assertEqual (getContent 1 ()) (a))

!(assertEqual (valuesAtIndex 37 ((3 (c)) (1 (a)) (37 (f h j k)) (17 (s c)) (18 (g j)) (2 (d)))) (f h j k))
!(assertEqual (valuesAtIndex 17 ((3 (c)) (1 (a)) (37 (f h j k)) (17 (s c)) (18 (g j)) (2 (d)))) (s c))

