!(register-module! ../../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)

;!(assertEqual 
;              (filter ((3 (c)) (1 (a)) (37 (f h j k)) (17 (s c)) (18 (g j)) (2 (d)) (27 ())) notEmpty) 
;              ((3 (c)) (1 (a)) (37 (f h j k)) (17 (s c)) (18 (g j)) (2 (d)))
;)
;
;!(assertEqual (filter ((1 ()) (2 ())) notEmpty) ())

;!(assertEqual (size ((3 (c)) (1 (a)) (37 (f h j k)) (17 (s c)) (18 (g j)) (2 (d)))) 6)
;!(assertEqual (size ()) 0)

;! (assertEqual (Max (1 2 3 17 18 37)) 37)
;! (assertEqual (Max (34 22 1 17 18 107)) 107)

;! (assertEqual (Min (34 22 1 17 18 107)) 1)
;! (assertEqual (Min (1 2 3 17 18 37)) 1)

!(assertEqual (valuesAtIndex 37 ((3 (c)) (1 (a)) (37 (f h j k)) (17 (s c)) (18 (g j)) (2 (d)))) (f h j k))
!(assertEqual (valuesAtIndex 17 ((3 (c)) (1 (a)) (37 (f h j k)) (17 (s c)) (18 (g j)) (2 (d)))) (s c))

;!(assertEqual (removeDuplicates (a a d c)) (c d a))
;!(assertEqual (removeDuplicates (a a)) (a))
;!(flatten ((s c) (G E) (a) (g) (f h j k) (d)))
;!(assertEqual(reverseExpr (a b c d)) (d c b a))
;!(assertEqual(reverseExpr ()) ())
;
;;test for the findMaxSTI and findMinSTI functions before that we need to set the values of the atoms
;! (setAv A (300 200 0))
;! (setAv B (200 400 1))
;! (setAv C (100 200 0))
;! (setAv D (600 400 1))
;! (setAv E (200 200 0))
;! (setAv F (800 400 1))
;! (setAv G (50 200 0))
;! (setAv H (900 400 1))
;
;!(findMaxSTI (A B C D E F G H))
;!(assertEqual (findMaxSTI (A B C D E F G H)) 900)
;!(findMinSTI (A B C D E F G H))
;!(assertEqual (findMinSTI (A B C D E F G H)) 50)
;
