!(bind! &typeSpace (new-space))

; set_av function accepts a pattern/node with the attention values
; and set the attention value to the pattern/node.
;
; i.e !(set_av A (399 400 1))

(: setAv (-> Atom (Number Number Number) Atom))
(= (setAv $pattern ($sti $lti $vlti))
    (let* (
        ($oldSTI (getSTI $pattern))
        ($oldLTI (getLTI $pattern))
        ($updateimpo (updateImportance (AtomBin) $pattern $oldSTI $sti))
        ($res (if (== (getValueType $pattern) %Undefined)
                   (add-atom &typeSpace ($pattern (AV $sti $lti $vlti)))
                   (let* (
                           ($stv (getStv $pattern))
                           ($_ (let $x (collapse (match &typeSpace ($pattern $_) ($pattern $_)))
                                   (if (== $x ())
                                       ()
                                       (let $y (car-atom $x) (remove-atom &typeSpace $y))
                                   )
                               )
                           )
                         )
                      (if (== $stv %Undefined%)
                          (add-atom &typeSpace ($pattern (AV $sti $lti $vlti)))
                          (add-atom &typeSpace ($pattern ($stv (AV $sti $lti $vlti)))))
                   )
                )
           )
          
           ($stiDiff (- $oldSTI $sti))
           ($ltiDiff (-  $oldLTI $lti))
           ($fundsSTI (getAttentionBank fundsSTI))
           ($fundsLTI (getAttentionBank fundsLTI))
           ($newstifund (+ $fundsSTI $stiDiff))
           ($newltifund (+ $fundsLTI $ltiDiff))
           ($updater (attentionValueChanged $pattern $newstifund $newltifund))  ; Update attentional focus and global paremeter
    )
   ()
)
)

 ; getAv function accepts a pattern/node and returns the attention
 ; value attached to the pattern/node.
 ;
 ; i.e !(getAv A)  output: (AV 400 400 1)

(: getAv (-> Atom AV))
(= (getAv $pattern)
    (if (== (get-metatype $pattern) Expression)
        (case (getValueType $pattern)
            (( (AV $a $b $c) (AV $a $b $c))
                    ( ( (STV $a $b) (AV $x $y $z)) (AV $x $y $z))
                    ($else %Undefined%))
        )
        (case (getValueType $pattern)
                (( (AV $a $b $c) (AV $a $b $c))
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
    (if (== (getValueType $pattern) %Undefined%)
        (add-atom &typeSpace ($pattern (STV $mean $conf)))
        (let* ( ( $av (getAv $pattern))
                ($_ (let $x (collapse (match &typeSpace ($pattern $_) ($pattern $_)))
                        (if (== $x ())
                            ()
                            (let $y (car-atom $x) (remove-atom &typeSpace $y))
                            ))))
            (if (== $av %Undefined%)
                (add-atom &typeSpace ($pattern (STV $mean $conf)))
                (add-atom &typeSpace ($pattern ( (STV $mean $conf) $av)))))
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
                ($else %Undefined%))
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
	(let $a 
		(collapse (getValueType-helper $pattern))
		(if (== $a ())
			%Undefined%
			(car-atom $a)
		)
	)
)

(: getValueType-helper (-> Atom Type))
(= (getValueType-helper $pattern) 
	(let $a 
		(match &typeSpace ($pattern $value) $value) 
		(unify $a  
			(AV $sti $lti $vlti) 
			(AV $sti $lti $vlti)
			(unify $a
				(STV $mean $conf)
				(STV $mean $conf)
				(unify $a
					((STV $mean $conf) (AV $sti $lti $vlti))
					((STV $mean $conf) (AV $sti $lti $vlti))
					(empty)
				)
			)
		)
	)
)

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


(= (getType $pattern) (get-type-space &typeSpace $pattern))

;;setSTI function accepts a pattern/node with an Sti value to replace the original
;;and set the Sti to the pattern/node.
; i.e !(setSTI A 500)
(: setSTI (-> Atom Number Atom)) 
(= (setSTI $pattern $newSTI)
    (case (getAv $pattern)
        ((%Undefined% (setAv $pattern ($newSTI 0 0)))
        ((AV $sti $lti $vlti) (setAv $pattern ($newSTI $lti $vlti))))
    )
)

;;setLTI function accepts a pattern/node with an Lti value to replace the original
;;and set the Lti to the pattern/node.
; i.e !(setLTI A 500)
(: setLTI (-> Atom Number Atom)) 
(= (setLTI $pattern $newLTI)
    (case (getAv $pattern)
        ((%Undefined% (setAv $pattern  (0 $newLTI 0)))
        ((AV $sti $lti $vlti) (setAv $pattern ($sti $newLTI $vlti))))
    )
)

;;setVLTI function accepts a pattern/node with an VLti value to replace the original
;;and set the VLti to the pattern/node.
; i.e !(setVLTI A 500)
(: setVLTI (-> Atom Number Atom)) 
(= (setVLTI $pattern $newVLTI)
    (case (getAv $pattern)
        ((%Undefined% (setAv $pattern  (0 0 $newVLTI)))
        ((AV $sti $lti $vlti) (setAv $pattern ($sti $lti $newVLTI))))
    )
)

(= (globalIncomingSetByType $atom $type)
	(collapse
		(superpose   
			(
				(match &typeSpace (($type $b $atom) $a) ($type $b $atom))
				(match &typeSpace (($type $atom $b) $a) ($type $atom $b ))
			)
    )
	)
)

(= (globalIncomingSetwithoutType $atom)
    (collapse 
        (superpose   
            (
				(match &typeSpace (($type $b $atom) $a) ($type $b $atom))
				(match &typeSpace (($type $atom $b) $a) ($type $atom $b ))
            )
        )  
    )
)

(: removeTypeSpace (-> Atom empty))
(= (removeTypeSpace $atom) 
	(let $a 
		(getValueType $atom)
		(if (== $a %Undefined%)
			()
			(remove-atom &typeSpace ($atom $a))
		)
	)
)

; (: TypeSpace (-> Grounded))
(= (TypeSpace)
	&typeSpace
)



(: getAtomsInTypeSpace-helper (-> List))
(= (getAtomsInTypeSpace-helper) 
	(let $a 
		(get-atoms &typeSpace)
		(unify $a
			($pattern $x)
			$pattern
			(empty)
		)
	)
)

; Description : getAtomsInTypeSpace is a function that returns a list of patterns in typespace
; params:
;	None
; return: List of patterns in the typeSpace without their types in and is more deterministic than matching
(: getAtomsInTypeSpace (-> List))
(= (getAtomsInTypeSpace) 
	(collapse (getAtomsInTypeSpace-helper))
)

(= (countAtomsInTypeSpace)
    (let $atoms
        (getAtomsInTypeSpace)
        (size-atom $atoms)
    )
)
