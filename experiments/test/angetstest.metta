!(register-module! ../../../metta-attention)
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


!(import! &self metta-attention:attention:agents:mettaAgents:AttentionParam)
!(import! &self metta-attention:attention:agents:mettaAgents:Neighbors)
!(import! &self metta-attention:experiments:runner-Def)

!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:utilities:recentVal)

!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)

!(import! &self metta-attention:attention-bank:bank:atom-bins:get-min-max-content)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &self metta-attention:attention-bank:bank:stochastic-importance-diffusion:stochastic-importance-diffusion)




!(setStv (SimilarityLink abamectin ants) (0.245 1.0))
!(setStv (SimilarityLink abamectin ant) (0.049 1.0))
!(setStv (SimilarityLink abamectin aphid) (0.608 1.0))
!(setStv (SimilarityLink abamectin aphids) (0.477 1.0))
!(setStv (SimilarityLink abamectin armyworms) (0.295 1.0))
!(setStv (SimilarityLink abamectin armyworm) (0.462 1.0))
!(setStv (SimilarityLink abamectin beanfly) (0 1.0))
!(setStv (SimilarityLink abamectin beanflys) (0 1.0))
!(setStv (SimilarityLink abamectin beanleafroller) (0 1.0))
!(setStv (SimilarityLink abamectin beanleafrollers) (0 1.0))
!(setStv (SimilarityLink abamectin beanpodborers) (0 1.0))
!(stimulate ants 1)



!(println! (typesepace (get-atoms (TypeSpace))))
!(println! (removespace (getAtomsInRemoveSpace)))
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
!(println! (Bin (collapseAtomBin (AtomBin))))
(assertEqual (getAtomList) (ants (SimilarityLink abamectin ants)))
(assertEqual (getAtomsInRemoveSpace) ())
(assertEqual (getAtomsInRemoveSpace) ())
(assertEqual 
    (let*
        (
            ($rmvspace (getAtomsInRemoveSpace))	
            ($typspace (getAtomsInTypeSpace))
        )
        (intersection-atom $typspace $rmvspace)
    ) 
    ()
)
!(get-atoms &recentVal)

!(test-superpose)

!(println! (typesepace (get-atoms (TypeSpace))))
!(println! (removespace (getAtomsInRemoveSpace)))
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
!(println! (Bin (collapseAtomBin (AtomBin))))
(assertEqual (getAtomList) (ants abamectin))
(assertEqual (getAtomsInRemoveSpace) 
        ((SimilarityLink abamectin ants) (ASYMMETRIC_HEBBIAN_LINK ants (SimilarityLink abamectin ants)) (ASYMMETRIC_HEBBIAN_LINK (SimilarityLink abamectin ants) ants))
    )
(assertEqual 
    (let*
        (
            ($rmvspace (getAtomsInRemoveSpace))	
            ($typspace (getAtomsInTypeSpace))
        )
        (intersection-atom $typspace $rmvspace)
    ) 
    ()
)
(get-atoms &recentVal)


!(test-superpose)

!(stimulate aphid 1)
!(stimulate aphids 0.2)
!(stimulate abamactin 0.2)

!(println! (typesepace (get-atoms (TypeSpace))))
!(println! (removespace (getAtomsInRemoveSpace)))
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
!(println! (Bin (collapseAtomBin (AtomBin))))
!(test-superpose)
!(test-superpose)

!(println! (typesepace (get-atoms (TypeSpace))))
!(println! (removespace (getAtomsInRemoveSpace)))
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
!(println! (Bin (collapseAtomBin (AtomBin))))
(println! (typesepace (get-atoms (TypeSpace))))
(println! (removespace (getAtomsInRemoveSpace)))
(println! 
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
(println! (Bin (collapseAtomBin (AtomBin))))
(assertEqual (getAtomList) (ants abamectin))
(assertEqual (getAtomsInRemoveSpace) 
        ((SimilarityLink abamectin ants) (ASYMMETRIC_HEBBIAN_LINK ants (SimilarityLink abamectin ants)) (ASYMMETRIC_HEBBIAN_LINK (SimilarityLink abamectin ants) ants))
    )
(assertEqual 
    (let*
        (
            ($rmvspace (getAtomsInRemoveSpace))	
            ($typspace (getAtomsInTypeSpace))
        )
        (intersection-atom $typspace $rmvspace)
    ) 
    ()
)
(get-atoms &recentVal)

(println! (hebbiancreationagent))
(HebbianCreationAgent-Run (TypeSpace) (attentionalFocus) (newAtomInAV))
(println! (typesepace (get-atoms (TypeSpace))))
(println! (removespace (getAtomsInRemoveSpace)))
(println! 
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
(println! (Bin (collapseAtomBin (AtomBin))))

(println! (hebbianupdatingagent-run))
(HebbianUpdatingAgent-Run (TypeSpace))
(println! (typesepace (get-atoms (TypeSpace))))
(println! (removespace (getAtomsInRemoveSpace)))
(println! 
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
(println! (Bin (collapseAtomBin (AtomBin))))

(println! (afimportancediffusionagent))
(AFImportanceDiffusionAgent-Run (attentionalFocus) (TypeSpace))
(println! (typesepace (get-atoms (TypeSpace))))
(println! (removespace (getAtomsInRemoveSpace)))
(println! 
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
(println! (Bin (collapseAtomBin (AtomBin))))
