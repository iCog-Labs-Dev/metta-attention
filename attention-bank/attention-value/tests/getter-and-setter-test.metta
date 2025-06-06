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

! (assertEqual (getAv a) (AV 400 400 1))                ;Should return (400 400 1)
! (assertEqual (getAv (link a c)) (AV 300 200 0))       ;Should return (300 200 0)
! (assertEqual (getAv (link (link a c) b)) (AV 200 200 0)) ;Should return (200 200 0)
! (assertEqual (getAv (link (link a c) b)) (AV 200 200 0));Should return (200 200 0)

! (setAv a (200 200 0))
! (setAv (link a b) (300 200 0))

! (assertEqual (getAv a) (AV 200 200 0));Should return (200 200 0)
! (assertEqual (getAv (link a b)) (AV 300 200 0));Should return (300 200 0)

; #######################################################

! (setStv (link (link a c) b) (200 200))

! (setStv (link a c) (300 200))
! (setStv a (400 400))
! (setStv b (400 400))
! (setStv c (400 400))

! (assertEqual (getStv a)  (STV 400 400))                 ;Should return (400 400)
! (assertEqual (getStv (link a c))  (STV 300 200))        ;Should return (300 200)
! (assertEqual (getStv (link (link a c) b)) (STV 200 200)) ;Should return (200 200)
! (assertEqual (getStv (link (link a c) b)) (STV 200 200)) ;Should return (200 200)

! (setStv a (200 200))
! (setStv (link a b) (300 200))

! (assertEqual (getStv a) (STV 200 200));Should return (200 200)
! (assertEqual (getStv (link a b)) (STV 300 200)) ;Should return (300 200)


! (setAv (link (link a b) (link c d)) (399 400 1))
! (assertEqual (getAv (link (link a b) (link c d))) (AV 399 400 1))

! (setStv (link (link a b) (link c d)) (0.1 0.9))
! (assertEqual (getStv (link (link a b) (link c d))) (STV 0.1 0.9))

! (setAv a (150 400 100))
! (assertEqual (getAv a) (AV 150 400 100))

! (setStv a (0.1 0.9))
! (assertEqual (getStv a) (STV 0.1 0.9))


! (setStv (a) (0.2 0.9))
! (assertEqual (getStv (a)) (STV 0.2 0.9))

! (setAv (a) (397 400 1))
! (assertEqual (getAv (a)) (AV 397 400 1))

! ( assertEqual (getAv k) %Undefined%)