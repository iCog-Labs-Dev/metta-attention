!(register-module! ../../../../metta-attention)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)

! (setAv A (200 200 0))
! (setAv A (400 400 1))

! (setStv A (0.1 0.9))
! (setStv A (1 0.9))

;node_a (1 2 3)
;node_b (1 2 3)
;link_ab node_a node_b (1 2 3)
;
!(setAv a (1 2 3))
! (setAv (link a b) (200 200 0))
;! (setStv (link a b) (0.1 0.9))
;! (setAv (C) (400 400 1))
;! (setStv (C) (1 0.9))
;
;! (assertEqual (getStv (C)) (STV 1 0.9))
;! (assertEqual (getAv (C)) (AV 400 400 1))
;
;! (assertEqual (getStv (link a b)) (STV 0.1 0.9))
;! (assertEqual (getAv (link a b)) (AV 200 200 0))
;
;
;
;! (assertEqual (getStv A) (STV 1 0.9))
;! (assertEqual (getAv A) (AV 400 400 1))
;! (assertEqual (getMean A) 1)
;! (assertEqual (getConfidence A) 0.9)
;! (assertEqual (getSTI A) 400)
;! (assertEqual (getLTI A) 400)
;! (assertEqual (getVLTI A) 1)
;
