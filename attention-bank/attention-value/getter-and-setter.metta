!(bind! &typeSpace (new-space))

; setAv function accepts a pattern (it could be a symbol or an expression) and attention values(contain STI, LTI and VLTI)
; and set the attention value as a type for the pattern. 
; then the pattern will be stored with attention value type in a space called typespace.

; i.e !(setAv Animal (399 400 1))
; we can get the type of the symbol animal using the function getValueType an it returns (AV 399 400 1).
; which means the atom called Animal now has STI = 399, LTI = 400 and VLTI = 1

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
))

 ; getAv function accepts a pattern/atom (it could be a symbol or an expression) and 
 ; returns the attention value attached to the atom.
 
 ; i.e !(getAv A)  output: (AV 400 400 1)

(: getAv (-> Atom AV))
(= (getAv $pattern)
        (case (getValueType $pattern)
          (
            ( (AV $a $b $c) (AV $a $b $c))
            ( ((STV $a $b) (AV $x $y $z)) (AV $x $y $z))
            ($else %Undefined%)
            )
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
                            (remove-atom &typeSpace $x)
                            )))
              )
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
        (case (getValueType $pattern)
          (
            ( (STV $a $b) (STV $a $b))
            ( ((STV $a $b) (AV $x $y $z)) (STV $a $b))
            ($else %Undefined%)
            )
        )
    
)

(: getValueType (-> Atom Type))
(= (getValueType $pattern) 
	(let $a 
		(collapse (getValueTypeHelper $pattern))
		(if (== $a ())
			%Undefined%
			(car-atom $a)
		)
	)
)

(: getValueTypeHelper (-> Atom Type))
(= (getValueTypeHelper $pattern) 
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

; getSti retrieves STI from a pattern
; i.e !(getSti A)  output: 400 

(: getSti (-> Atom Number))
(= (getSti $pattern)
    (case (getAv $pattern)
        ((%Undefined% 0)
        ((AV $sti $lti $vlti) $sti))
    )
        
)


; getLti retrieves LT from a pattern
; i.e !(getLti A)  output: 400 

(: getLti (-> Atom Number))
(= (getLti $pattern)
    (case (getAv $pattern)
        ((%Undefined% 0)
        ((AV $sti $lti $vlti) $lti))
    )
)

; getVlti retrieves VLTI from a pattern
; i.e !(getLti A)  output: 1

(: getVlti (-> Atom Number))
(= (getVlti $pattern)
    (case (getAv $pattern)
        ((%Undefined% 0)
        ((AV $sti $lti $vlti) $vlti)
        )
    )

)


; (= (getType $pattern) (get-type-space &typeSpace $pattern))


;;setSti fnction accepts a pattern/node with an Sti value to replace the original

;;and set the Sti to the pattern/node.
; i.e !(setSti A 500)
(: setSti (-> Atom Number Atom)) 
(= (setSti $pattern $newSTI)
    (case (getAv $pattern)
        ((%Undefined% (setAv $pattern ($newSTI 0 0)))
        ((AV $sti $lti $vlti) (setAv $pattern ($newSTI $lti $vlti))))
    )
)


;;setLti fnction accepts a pattern/node with an Lti value to replace the original

;;and set the Lti to the pattern/node.
; i.e !(setLti A 500)
(: setLti (-> Atom Number Atom)) 
(= (setLti $pattern $newLTI)
    (case (getAv $pattern)
        ((%Undefined% (setAv $pattern  (0 $newLTI 0)))
        ((AV $sti $lti $vlti) (setAv $pattern ($sti $newLTI $vlti))))
    )
)


;;setVlti fnction accepts a pattern/node with an VLti value to replace the original

;;and set the VLti to the pattern/node.
; i.e !(setVlti A 500)
(: setVlti (-> Atom Number Atom)) 
(= (setVlti $pattern $newVLTI)
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
