!(import! &self lib/lib_he)
!(import! &self lib/lib_spaces)
!(import! &self ../../../AttentionParam)
!(import! &self ../../../../attention-bank/utilities/helper-functions)
!(import! &self ../../../../attention-bank/attention-value/getter-and-setter)
!(import! &self ../../../../attention-bank/bank/attention-bank)
!(import! &self ../../../../attention-bank/utilities/recentVal)
!(import! &self ../../../../attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../../../attention-bank/bank/importance-index/importance-index)
!(import! &self ../../../Neighbors)
!(import! &self ../ImportanceDiffusionBase)
!(import! &self ../../AFImportanceDiffusionAgent)


!(updateAttentionParam MAX_AF_SIZE 3)

!(setStv (ASYMMETRIC_HEBBIAN_LINK target source) (0.2))
!(setStv (ASYMMETRIC_HEBBIAN_LINK source target3) (0.2 0.8))
!(setStv (INHERITANCE_LINK source target5) (0.2 0.8))
!(setStv (INHERITANCE_LINK source target6) (0.2 0.8))
!(setStv (CAUSAL_LINK source target4) (0.2 0.8))
!(stimulate source 10)
!(stimulate target4 10)
!(stimulate target3 10)

; ========= tests ===============
!(test (size-atom (collapse (filteroset (collapse (match (TypeSpace) (($x $y $z) $val) ($x $y $z)))))) 3)
!(test (size-atom (collapse (incidentAtoms source (TypeSpace)))) 3)

!(collapse 
    (let* (
            ($x (collapse (incidentAtoms source (TypeSpace))))
            (($exp $val) (probabilityVectorIncident $x))
        )
         (
           (test $val (/ 1 3))
        )
    )
)


!(test (approxEqual (calculateHebbianDiffusionPercentation (INHERITANCE_LINK source target5)) 0.16 0.0001) true) ; mean*confidence
!(test (size-atom (collapse (getAllIncomingSets source (TypeSpace)))) 4)

!(setStv (ASYMMETRIC_HEBBIAN_LINK source target7) (0.25 0.8))
!(setStv (ASYMMETRIC_HEBBIAN_LINK source target8) (0.25 0.85))
!(test (probabilityVectorHebbianAjacent source (target7)) (target7 0.2))

!(let* (
        ($x (collapse (probabilityVectorHebbianAjacent source (target7 target8))))
        ($y (collapse (hebbianProportionSTI $x 0.05)))
        ($z (hebbianDiffusionUsed $y))
        )
       ((test $x ((target7 0.1) (target8 0.10625))) 
        (test $y ((target7 0.005000000000000001) (target8 0.0053125))) ; 0.05*their percentage
        (test $z 0.010312500000000002) ;the sum of the two
     ))

!(collapse 
        (let* (($x (collapse (incidentAtoms source (TypeSpace))))
        ($y (collapse (probabilityVectorIncident (CAUSAL_LINK source target4))))
        (($exp $val) (incidentProportionSTI $y 0.1)))
    (test $val 0.3))
)

!(tradeSti source target4 5)
!(test (getSti source) 195.0)
!(test (getSti target4) 205.0)