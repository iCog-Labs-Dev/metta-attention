!(register-module! ../../../metta-attention)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)

! (setAv A (200 200 0))
! (setAv A (400 400 1))

! (setStv A (0.1 0.9))
! (setStv A (1 0.9))
!(get-type A)

! (assertEqual (getStv A) (STV 1 0.9))
! (assertEqual (getAv A) (AV 400 400 1))

! (assertEqual (getMean A) 1)
! (assertEqual (getConfidence A) 0.9)
! (assertEqual (getSTI A) 400)
! (assertEqual (getLTI A) 400)
! (assertEqual (getVLTI A) 1)

