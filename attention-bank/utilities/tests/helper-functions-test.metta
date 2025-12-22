!(import! &self ../../../../PeTTa/lib/lib_he)
!(import! &self ../../../../metta-attention/attention-bank/utilities/helper-functions)
!(import! &self ../../../../metta-attention/attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../../../metta-attention/attention-bank/attention-value/getter-and-setter)
!(import! &self ../../../../metta-attention/attention-bank/bank/importance-index/importance-index)

!(test (filter ((c)(a)(f h j k)(s c)(g j)(d)()()) notEmpty) ((c)(a)(f h j k)(s c)(g j)(d)))

!(test (filter (()()) notEmpty) ())

;!(test (size ((3 (c)) (1 (a)) (37 (f h j k)) (17 (s c)) (18 (g j)) (2 (d)))) 6)
;!(test (size ()) 0)

;! (test (Max (1 2 3 17 18 37)) 37)
;! (test (Max (34 22 1 17 18 107)) 107)

;! (test (Min (34 22 1 17 18 107)) 1)
;! (test (Min (1 2 3 17 18 37)) 1)


!(test (removeDuplicates (a a d c)) (a d c))
!(test (removeDuplicates (a a)) (a))
!(test (flattener ((s c) (G E) (a) (g) (f h j k) (d))) (s c G E a g f h j k d))
!(test (reverseExpr (a b c d)) (d c b a))
!(test (reverseExpr ()) ())

!(test (sorter (4 9 2 6 1)) (1 2 4 6 9))