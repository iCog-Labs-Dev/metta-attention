! (register-module! ../../../metta-attention)
! (import! &self metta-attention:attention:importance-diffusion-base:probability-vector-incident)

;; Add atoms to the space
!(add-atom &space (1 (incident-atoms (2 3 4))))
!(add-atom &space (2 (incident-atoms (1 5))))
!(add-atom &space (3 (incident-atoms (1 4)) ))
!(add-atom &space (4 (incident-atoms (1 3 5))))
!(add-atom &space (5 (incident-atoms (2 4))))

;;Check if the function outputs the incident atoms with their probabilities correctly
!(probabilityVectorIncident 4)

! (assertEqualToResult
    (probabilityVectorIncident 2)
   ((1 0.5) (5 0.5))) 


