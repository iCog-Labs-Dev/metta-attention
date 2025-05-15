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

! (stimulate source 1500)
! (stimulate target1 1500)
! (stimulate target2 1600)
! (stimulate target4 290)

! (setStv (INHERITANCE_LINK source target4) (0.1 0.9))
! (setStv (INHERITANCE_LINK source target3) (0.1 0.9))



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
! (println! ("HebbianCreationAgent output"))

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
! (println! ("HebbianUpdatingAgent output"))

!(println! (typesepace (get-atoms (TypeSpace))))
!(println! (Bin (collapseAtomBin (AtomBin))))

!(AFImportanceDiffusionAgent-Run (attentionalFocus) (TypeSpace))
! (println! ("AFImportanceDiffusionAgent output"))
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


! (AFRentCollectionAgent-run)

! ((py-atom time.sleep) (/ 5.0 5.0))

! (AFRentCollectionAgent-run)

! ((py-atom time.sleep) (/ 20.0 5.0))

! (AFRentCollectionAgent-run)

! ((py-atom time.sleep) (/ 30.0 5.0))

!(AFRentCollectionAgent-run)

! (println! ("AFRentCollectionAgent output"))


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





