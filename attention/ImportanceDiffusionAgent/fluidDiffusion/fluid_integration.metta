!(import! &self "../attention/ImportanceDiffusionAgent/fluidDiffusion/connection.py")

(= (extractStiPairs ())
    ())

(= (extractStiPairs (cons $atom $rest))
    (cons ($atom (getSti $atom)) (extractStiPairs $rest)))

(= (applyNewStis ())
    ()
)

(= (applyNewStis (cons ($atom $sti) $rest))
    (let $x (setSti $atom $sti)
        (applyNewStis $rest)
    )
)

(= (applyFluidSimulation $graphFile)
    (let*
        (
            ($pairs (extractStiPairs (getAfAtoms)))
            ($newStis (py-call (connection.fluid_from_af $graphFile $pairs 70 70 0.9)))
        )
        (applyNewStis $newStis)
    )
)
