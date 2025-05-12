(= (test-superpose)
    (superpose 
        (
            (HebbianCreationAgent-Run (TypeSpace) (attentionalFocus) (newAtomInAV))
            (HebbianUpdatingAgent-Run (TypeSpace))
            (AFImportanceDiffusionAgent-Run (attentionalFocus) (TypeSpace))
            (AFRentCollectionAgent-run)
            ; (WARentCollectionAgent-Run)
            ; (WAImportanceDiffusionAgent-Run (TypeSpace))
            ; (forgettingAgent-Run (AtomBin))
        )
    )
)
