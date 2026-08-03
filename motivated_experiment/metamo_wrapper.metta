!(import! &self "/home/birhaneg/Documents/Icog/MetaMo/core/helpers.py")
!(import! &self ../../MetaMo/core/helper)
!(import! &self ../../MetaMo/core/state)
!(import! &self ../../MetaMo/core/state_accessors)
!(import! &self ../../MetaMo/core/config)
!(import! &self ../../MetaMo/openpsi/config)
!(import! &self ../../MetaMo/category/functors)
!(import! &self ../../MetaMo/category/bimonad)
!(import! &self ../../MetaMo/openpsi/appraisal)
!(import! &self ../../MetaMo/openpsi/appraisal_helpers)
!(import! &self ../../MetaMo/openpsi/feeling)
!(import! &self ../../MetaMo/magus/decision)
!(import! &self ../../MetaMo/dynamics/stability)
!(import! &self ../../MetaMo/dynamics/coherence)
!(import! &self ../../MetaMo/dynamics/default)
!(import! &self ../../MetaMo/main/main)

!(bind! &metamoState (new-space))

(= (cautiousInitialState)
    (subsystemState cautious
        (motivation
            (0.6 0.3 0.6 0.2 0.2 0.3 0.7 0.5)
            (0.4 0.3 0.3 0.6 0.7 0.6)
        )
    )
)

(= (curiousInitialState)
    (subsystemState curious
        (motivation
            (0.3 0.7 0.3 0.8 0.7 0.6 0.2 0.5)
            (0.6 0.7 0.7 0.3 0.3 0.3)
        )
    )
)

(= (initialMetaMoStates)
    ((cautiousInitialState) (curiousInitialState))
)

!(let $initial (initialMetaMoStates) (add-atom &metamoState (metaMoStates $initial)))

(= (getMetaMoStates)
    (collapse (match &metamoState (metaMoStates $states) $states))
)

(= (metaMoCandidates)
    ((
        action narrow-focus
            (0.4 0.3 0.8 0.2 0.2 0.3 0.8 0.5)
            0.1
            (0.0 0.0 0.1 0.0 0.0 0.0 0.1 0.0)
        )
        (action expand-focus
            (0.6 0.5 0.3 0.6 0.5 0.7 0.3 0.6)
            0.3
            (0.1 0.0 0.0 0.1 0.0 0.1 0.0 0.1)
        )
        (action explore-novel
            (0.8 0.7 0.1 0.9 0.9 0.5 0.1 0.3)
            0.5
            (0.1 0.2 0.0 0.2 0.2 0.0 0.0 0.0)
        )
    ))
)

(= (setMetaMoStates $states)
    (let $old (match &metamoState (metaMoStates $x) $x)
        (let $removed (remove-atom &metamoState (metaMoStates $x))
            (add-atom &metamoState (metaMoStates $states))
        )
    )
)

(= (runMetaMoGuided $ecanStimulus)
    (let* 
        (
            ($states (getMetaMoStates))
            ($candidates (metaMoCandidates))
            ($dbg1 (println! (about to call cycle with candidates = $candidates)))
            ($result (runMetaMoCycleDefault
                (defaultMetaMoBimonad)
                $states
                $ecanStimulus
                $candidates
                ()
                ()
            ))
            ($dbg2 (println! (cycle result = $result)))
            ($finalAction (cycleFinalAction $result))
            ($strategyName (actionId $finalAction))
            ($nextStates (cycleNextStates $result))
            ($_ (setMetaMoStates $nextStates))
        )
        $strategyName
    )
)
