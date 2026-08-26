(= (test-superpose $incidentSpace)
    (superpose 
        (
            (HebbianCreationAgent-Run (TypeSpace))
            (HebbianUpdatingAgent-Run (TypeSpace))
            (AFImportanceDiffusionAgent-Run $incidentSpace (TypeSpace))
            (WAImportanceDiffusionAgent-Run $incidentSpace)
            (AFRentCollectionAgent-run)
            (WARentCollectionAgent-Run)
            ; (AFRentCollectionAgent2-run)
            ;(forgettingAgent-Run (atomBin))
        )
    )
)
