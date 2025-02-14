!(register-module! ../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:bank:atom-bins:get-min-max-content)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)

!(import! &self metta-attention:attention-bank:utilities:helper-functions)


!(add-atom &atombin (1 (a)))
!(add-atom &atombin (2 (d)))
!(add-atom &atombin (3 (c)))
!(add-atom &atombin (17 (s c)))
!(add-atom &atombin (18 (g j)))
!(add-atom &atombin (37 (f h j k)))

! (assertEqual (getMaxContent) (f h j k))
! (assertEqual (getMinContent) (a))
;! (assertEqual (Max (1 2 3 17 18 37)) 37)

! (assertEqual (getSize 1) 1)
! (assertEqual (getSize 17) 2)
! (assertEqual (getSize 37) 4)
! (assertEqual (binSize) 11)
