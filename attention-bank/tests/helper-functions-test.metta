!(register-module! ../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:bank:atombins)

!(assertEqual 
              (filter ((3 (c)) (1 (a)) (37 (f h j k)) (17 (s c)) (18 (g j)) (2 (d)) (27 ())) notEmpty ()) 
              ((3 (c)) (1 (a)) (37 (f h j k)) (17 (s c)) (18 (g j)) (2 (d)))
)

!(assertEqual (filter ((1 ()) (2 ())) notEmpty ()) ())

!(assertEqual (size ((3 (c)) (1 (a)) (37 (f h j k)) (17 (s c)) (18 (g j)) (2 (d)))) 6)
!(assertEqual (size ()) 0)

! (assertEqual (Max (1 2 3 17 18 37)) 37)
! (assertEqual (Max (34 22 1 17 18 107)) 107)

! (assertEqual (Min (34 22 1 17 18 107)) 1)
! (assertEqual (Min (1 2 3 17 18 37)) 1)
