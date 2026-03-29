(= (test-superpose $incidentSpace)
    (hyperpose 
        (
            (HebbianUpdatingAgent-Run (TypeSpace))
            (AFImportanceDiffusionAgent-Run $incidentSpace (TypeSpace))
            (HebbianCreationAgent-Run (TypeSpace))
            (AFRentCollectionAgent-run)
            ; (WAImportanceDiffusionAgent-Run $incidentSpace)
            (WARentCollectionAgent-Run)
            ;(forgettingAgent-Run (atomBin))
        )
    )
)
