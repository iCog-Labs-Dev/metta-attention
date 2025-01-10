!(register-module! ../../../metta-attention)
!(import! &self metta-attention:attention-bank:bank:get-min-max-content)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)


! (assertEqual (getMaxContent) (f h j k))
! (assertEqual (getMinContent) (a))
! (assertEqual (Max (1 2 3 17 18 37)) 37)


! (assertEqual (getSize 1) 1)
! (assertEqual (getSize 17) 2)
! (assertEqual (getSize 37) 4)