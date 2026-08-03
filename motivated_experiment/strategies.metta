(= (pickOutsideAF)
    (let $x (getRandomAtomNotInAF)
        (if (== $x ()) (getRandomAtomInAF) $x)
    )
)

(= (applyStrategy narrow-focus)
    ((getRandomAtomInAF) (getRandomAtomInAF) (getRandomAtomInAF) (getRandomAtomInAF))
)

(= (applyStrategy expand-focus)
    ((getRandomAtomInAF) (getRandomAtomInAF) (pickOutsideAF) (pickOutsideAF))
)

(= (applyStrategy explore-novel)
    ((pickOutsideAF) (pickOutsideAF) (pickOutsideAF) (pickOutsideAF))
)

