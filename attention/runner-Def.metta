(= (test-superpose $incidentSpace)
    (hyperpose 
        (
            (HebbianUpdatingAgent-Run (TypeSpace))
            (AFImportanceDiffusionAgent-Run $incidentSpace (TypeSpace))
            (HebbianCreationAgent-Run (TypeSpace))
            (AFRentCollectionAgent-run)
            (WAImportanceDiffusionAgent-Run (TypeSpace))
            (WARentCollectionAgent-Run)
            ;(forgettingAgent-Run (atomBin))
        )
    )
)
