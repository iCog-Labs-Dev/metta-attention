(: AV (-> Number Number Number Type))
(: STV (-> Number Number Type))

(: createAV (-> $event ($sti $lti $vlti) ((AV $sti $lti $vlti))))
(: createSTV (-> $event ($tv $conf) ((STV $tv $conf))))

(: getSTI (-> $instance Number))
(= (getSTI ((createAV $x ($sti $_)) $y)) $sti)
(= (getSTI ($y (createAV $x ($sti $_)))) $sti)
(= (getSTI ((createAV $x ($sti $_))) )$sti)
(= (getSTI ((createSTV $x ($tv $_)))) 0.0)

(: getLTI (-> $instance Number))
(= (getLTI ((createAV $x ($_ $lti)) $y)) $lti)
(= (getLTI ((createSTV $x $y) (createAV $x ($_ $lti)))) $lti)
(= (getLTI ((createAV $x ($_ $lti)))) $lti)
(= (getLTI ((createSTV $x $y))) 0.0)

(: getTV (-> $instance Number))
(= (getTV ($y (createSTV $x ($tv $_)))) $tv)
(= (getTV ((createSTV $x ($tv $_)) $y)) $tv)
(= (getTV ((createSTV $x ($tv $_)))) $tv)
(= (getTV ((createAV $x $y))) 0.0) 

(: getConf (-> $instance Number))
(= (getConf ($y (createSTV $x ($_ $conf)))) $conf)
(= (getConf ((createSTV $x ($_ $conf)) $y)) $conf)
(= (getConf ((createSTV $x ($_ $conf)))) $conf)
(= (getConf ((createAV $x $y))) 0.0) 

(= (getType $space $instance) (collapse (get-type-space $space $instance)))

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
