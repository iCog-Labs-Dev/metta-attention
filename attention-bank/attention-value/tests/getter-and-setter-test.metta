!(register-module! ../../../../metta-attention)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)

! (setAv A (200 200 0))
! (setAv A (400 400 1))

! (setStv A (0.1 0.9))
! (setStv A (1 0.9))

! (setAv (link a b) (200 200 0))
! (setStv (link a b) (0.1 0.9))
! (setAv (C) (400 400 1))
! (setStv (C) (1 0.9))

! (assertEqual (getStv (C)) (STV 1 0.9))
! (assertEqual (getAv (C)) (AV 400 400 1))

! (assertEqual (getStv (link a b)) (STV 0.1 0.9))
! (assertEqual (getAv (link a b)) (AV 200 200 0))



! (assertEqual (getStv A) (STV 1 0.9))
! (assertEqual (getAv A) (AV 400 400 1))
! (assertEqual (getMean A) 1)
! (assertEqual (getConfidence A) 0.9)
! (assertEqual (getSTI A) 400)
! (assertEqual (getLTI A) 400)
! (assertEqual (getVLTI A) 1)

! (setAv (link (link a c) b) (200 200 0))

! (setAv (link a c) (300 200 0))
! (setAv a (400 400 1))
! (setAv b (400 400 1))
! (setAv c (400 400 1))

! (getAv a)                   ;Should return (400 400 1)
! (getAv (link a c))          ;Should return (300 200 0)
! (getAv (link (link a c) b)) ;Should return (200 200 0)
! (getAv (link (link a c) b)) ;Should return (200 200 0)

! (setAv a (200 200 0))
! (setAv (link a b) (300 200 0))

! (getAv a) ;Should return (200 200 0)
! (getAv (link a b)) ;Should return (300 200 0)

; #######################################################

! (setStv (link (link a c) b) (200 200))

! (setStv (link a c) (300 200))
! (setStv a (400 400))
! (setStv b (400 400))
! (setStv c (400 400))

! (getStv a)                   ;Should return (400 400)
! (getStv (link a c))          ;Should return (300 200)
! (getStv (link (link a c) b)) ;Should return (200 200)
! (getStv (link (link a c) b)) ;Should return (200 200)

! (setStv a (200 200))
! (setStv (link a b) (300 200))

! (getStv a) ;Should return (200 200)
! (getStv (link a b)) ;Should return (300 200)


! (setAv (link (link a b) (link c d)) (399 400 1))
! (getAv (link (link a b) (link c d)))

! (setStv (link (link a b) (link c d)) (0.1 0.9))
! (getStv (link (link a b) (link c d)))

! (setAv a (150 400 100))
! (getAv a)

! (setStv a (0.1 0.9))
! (getStv a)


! (setStv (a) (0.2 0.9))
! (getStv (a))

! (setAv (a) (397 400 1))
! (getAv (a))

! (getAv k)