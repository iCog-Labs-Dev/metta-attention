!(register-module! ../../../attention-bank)
!(import! &self attention-bank:utilities:helper-functions)
!(import! &self attention-bank:bank:importance-index/importance-index)

!(assertEqual (notEmpty (1 2 3 ())) (1 2 3))
!(assertEqual 
              (filter ((c)(a)(f h j k)(s c)(g j)(d)()) notEmpty) 
              ((c)(a)(f h j k)(s c)(g j)(d))
)

!(assertEqual (filter (()()) notEmpty) ())

!(assertEqual (removeDuplicates (a a d c)) (a d c))
!(assertEqual (removeDuplicates (a a)) (a))


!(flatten ((s c) (G E) (a) (g) (f h j k) (d)))
!(assertEqual (findGroup 0 0 0) 0)
!(assertEqual (findGroup 1 0 0) 1)
!(assertEqual (findGroup 2 0 0) 2)
!(assertEqual (findGroup 3 0 0) 2)
!(assertEqual (findGroup 4 0 0) 3)

!(assertEqual (findGroup 50 0 0) 6)
!(assertEqual (findGroup 500 0 0) 9)
!(assertEqual (findGroup 5000 0 0) 12)
