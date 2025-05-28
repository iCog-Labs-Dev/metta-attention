(= (test-superpose)
    (superpose 
        (
            ;(HebbianUpdatingAgent-Run (TypeSpace))
            (HebbianCreationAgent-Run (TypeSpace) (attentionalFocus) (newAtomInAV))
            ;(AFImportanceDiffusionAgent-Run (attentionalFocus) (TypeSpace))
            (AFRentCollectionAgent-run)
            ;(WARentCollectionAgent-Run)
           ;(WAImportanceDiffusionAgent-Run (TypeSpace))
            ;(forgettingAgent-Run (AtomBin))
        )
    )
)
