! (register-module! ../../../../../metta-attention)
! (import! &self metta-attention:attention-bank:bank:stochastic-importance-diffusion:merge-bin)
! (import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
! (import! &self metta-attention:attention-bank:bank:attention-bank)
! (import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
! (import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
! (import! &self metta-attention:attention-bank:utilities:helper-functions)
! (import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)

 ;add atoms to past-space
! (add-atom &past-space (1 ( (count 1) (index 1) (Size 1))))
! (add-atom &past-space (2 ( (count 10) (index 2) (Size 1))))
! (add-atom &past-space (3 ( (count 1) (index 3) (Size 1))))
! (add-atom &past-space (4 ( (count 5) (index 4) (Size 1))))

 ;add atoms to recent-space
! (add-atom &recent-space (4 ( (count 1) (index 4) (Size 1))))
! (add-atom &recent-space (5 ( (count 1) (index 5) (Size 1))))
! (add-atom &recent-space (3 ( (count 3) (index 3) (Size 1))))
! (add-atom &recent-space (2 ( (count 5) (index 2) (Size 1))))

 ;check the function is returning Merge completed string after all thing done
! (assertEqual (mergeBin (collapse (get-atoms &recent-space)) 0.5) ((4 ((count 3) (index 4) (Size 1))) (5 ((count 1) (index 5) (Size 1))) (3 ((count 2) (index 3) (Size 1))) (2 ((count 7.5) (index 2) (Size 1)))))
 ;  after apply  merge function by bias 0.5 on recent space at index 2 the value of count change from 5 to 7.5
! (assertEqual (match &recent-space (2 ( (count $count) (index $x) (Size $y))) $count) 7.5)
 ;  after apply  merge function by bias 0.5 on recent space at index 4 the value of count change from 1 to 3
! (assertEqual (match &recent-space (4 ( (count $count) (index $x) (Size $y))) $count) 3)
