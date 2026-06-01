(= (test-superpose $incidentSpace)
    (hyperpose 
        (
            (HebbianCreationAgent-Run (TypeSpace))
            (HebbianUpdatingAgent-Run (TypeSpace))
            (AFImportanceDiffusionAgent-Run $incidentSpace (TypeSpace))
            ; (AFRentCollectionAgent2-run)
            (AFRentCollectionAgent-run)
            (WAImportanceDiffusionAgent-Run $incidentSpace)
            (WARentCollectionAgent-Run)
            ;(forgettingAgent-Run (atomBin))
        )
    )
)
