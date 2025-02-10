!(bind! &depTypes (dT))

(: AV (-> Number Number Number Type))
(: STV (-> Number Number Type))

(: Link (-> $type $source $target ($sti $lti $vlti) ($tv $conf) ((AV $sti $lti $vlti) (STV $tv $conf))))
(: Node (-> $type $symbol ($sti $lti $vlti) ($tv $conf) ((AV $sti $lti $vlti) (STV $tv $conf))))

;getters for Link types
(= (getAV (Link $type $source $target $av $stv)) $av)
(= (getSTV (Link $type $source $target $av $stv)) $stv)

;getters for Node types
(= (getSTV (Node $type $symbol $av $stv)) $stv)
(= (getAV (Node $type $symbol $av $stv)) $av)

;av and stv setters for Node types
(= (applySTV Node $pattern ($type $symbol $av $stv) $newSTV)
   (unify (quote (Node $type $symbol $av $stv))
           (quote ($node $type $symbol $av $stv))
           (let () (remove-atom &depTypes (: $pattern ($node $type $symbol $av $stv)))
                                      (add-atom &depTypes (: $pattern ($node $type $symbol $av $newSTV)))
            )
          ("Failure")
    )
)

(= (applySTV Link $pattern ($type $source $target $av $stv) $newSTV)
   (unify (quote (Link $type $source $target $av $stv))
           (quote ($link $type $source $target $av $stv))
           (let () (remove-atom &depTypes (: $pattern ($link $type $source $target $av $stv)))
                                      (add-atom &depTypes (: $pattern ($link $type $source $target $av $newSTV)))
            )
          ("Failure")

    )
)

(= (setSTV $pattern $newSTV)
   (let* (
          ($val (get-type-space &depTypes $pattern))
          ($signal (car-atom $val))
          ($rest (cdr-atom $val))
          )
     (applySTV $signal $pattern $rest $newSTV)
    )
)

(= (applyAV Node $pattern ($type $symbol $av $stv) $newAV)
   (unify (quote (Node $type $symbol $av $stv))
           (quote ($node $type $symbol $av $stv))
           (let () (remove-atom &depTypes (: $pattern ($node $type $symbol $av $stv)))
                                      (add-atom &depTypes (: $pattern ($node $type $symbol $newAV $stv)))
            )
          ("Failure")
    )
)

(= (applyAV Link $pattern ($type $source $target $av $stv) $newAV)
   (unify (quote (Link $type $source $target $av $stv))
           (quote ($link $type $source $target $av $stv))
           (let () (remove-atom &depTypes (: $pattern ($link $type $source $target $av $stv)))
                                      (add-atom &depTypes (: $pattern ($link $type $source $target $newAV $stv)))
            )
          ("Failure")

    )
)

(= (setAV $pattern $newAV)
   (let* 
     (
      ($val (get-type-space &depTypes $pattern))
      ($signal (car-atom $val))
      ($rest (cdr-atom $val))
      )
     (applyAV $signal $pattern $rest $newAV)
    )
)
