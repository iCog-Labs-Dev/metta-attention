(= (Experiment.Library) (argv 1))
(= (Experiment.Case) (argv 2))
(= (Experiment.MaxSteps) (argv 3))
(= (Experiment.TaskLimit) (argv 4))
(= (Experiment.BeliefLimit) (argv 5))
(= (Experiment.Questions) (sread (argv 6)))
(= (Experiment.SnapshotModule) (argv 7))

!(callPredicate (Predicate (use_module (Experiment.SnapshotModule))))
!(import_prolog_function Baseline.Canonical)

!(import! &self (Experiment.Library))
!(import! &self baseline)
!(import! &self (Experiment.Case))

!(Baseline.Run
    (kb)
    (Experiment.MaxSteps)
    (Experiment.TaskLimit)
    (Experiment.BeliefLimit)
    (Experiment.Questions))
