!(import! &self ../../../../PeTTa/lib/lib_he)
!(import! &self ../../../../metta-attention/attention-bank/utilities/helper-functions)
!(import! &self ../../../../metta-attention/attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../../../metta-attention/attention-bank/attention-value/getter-and-setter)
!(import! &self ../../../../metta-attention/attention-bank/bank/importance-index/importance-index)

!(assertEqual (filter ((c)(a)(f h j k)(s c)(g j)(d)()()) notEmpty) ((c)(a)(f h j k)(s c)(g j)(d)))

!(assertEqual (filter (()()) notEmpty) ())

;!(assertEqual (size ((3 (c)) (1 (a)) (37 (f h j k)) (17 (s c)) (18 (g j)) (2 (d)))) 6)
;!(assertEqual (size ()) 0)

;! (assertEqual (Max (1 2 3 17 18 37)) 37)
;! (assertEqual (Max (34 22 1 17 18 107)) 107)

;! (assertEqual (Min (34 22 1 17 18 107)) 1)
;! (assertEqual (Min (1 2 3 17 18 37)) 1)


!(assertEqual (removeDuplicates (a a d c)) (a d c))
!(assertEqual (removeDuplicates (a a)) (a))
!(assertEqual (flattener ((s c) (G E) (a) (g) (f h j k) (d))) (s c G E a g f h j k d))
!(assertEqual(reverseExpr (a b c d)) (d c b a))
!(assertEqual(reverseExpr ()) ())

!(assertEqual (findGroup 0 0 0) 0)
!(assertEqual (findGroup 1 0 0) 1)
!(assertEqual (findGroup 2 0 0) 2)
!(assertEqual (findGroup 3 0 0) 2)
!(assertEqual (findGroup 4 0 0) 3)

!(assertEqual (findGroup 50 0 0) 6)
!(assertEqual (findGroup 500 0 0) 9)
!(assertEqual (findGroup 5000 0 0) 12)
!(assertEqual (sorter (4 9 2 6 1)) (1 2 4 6 9))

