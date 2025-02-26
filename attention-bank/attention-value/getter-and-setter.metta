(: createAV (-> $event ($sti $lti $vlti) ($sti $lti $vlti)))
(: createSTV (-> $event ($mean $conf) ($mean $conf)))

(: getSTI (-> $instance Number))
(= (getSTI ((createAV $x ($sti $lti $vlti)) $y)) $sti)
(= (getSTI ($y (createAV $x ($sti $lti $vlti)))) $sti)
(= (getSTI ((createAV $x ($sti $lti $vlti))) )$sti)
(= (getSTI ((createSTV $x $y))) 0.0)
(= (getSTI (%Undefined%)) 0.0)

(: getLTI (-> $instance Number))
(= (getLTI ((createAV $x ($sti $lti $vlti)) $y)) $lti)
(= (getLTI ((createSTV $x $y) (createAV $x ($sti $lti $vlti)))) $lti)
(= (getLTI ((createAV $x ($sti $lti $vlti)))) $lti)
(= (getLTI ((createSTV $x $y))) 0.0)
(= (getLTI (%Undefined%)) 0.0)

(: getVLTI (-> $instance Number))
(= (getVLTI ((createAV $x ($sti $lti $vlti)) $y)) $vlti)
(= (getVLTI ($y (createAV $x ($sti $lti $vlti)))) $vlti)
(= (getVLTI ((createAV $x ($sti $lti $vlti)))) $vlti)
(= (getVLTI ((createSTV $x $y))) 0.0)
(= (getVLTI (%Undefined%)) 0.0)

(: getAV (-> $instance Expression))
(= (getAV ((createAV $x ($sti $lti $vlti)))) ($sti $lti $vlti))
(= (getAV ((createAV $x ($sti $lti $vlti)) $_)) ($sti $lti $vlti))
(= (getAV ($_ (createAV $x ($sti $lti $vlti)))) ($sti $lti $vlti))
(= (getAV ((createSTV $x ($mean $conf)))) (0.0 0.0 0.0))
(= (getAV (%Undefined%)) (0.0 0.0 0.0))

(: getMean (-> $instance Number))
(= (getMean ($y (createSTV $x ($mean $_)))) $mean)
(= (getMean ((createSTV $x ($mean $_)) $y)) $mean)
(= (getMean ((createSTV $x ($mean $_)))) $mean)
(= (getMean ((createAV $x $y))) 0.0) 

(: getConf (-> $instance Number))
(= (getConf ($y (createSTV $x ($_ $conf)))) $conf)
(= (getConf ((createSTV $x ($_ $conf)) $y)) $conf)
(= (getConf ((createSTV $x ($_ $conf)))) $conf)
(= (getConf ((createAV $x $y))) 0.0) 

(: getSTV (-> $instance Expression))
(= (getSTV ((createSTV $x ($mean $conf)))) ($mean $conf))
(= (getSTV ($_ (createSTV $x ($mean $conf)))) ($mean $conf))
(= (getSTV ((createSTV $x ($mean $conf)) $_ )) ($mean $conf))
(= (getSTV ((createAV $x $_))) (0.0 0.0))
(= (getSTV (%Undefined%)) (0.0 0.0))

(= (upsertAV $space $pattern ((createAV $instance $av) $_) $newAV)
   (update-atom
    $space
    (: $pattern (createAV $instance $av))
    (: $pattern (createAV $instance $newAV))
    )
)

(= (upsertAV $space $pattern ((createAV $instance $av)) $newAV)
   (update-atom
    $space
    (: $pattern (createAV $instance $av))
    (: $pattern (createAV $instance $newAV))
    )
)

(= (upsertAV $space $pattern ($_ (createAV $instance $av)) $newAV)
   (update-atom
    $space
    (: $pattern (createAV $instance $av))
    (: $pattern (createAV $instance $newAV))
    )
)

(= (upsertAV $space $pattern ((createSTV $instance $av)) $newAV)
   (update-atom
    $space
    (: $pattern (createAV $instance $av))
    (: $pattern (createAV $instance $newAV))
    )
)

(= (setAV $space $pattern $newAV)
   (let $val (collapse (get-type-space $space $pattern))
     (upsertAV $space $pattern $val $newAV)
    )
)

(= (upsertSTV $space $pattern ($_ (createSTV $instance $stv)) $newSTV)
  (update-atom
    $space
    (: $pattern (createSTV $instance $stv))
    (: $pattern (createSTV $instance $newSTV))
   )
)

(= (upsertSTV $space $pattern ((createSTV $instance $stv) $_ ) $newSTV)
  (update-atom
    $space
    (: $pattern (createSTV $instance $stv))
    (: $pattern (createSTV $instance $newSTV))
   )
)

(= (upsertSTV $space $pattern ((createSTV $instance $stv)) $newSTV)
  (update-atom
    $space
    (: $pattern (createSTV $instance $stv))
    (: $pattern (createSTV $instance $newSTV))
   )
)

(= (upsertSTV $space $pattern ((createAV $instance $stv)) $newSTV)
  (update-atom
    $space
    (: $pattern (createSTV $instance $stv))
    (: $pattern (createSTV $instance $newSTV))
   )
)

(= (setSTV $space $pattern $newSTV)
   (let $val (collapse (get-type-space $space $pattern))
     (upsertSTV $space $pattern $val $newSTV)
    )
)
