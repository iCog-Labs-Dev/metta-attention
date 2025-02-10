(: update-atom (-> Grounded Atom Atom (->)))
(= (update-atom $space $oatom $natom) (let $_ (remove-atom $space $oatom) (add-atom $space $natom)))

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
(= (applySTV $space Node $pattern ($type $symbol $av $stv) $newSTV)
   (unify (quote (Node $type $symbol $av $stv))
           (quote (Node $type $symbol $av $stv))
           (update-atom $space (: $pattern (Node $type $symbol $av $stv)) (: $pattern (Node $type $symbol $av $newSTV)))
          ("Failure")
    )
)

(= (applySTV $space Link $pattern ($type $source $target $av $stv) $newSTV)
   (unify (quote (Link $type $source $target $av $stv))
           (quote (Link $type $source $target $av $stv))
           (update-atom $space (: $pattern (Link $type $source $target $av $stv)) (: $pattern (Link $type $source $target $av $newSTV)))
          ("Failure")

    )
)

(= (setSTV $space $pattern $newSTV)
   (let* (
          ($val (get-type-space $space $pattern))
          ($signal (car-atom $val))
          ($rest (cdr-atom $val))
          )
     (applySTV $space $signal $pattern $rest $newSTV)
    )
)

(= (applyAV $space Node $pattern ($type $symbol $av $stv) $newAV)
   (unify (quote (Node $type $symbol $av $stv))
           (quote (Node $type $symbol $av $stv))
           (update-atom $space (: $pattern (Node $type $symbol $av $stv)) (: $pattern (Node $type $symbol $newAV $stv)))
          ("Failure")
    )
)

(= (applyAV $space Link $pattern ($type $source $target $av $stv) $newAV)
   (unify (quote (Link $type $source $target $av $stv))
           (quote (Link $type $source $target $av $stv))
           (update-atom $space (: $pattern (Link $type $source $target $av $stv)) (: $pattern (Link $type $source $target $newAV $stv)))
          ("Failure")

    )
)

(= (setAV $space $pattern $newAV)
   (let* 
     (
      ($val (get-type-space $space $pattern))
      ($signal (car-atom $val))
      ($rest (cdr-atom $val))
      )
     (applyAV $space $signal $pattern $rest $newAV)
    )
)

