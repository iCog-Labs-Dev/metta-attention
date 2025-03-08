
;constant Value
(= (maxSpreadPercentage) 0.4)
(= (hebbianMaxAllocationPercentage) 0.05)
(= (spreadHebbianOnly) 0)

;function calculateDiffusionAmount
;param Atom
;return Number
(: calculateDiffusionAmount (-> Atom Number))
(= (calculateDiffusionAmount $atom)
    (let* (
        ($stiValue (getSTI $atom))
        ($result (* $stiValue (maxSpreadPercentage)))
        )
        $result
    )    
)