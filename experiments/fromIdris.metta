(: Event Type)
(: AV (-> Number Number Type))
(: STV (-> Number Number Type))

(: createAV (-> $event ($sti $lti) ((AV $sti $lti))))
(: createSTV (-> $event ($tv $conf) ((STV $tv $conf))))

(: Node (-> $type $node Type))
(: Link (-> $type $source $target Type))

(: nodeA (Concept A))
(: nodeB (Concept B))

(: linkAB (Hebbian nodeA nodeB))

(: eventA (createAV nodeA (0.1 0.2)))
(: eventA (createSTV nodeA (0.3 0.4)))

(: linkEvent (createAV linkAB (0.1 0.2)))
(: linkEvent (createSTV linkAB (0.3 0.4)))

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

(: update-atom (-> Grounded Atom Atom (->)))
(= (update-atom $space $oatom $natom) (let $_ (remove-atom $space $oatom) (add-atom $space $natom)))

(= (getType $instance) (collapse (get-type $instance)))
!(getType eventA)
(= (setAV ($_ (createAV $x ($sti $lti))) ($newSTI $newLTI))
   (
    update-atom &self (: $x (createAV ($sti $lti))) (: $x (createAV ($newSTI $newLTI)))
    )
)

(= (setAV (($createAV $x ($sti $lti)) $_) ($newSTI $newLTI))
   (
    update-atom 
    &self 
    (: $x (createAV ($sti $lti)))
    (: $x (createAV ($newSTI $newLTI)))
  )
)
!(setAV (getType eventA) 0.0 0.0)
!(getSTI (getType eventA))
!(getLTI (getType eventA))

!(getSTI (getType linkEvent))

!(getTV (getType linkEvent))
!(getConf (getType linkEvent))

