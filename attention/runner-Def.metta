(= (test-superpose $incidentSpace)
    (hyperpose 
        (
            (HebbianUpdatingAgent-Run (TypeSpace))
            (AFImportanceDiffusionAgent-Run $incidentSpace (TypeSpace))
            (AFRentCollectionAgent2-run)
            (WAImportanceDiffusionAgent-Run $incidentSpace)
            (WARentCollectionAgent-Run)
            ;(forgettingAgent-Run (atomBin))
        )
    )
)
