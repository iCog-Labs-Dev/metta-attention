


(: AttentionValue Type)
(: TruthValue Type)

(:AV (-> Number Number Number AttentionValue))

(:STV (-> Number Number Number TruthValue))

(: At (-> TruthValue AttentionValue Type))

(= (Test $pattern $sti $lti $vlti)
    (: $pattern ( (STV 0.2 0.3) (AV $sti $lti $vlti)) )
)


(sami (At (STV 0.2 0.3) (AV 0.2 0.3) ))
(dog (At (STV 0.2 0.3) (AV 0.2 0.3)))
(cat (At (STV 0.2 0.3) (AV 0.2 0.3)))

(: a A)
(: b TruthValue)

! (get-type b)
! (get-type a)
! (get-type )

! (get-type (STV 0.2 0.3) )
! (get-type (STV 0.2 0.3) )


; ! (get-type sami)
; ! (get-type dog)
; ! (get-type cat)