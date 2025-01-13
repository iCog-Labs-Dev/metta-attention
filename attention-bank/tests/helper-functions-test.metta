! (register-module! ../../../metta-attention) 
! (import! &self metta-attention:attention-bank:utilities:helper-functions)



! (assertEqual (Max (1 2 3 17 18 37)) 37)
! (assertEqual (Max (34 22 1 17 18 107)) 107)

! (assertEqual (Min (34 22 1 17 18 107)) 1)
! (assertEqual (Min (1 2 3 17 18 37)) 1)