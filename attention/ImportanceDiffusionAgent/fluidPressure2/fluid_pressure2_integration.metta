!(import! &self "../attention/ImportanceDiffusionAgent/fluidPressure2/connection.py")

(= (extractStiPairs2 ()) ())
(= (extractStiPairs2 (cons $atom $rest))
    (cons ($atom (getSti $atom)) (extractStiPairs2 $rest)))

(= (extractLtiPairs2 ()) ())
(= (extractLtiPairs2 (cons $atom $rest))
    (cons ($atom (getLti $atom)) (extractLtiPairs2 $rest)))

(= (applyStiPairs2 ()) ())
(= (applyStiPairs2 (cons ($atom $sti) $rest))
    (let $ignored (setSti $atom $sti) (applyStiPairs2 $rest)))

; $seeds is a list of goal atom names.
(= (applyFluidPressure2Simulation $graphFile $seeds)
    (let* (($atoms (getAfAtoms))
           ($sti (extractStiPairs2 $atoms))
           ($lti (extractLtiPairs2 $atoms))
           ($newSti (py-call (connection.fluid_from_ecan $graphFile $sti $lti $seeds))))
        (applyStiPairs2 $newSti)))
