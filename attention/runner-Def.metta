(= (test-superpose)
    (superpose 
        (
            (HebbianUpdatingAgent-Run (TypeSpace))
            (AFImportanceDiffusionAgent-Run (TypeSpace))
            (HebbianCreationAgent-Run (TypeSpace))
            (AFRentCollectionAgent-run)
            (WAImportanceDiffusionAgent-Run (TypeSpace))
            (WARentCollectionAgent-Run)
            ;(forgettingAgent-Run (atomBin))
        )
    )
)
