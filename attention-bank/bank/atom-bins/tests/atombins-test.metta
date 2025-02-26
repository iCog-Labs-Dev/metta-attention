!(register-module! ../../../../../metta-attention)

!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &test-kb metta-attention:attention-bank:bank:atom-bins:tests:test-kb)
!(import! &self metta-attention:attention-bank:bank:atom-bins:get-min-max-content)

!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)

!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)

!(import! &self metta-attention:attention-bank:utilities:helper-functions)

!(add-atom &atombin (1 (a)))
!(add-atom &atombin (2 (d)))
!(add-atom &atombin (17 (s c)))
!(add-atom &atombin (18 (g)))
!(add-atom &atombin (37 (f h j k)))

!(let $res (collapse (getRandomAtom)) (assertEqual (size $res) 1))
;
;;; Example Predicate function
;(: pred (-> Symbol Number Number Bool))
(= (pred $x $lower $higher $space) (
    let $sti (getSTI (getType $space $x)) 
      (and 
        (>=  $sti $lower) 
        (<=  $sti $higher)
      )
  )
)

!(assertEqual (getContentIf 2 pred 0 10 (a) &test-kb) (a d))
!(assertEqual (getContentIf 1 pred 0 10 () &test-kb) (a))
!(assertEqual (getContent 2 (collapseAtomBin &atombin) (a b) ) (a b d))
!(assertEqual (getContent 1 (collapseAtomBin &atombin) ()) (a))
!(insertAtom 45 E &test-kb)
!(assertEqual (match &atombin (45 $x) $x) (E)) 
!(getAV (getType &test-kb G))
!(insertAtom 45 G &test-kb)
!(assertEqual (match &atombin (45 $x) $x) (G E))
!(insertAtom 45 H &test-kb)
!(assertEqual (match &atombin  (45 $x) $x) (H G E))

!(assertEqual (insertAtom 20 f &test-kb) ("Atom is not valid")) 
!(assertEqual (remove_atom_helper G (E  H Y G J K L)) (E H Y J K L))
!(assertEqual (remove_atom_helper G (G J K L)) (J K L))
!(removeAtom 45 H &test-kb)
!(assertEqual (match &atombin  (45 $x) $x) (G E))
!(assertEqual (removeAtom  45 L &test-kb) ("Atom is not valid"))
!(addAtomToAF a &test-kb)
!(addAtomToAF d &test-kb)
