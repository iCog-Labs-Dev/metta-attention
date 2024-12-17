! (register-module! ../metta-attention)
! (import! &self types)

 ;Utility functions for checking if expression is tuple or not
 ;Need to be refactored
 ;################################################
(= (is_tuple $pattern)
    (if (== (tuple_count $pattern) 2)
        True
        False
    )
)

(= (tuple_count $atom)
    (if (== $atom ())
        0
        (+ 1 (tuple_count (cdr-atom $atom))))
)
 ;#################################################
(= (set_av $pattern ($sti $lti $vlti))
    (if (== (get-type $pattern) %Undefined%)
        (add-atom &self (: $pattern (AV $sti $lti $vlti)))
        (let* (
                ($type (get-type $pattern))
                ( ($stv $av)
                    (if (is_tuple $type)
                        $type
                        (if (unify $type (STV $r1 $r2) True False)
                            ( $type (AV 0 0 0))
                            ( (STV 0 0) $type)))))
            (let $_
                (if (is_tuple $type)
                    (let $x (collapse (match &self (: $pattern ( (STV $a $b) (AV $x $y $z))) (: $pattern ( (STV $a $b) (AV $x $y $z)))))
                        (let $y (car-atom $x)
                            (remove-atom &self $y)))
                    (if (== $stv (STV 0 0))
                        (let $x (collapse (match &self (: $pattern (AV $x $y $z)) (: $pattern (AV $x $y $z))))
                            (let $y (car-atom $x)
                                (remove-atom &self $y)))
                        (let $x (collapse (match &self (: $pattern (STV $x $y)) (: $pattern (STV $x $y))))
                            (let $y (car-atom $x)
                                (remove-atom &self $y)))))
                (if (== $stv (STV 0 0))
                    (add-atom &self (: $pattern (AV $sti $lti $vlti)))
                    (add-atom &self (: $pattern ($stv (AV $sti $lti $vlti)))))))
    )
)

(= (get_av $pattern)
    (if (== (get-type $pattern) %Undefined%)
        (AV 0 0 0)
        (let* (
                ($type (get-type $pattern))
                ( ($stv $av)
                    (if (is_tuple $type)
                        $type
                        (if (unify (STV $x $y) $type True False)
                            ( $type (AV 0 0 0))
                            ( (STV 0 0) $type)))))
            $av)
    )
)

 ;  ;########################### Test for seting and getting AV ###########################
 ; (: A (STV 10 20) ) ;You can comment this out.
 ; ! (set_av A (1 2 1))
 ; ! (set_av A (2 2 1))
 ; ! (set_av A (23 23 23))
 ; ! (get_av A)
 ; ! (match &self (: A $x ) (: A $x ))
 ;######################## End for av manipulation #####################################

 ; Assuming we represent pattern as (Node (AtomValues))
(= (set_stv $pattern ($mean $conf))
    (if (== (get-type $pattern) %Undefined%)
        (add-atom &self (: $pattern (STV $mean $conf)))
        (let* ( ($type (get-type $pattern))
                ( ($stv $av)
                    (if (is_tuple $type)
                        $type
                        (if (let $x $type (unify $x (STV $r1 $r2) True False))
                            ( $type (AV 0 0 0))
                            ( (STV 0 0) $type)))))

            (let $_
                (if (is_tuple $type)
                    (let $x (collapse (match &self (: $pattern ( (STV $a $b) (AV $x $y $z))) (: $pattern ( (STV $a $b) (AV $x $y $z)))))
                        (let $y (car-atom $x)
                            (remove-atom &self $y)))
                    (if (== $stv (STV 0 0))
                        (let $x (collapse (match &self (: $pattern (AV $x $y $z)) (: $pattern (AV $x $y $z))))
                            (let $y (car-atom $x)
                                (remove-atom &self $y)))
                        (let $x (collapse (match &self (: $pattern (STV $x $y)) (: $pattern (STV $x $y))))
                            (let $y (car-atom $x)
                                (remove-atom &self $y)))))
                (if (== $av (AV 0 0 0))
                    (add-atom &self (: $pattern (STV $mean $conf)))
                    (add-atom &self (: $pattern ( (STV $mean $conf) $av))))))
    )
)

(= (get_stv $pattern)
    (if (== (get-type $pattern) %Undefined%)
        (STV 0 0 0)
        (let* ( ($type (get-type $pattern))
                ( ($stv $av)
                    (if (is_tuple $type)
                        $type
                        (if (unify (STV $x $y) $type True False )
                            ( $type (AV 0 0 0))
                            ( (STV 0 0) $type )))))
            $stv)
    )
)

 ;########################### Test for seting and getting STV ##########################
 ; (: A (STV 10 20) ) ;You can comment this out.
 ; ! (set_stv A (1 1))
 ; ! (set_stv A (2 1))
 ; ! (set_stv A (23 23))
 ; ! (get_stv A)
 ; ! (get_av A)
 ; ! (match &self (: A $x ) (: A $x ))
 ;######################## End for av manipulation #####################################