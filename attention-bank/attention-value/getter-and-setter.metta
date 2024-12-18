! (register-module! ../../../metta-attention)



; set_av function accepts a pattern/node with the attention values
; and set the attention value to the pattern/node.
;
; i.e !(set_av A (399 400 1))

(= (set_av $pattern ($sti $lti $vlti))
    (if (== (get-type $pattern) %Undefined%)
        (add-atom &self (: $pattern (AV $sti $lti $vlti)))
        (let* (
                ( $stv (get_stv $pattern))
                ( $_ (let $x (collapse (match &self (: $pattern $_) (: $pattern $_)))
                        (let $y (car-atom $x)
                            (remove-atom &self $y)))))
            (if (== $stv (STV 0 0))
                (add-atom &self (: $pattern (AV $sti $lti $vlti)))
                (add-atom &self (: $pattern ($stv (AV $sti $lti $vlti)))))))
)

 
 ; get_av function accepts a pattern/node and returns the attention
 ; value attached to the pattern/node.
 ;
 ; i.e !(get_av A)  output: (AV 400 400 1)
 
(= (get_av $pattern)
    (case (get-type $pattern)
        (
            ( (AV $a $b $c) (get-type $pattern) )
            ( ( (STV $a $b) (AV $x $y $z)) (AV $x $y $z))
            ($else (AV 0 0 0)))
    )
)


; set_stv function accepts a pattern/node with the truthvalues
 ; and set the simple truth value to the pattern/node.
 ;
 ; i.e !(set_stv A (0.1 0.9))
 ;
(= (set_stv $pattern ($mean $conf))
    (if (== (get-type $pattern) %Undefined%)
        (add-atom &self (: $pattern (STV $mean $conf)))
        (let* ( ( $av (get_av $pattern))
                ($_ (let $x (collapse (match &self (: $pattern $_) (: $pattern $_)))
                        (let $y (car-atom $x)
                            (remove-atom &self $y)))))
            (if (== $av (AV 0 0 0))
                (add-atom &self (: $pattern (STV $mean $conf)))
                (add-atom &self (: $pattern ( (STV $mean $conf) $av)))))
    )
)


; get_stv function accepts a pattern/node and returns the simple truth
 ; value attaced to the pattern/node
 ;
 ; i.e !(get_stv A)  output: (STV 0.1 0.9)

(= (get_stv $pattern)
    (case (get-type $pattern)
        (
            ( (STV $x $y) (get-type $pattern) )
            ( ( (STV $x $y) (AV $a $b $c)) (STV $x $y))
            ($else (STV 1 0)))
    )
)
 ! (set_av A (200 200 0))
 ! (set_av A (400 400 1))

 ! (set_stv A (0.1 0.9))
 ! (set_stv A (1 0.9))

 ! (get_stv A)
 ! (get_av A)

 ! (get-type A)
