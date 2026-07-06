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

(= (applyFluidSimulation $graphFile $now)
    (let*
        (
            ($pairs (extractStiPairs (getAfAtoms)))
            ($goals (py-call (getelement.get_fair_goals $pairs $now 5)))
            ($newStis (py-call (connection.fluid_from_af $graphFile $pairs 36 100 0.1 $goals)))
        )
        (applyNewStis $newStis)
    )
)
