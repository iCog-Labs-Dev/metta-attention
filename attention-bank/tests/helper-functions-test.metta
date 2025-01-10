!(register-module! ../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:bank:atombins)

(: notEmpty (-> Expression Bool))
(= (notEmpty ($x $y)) (> (size $y 0) 0 ))

!(assertEqual 
              (filter ((3 (c)) (1 (a)) (37 (f h j k)) (17 (s c)) (18 (g j)) (2 (d)) (27 ())) notEmpty) 
              ((3 (c)) (1 (a)) (37 (f h j k)) (17 (s c)) (18 (g j)) (2 (d)))
)
!(assertEqual (filter ((1 ()) (2 ())) notEmpty) ())

!(assertEqual (size ((3 (c)) (1 (a)) (37 (f h j k)) (17 (s c)) (18 (g j)) (2 (d))) 0) 6)
!(assertEqual (size () 0) 0)
