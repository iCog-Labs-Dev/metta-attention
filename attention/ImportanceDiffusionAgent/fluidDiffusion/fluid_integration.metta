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

(= (applyFluidSimulation $graphFile $seeds)
    (let*
        (
            ($pairs (extractStiPairs (getAfAtoms)))
            ($newStis (py-call (connection.fluid_from_af $graphFile $pairs 70 50 0.9 $seeds 2.2 0.5 "value_alignment")))
        )
        (applyNewStis $newStis)
    )
)
