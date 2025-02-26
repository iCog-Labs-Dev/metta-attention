

;function tradeSTI
;param Atom Atom Number
;return None
(: tradeSTI (-> Atom Atom Number emtpy))
(= (tradeSTI $source $target $value)
    (let* (
        ($sourceSTI (getSTI $source))
        ($targetSTI (getSTI $target))
        ($sourceAV (getAv $source))
        ($targetAV (getAv $target))
        ($sourceValues (cdr-atom $sourceAV))
        ($targetValues (cdr-atom $targetAV))
        ($sourceVal (cdr-atom $sourceValues))
        ($targetVal (cdr-atom $targetValues))
        ($newSTISourceVal (- $sourceSTI $value))
        ($newSTITargetVal (+ $targetSTI $value))
        ($newSourceAV (cons-atom $newSTISourceVal $sourceVal))
        ($newTargetAV (cons-atom $newSTITargetVal $targetVal))
        ($_ (setAv $source $newSourceAV))
        ($_ (setAv $target $newTargetAV))
        )
        (empty)

    )
)