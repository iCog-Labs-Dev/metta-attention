!(register-module! ../../metta-attention)
!(import! &self metta-attention:attention:agents:mettaAgents:ForgettingAgent:ForgettingAgent)
!(import! &self metta-attention:attention:agents:mettaAgents:AttentionParam)
!(import! &self metta-attention:attention:agents:mettaAgents:RentCollectionAgent:RentCollectionBaseAgent:RentCollectionBaseAgent)
!(import! &self metta-attention:attention:agents:mettaAgents:RentCollectionAgent:WARentCollectionAgent:WARentCollectionAgent)
!(import! &self metta-attention:attention:agents:mettaAgents:RentCollectionAgent:AFRentCollectionAgent:AFRentCollectionAgent)
!(import! &self metta-attention:attention:agents:mettaAgents:ImportanceDiffusionAgent:ImportanceDiffusionBase:ImportanceDiffusionBase)
!(import! &self metta-attention:attention:agents:mettaAgents:ImportanceDiffusionAgent:WAImportanceDiffusionAgent:WAImportanceDiffusionAgent)
!(import! &self metta-attention:attention:agents:mettaAgents:ImportanceDiffusionAgent:AFImportanceDiffusionAgent:AFImportanceDiffusionAgent)
!(import! &self metta-attention:attention:agents:mettaAgents:HebbianUpdatingAgent:HebbianUpdatingAgent)
!(import! &self metta-attention:attention:agents:mettaAgents:HebbianCreationAgent:HebbianCreationAgent)

; !(import! &self metta-attention:attention:agents:mettaAgents:AttentionParam)
!(import! &self metta-attention:attention:agents:mettaAgents:Neighbors)
; !(import! &self metta-attention:attention:agents:mettaAgents:Runner:runnerDef)

!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:utilities:recentVal)

!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)

!(import! &self metta-attention:attention-bank:bank:atom-bins:get-min-max-content)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &self metta-attention:attention-bank:bank:stochastic-importance-diffusion:stochastic-importance-diffusion)

! (stimulate source 50)
! (stimulate target1 100)
! (stimulate target2 150)
! (stimulate target3 200)
! (stimulate target4 250)
! (setStv (INHERITANCE_LINK source target4) (0 1))
! (setStv (INHERITANCE_LINK source target3) (0 1))



!(println! 
    (AF 
        (let*
            (
               ($atoms (getAtomList))
               ($vals (superpose $atoms))
               ($sti (getSTI $vals))
            )
            ($vals $sti)
        )
    )
)
!(println! (typesepace (get-atoms (TypeSpace))))
!(println! (Bin (collapseAtomBin (AtomBin))))

!(HebbianCreationAgent-Run (TypeSpace) (attentionalFocus) (newAtomInAV))
; !(updateHebbianLinks hello (TypeSpace))

!(println! 
    (AF 
        (let*
            (
               ($atoms (getAtomList))
               ($vals (superpose $atoms))
               ($sti (getSTI $vals))
            )
            ($vals $sti)
        )
    )
)
!(println! (typesepace (get-atoms (TypeSpace))))
!(println! (Bin (collapseAtomBin (AtomBin))))


; ! (updateHebbianLinks source (TypeSpace))
; ! (updateHebbianLinks target1 (TypeSpace))
! (HebbianUpdatingAgent-Run (TypeSpace))

!(println! (typesepace (get-atoms (TypeSpace))))

!(AFImportanceDiffusionAgent-Run (attentionalFocus) (TypeSpace))

!(println! 
    (AF 
        (let*
            (
               ($atoms (getAtomList))
               ($vals (superpose $atoms))
               ($sti (getSTI $vals))
            )
            ($vals $sti)
        )
    )
)
!(println! (typesepace (get-atoms (TypeSpace))))
!(println! (Bin (collapseAtomBin (AtomBin))))
! (getSTI (INHERITANCE_LINK source target4))

; what i dont understand is if Hebbian creation agent and updating agent focus on hebbian link
   ; and importance diffusion agent dosnt consider any hebbian link whats the point then??
   ; specially what is the poin of updating mean and confidence by updating agent
; and why does when atoms diffuse thire value is not decreasing??

! (AFRentCollectionAgent-run)

!(println! 
    (AF 
        (let*
            (
               ($atoms (getAtomList))
               ($vals (superpose $atoms))
               ($sti (getSTI $vals))
            )
            ($vals $sti)
        )
    )
)
!(println! (typesepace (get-atoms (TypeSpace))))
!(println! (Bin (collapseAtomBin (AtomBin))))



