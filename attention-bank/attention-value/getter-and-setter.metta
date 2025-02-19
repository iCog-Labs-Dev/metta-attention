; set_av function accepts a pattern/node with the attention values
; and set the attention value to the pattern/node.
;
; i.e !(set_av A (399 400 1))
(: setAv (-> Atom (Number Number Number) Atom))
(= (setAv $pattern ($sti $lti $vlti))
    (if (== (collapse (getValueType $pattern)) ())
        (add-atom &self (: $pattern (AV $sti $lti $vlti)))
        (let* (
                ( $stv (getStv $pattern))
                ( $_ (let $x (collapse (match &self (: $pattern $_) (: $pattern $_)))
                        (if (== $x ())
                            ()
                            (let $y (car-atom $x) (remove-atom &self $y))
                            ))))
            (if (== $stv %Undefined%); 
                (add-atom &self (: $pattern (AV $sti $lti $vlti)))
                (add-atom &self (: $pattern ($stv (AV $sti $lti $vlti)))))))
)

 ; getAv function accepts a pattern/node and returns the attention
 ; value attached to the pattern/node.
 ;
 ; i.e !(getAv A)  output: (AV 400 400 1)

(: getAv (-> Atom AV))
(= (getAv $pattern)
    (if (== (get-metatype $pattern) Expression)
        (case (let $a (collapse (let $x (getValueType $pattern) (collapse (superpose $x)))) (index-atom $a 0))
            (( (AV $a $b $c) (AV $a $b $c))
                    ( ( (STV $a $b) (AV $x $y $z)) (AV $x $y $z))
                    ($else (AV 0 0 0)))
        )
        (case (getValueType $pattern)
                (( (AV $a $b $c) (getValueType $pattern))
                    ( ( (STV $a $b) (AV $x $y $z)) (AV $x $y $z))
                    ($else %Undefined%)))
    )
)


 ; set_stv function accepts a pattern/node with the truthvalues
 ; and set the simple truth value to the pattern/node.
 ;
 ; i.e !(set_stv A (0.1 0.9))
 ;

 (: setStv (-> Atom (Number Number) Atom))
(= (setStv $pattern ($mean $conf))
    (if (== (collapse (getValueType $pattern)) ())
        (add-atom &self (: $pattern (STV $mean $conf)))
        (let* ( ( $av (getAv $pattern))
                ($_ (let $x (collapse (match &self (: $pattern $_) (: $pattern $_)))
                        (if (== $x ())
                            ()
                            (let $y (car-atom $x) (remove-atom &self $y))
                            ))))
            (if (== $av %Undefined%)
                (add-atom &self (: $pattern (STV $mean $conf)))
                (add-atom &self (: $pattern ( (STV $mean $conf) $av)))))
    )
)

 ; getStv function accepts a pattern/node and returns the simple truth
 ; value attaced to the pattern/node
 ;
 ; i.e !(getStv A)  output: (STV 0.1 0.9)

(: getStv (-> Atom STV))
(= (getStv $pattern)
    (if (== (get-metatype $pattern) Expression)
            (case (let $a (collapse (let $x (getValueType $pattern) (collapse (superpose $x)))) (index-atom $a 0))
                (( (STV $x $y) (STV $x $y) )
                ( ( (STV $x $y) (AV $a $b $c)) (STV $x $y))
                ($else (STV 1 0)))
        )
        (case (getValueType $pattern)
            (
                ( (STV $x $y) (getValueType $pattern) )
                ( ( (STV $x $y) (AV $a $b $c)) (STV $x $y))
                ($else %Undefined%))
        )
    )
)


(: getValueType (-> Atom Type))
(= (getValueType $pattern) 
   (let $t (get-type $pattern) (if (== $t %Undefined%) (empty) $t)))


; getMean retrieves mean from a pattern
; i.e !(getMean A)  output: 1 

(: getMean (-> Atom Number))
(= (getMean $pattern)
    (case (getStv $pattern)
        ((%Undefined% 0)
        ((STV $mean $conf) $mean))
    )
)

; getConfidence retrieves Confidence from a pattern
; i.e !(getConfidence A)  output: 0.9 
(: getConfidence (-> Atom Number))
(= (getConfidence $pattern)
    (case (getStv $pattern)
        ((%Undefined% 0)
        ((STV $mean $conf) $conf))
    )
)

; getSTI retrieves STI from a pattern
; i.e !(getSTI A)  output: 400 

(: getSTI (-> Atom Number))
(= (getSTI $pattern)
    (case (getAv $pattern)
        ((%Undefined% 0)
        ((AV $sti $lti $vlti) $sti))
    )
        
)


; getLTI retrieves LT from a pattern
; i.e !(getLTI A)  output: 400 

(: getLTI (-> Atom Number))
(= (getLTI $pattern)
    (case (getAv $pattern)
        ((%Undefined% 0)
        ((AV $sti $lti $vlti) $lti))
    )
)

; getVLTI retrieves VLTI from a pattern
; i.e !(getLTI A)  output: 1

(: getVLTI (-> Atom Number))
(= (getVLTI $pattern)
    (case (getAv $pattern)
        ((%Undefined% 0)
        ((AV $sti $lti $vlti) $vlti)
        )
    )

)

(= (getType $pattern) (get-type $pattern))
