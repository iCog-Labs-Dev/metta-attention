!(register-module! ../../../metta-attention)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)

! (set_av A (200 200 0))
! (set_av A (400 400 1))

! (set_stv A (0.1 0.9))
! (set_stv A (1 0.9))

! (assertEqual (get_stv A) (STV 1 0.9))
! (assertEqual (get_av A) (AV 400 400 1))

! (assertEqual (getMean A) 1)
! (assertEqual (getConfidence A) 0.9)
! (assertEqual (getSTI A) 400)
! (assertEqual (getLTI A) 400)
! (assertEqual (getVLTI A) 1)

