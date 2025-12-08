(= (test-superpose)
    (superpose 
        (
            (HebbianUpdatingAgent-Run (eval (TypeSpace)))
            (AFImportanceDiffusionAgent-Run (eval (TypeSpace)))
            (HebbianCreationAgent-Run (eval (TypeSpace)))
            (AFRentCollectionAgent-run)
            (WAImportanceDiffusionAgent-Run (eval (TypeSpace)))
            ;(WARentCollectionAgent-Run)
            ;(forgettingAgent-Run (atomBin))
        )
    )
)
