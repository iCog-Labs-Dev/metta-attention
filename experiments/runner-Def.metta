(= (test-superpose)
    (superpose 
        (
            (HebbianUpdatingAgent-Run (eval (TypeSpace)))
            (AFImportanceDiffusionAgent-Run (eval (TypeSpace)))
            (HebbianCreationAgent-Run (eval (TypeSpace)))
            (AFRentCollectionAgent-run)
            ;(WARentCollectionAgent-Run)
            ;(WAImportanceDiffusionAgent-Run (TypeSpace))
            ;(forgettingAgent-Run (atomBin))
        )
    )
)
