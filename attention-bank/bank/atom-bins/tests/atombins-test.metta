!(register-module! ../../../../../metta-attention)

!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:atom-bins:get-min-max-content)

!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)

!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)

!(import! &self metta-attention:attention-bank:utilities:helper-functions)


;
!(add-atom &atombin (1 (a)))
!(add-atom &atombin (2 (d)))
!(add-atom &atombin (17 (s c)))
!(add-atom &atombin (18 (g)))
!(add-atom &atombin (37 (f h j k)))
!(setAv a (0.0 0.0 0.0))
!(setAv d (7.0 4.0 0.0))
!(setAv c (0.0 0.0 0.0))

!(let $res (collapse (getRandomAtom)) (assertEqual (size-atom $res) 1))
;
;;; Example Predicate function
;(: pred (-> Symbol Number Number Bool))
(= (pred $x $lower $higher) (
    let $sti (getSTI $x) 
      (and 
        (>=  $sti $lower) 
        (<=  $sti $higher)
      )
  )
)
!(assertEqual (getContentIf 2 pred 0 10 (collapseAtomBin &atombin) (a)) (a d))
!(assertEqual (getContentIf 1 pred 0 10 (collapseAtomBin &atombin)()) (a))
!(assertEqual (getContent 2 (collapseAtomBin &atombin) (a b)) (a b d))
!(assertEqual (getContent 1 (collapseAtomBin &atombin) ()) (a))

!(setAv  E (200 200 0))
!(insertAtom  45 E)
!(assertEqual (match &atombin (45 $x) $x) (E)) 
!(setAv G (200 200 0))
!(insertAtom  45 G)
!(assertEqual (match &atombin (45 $x) $x) (G E))
!(setAv H (200 200 0))
!(insertAtom 45 H)
!(assertEqual (match &atombin  (45 $x) $x) (H G E))
!(assertEqual (insertAtom 20 f) ("Atom is not valid")) 
!(assertEqual (remove_atom_helper G (E  H Y G J K L)) (E H Y J K L))
!(assertEqual (remove_atom_helper G (G J K L)) (J K L))
!(removeAtom  45 H)
!(assertEqual (match &atombin  (45 $x) $x) (G E))
!(assertEqual (removeAtom  45 L) ("Atom is not valid"))
!(addAtomToAF a)
!(addAtomToAF d)
