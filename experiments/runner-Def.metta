(= (test-superpose)
    (let $atoms
        (getAfAtoms)
        (superpose 
            (
                (HebbianUpdatingAgent-Run (TypeSpace) $atoms)
                (AFImportanceDiffusionAgent-Run (TypeSpace) $atoms)
                (HebbianCreationAgent-Run (TypeSpace) $atoms)
                (AFRentCollectionAgent-run $atoms)
                (WAImportanceDiffusionAgent-Run (TypeSpace))
                (WARentCollectionAgent-Run)
                ;(forgettingAgent-Run (atomBin))
            )
        )
    )
)
