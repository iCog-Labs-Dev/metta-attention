(= (test-superpose $incidentSpace)
    (hyperpose 
        (
            (HebbianCreationAgent-Run (TypeSpace))
            (HebbianUpdatingAgent-Run (TypeSpace))
            (AFImportanceDiffusionAgent-Run $incidentSpace (TypeSpace))
            (AFRentCollectionAgent-run)
            ; (AFRentCollectionAgent2-run)
            (WAImportanceDiffusionAgent-Run $incidentSpace)
            (WARentCollectionAgent-Run)
            ;(forgettingAgent-Run (atomBin))
        )
    )
)
