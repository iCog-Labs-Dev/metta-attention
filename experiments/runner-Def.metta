(= (test-superpose)
    (superpose 
        (
            (HebbianUpdatingAgent-Run (TypeSpace))
            (HebbianCreationAgent-Run (TypeSpace))
            (AFImportanceDiffusionAgent-Run (TypeSpace))
            (AFRentCollectionAgent-run)
            ;(WARentCollectionAgent-Run)
            ;(WAImportanceDiffusionAgent-Run (TypeSpace))
            ;(forgettingAgent-Run (atomBin))
        )
    )
)
