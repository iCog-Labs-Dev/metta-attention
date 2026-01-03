!(bind! &typeSpace (new-space))
(= (TypeSpace)
    &typeSpace
)

; updated data structure (atom (((STV mean conf) (AV sti lti vlti)) (Bin bin)))
; setAv function accepts a pattern (it could be a symbol or an expression) and attention values(contain STI, LTI and VLTI)
; and set the attention value as a type for the pattern. 
; then the pattern will be stored with attention value type in a space called typespace.

; i.e !(setAv Animal (399 400 1))
; we can get the type of the symbol animal using the function getValueType an it returns (AV 399 400 1).
; which means the atom called Animal now has STI = 399, LTI = 400 and VLTI = 1

; (: setAv (-> Atom (Number Number Number) Atom))
(= (setAv $pattern ($sti $lti $vlti))
    (let* (
        ($oldSti (getSti $pattern))
        ($oldLti (getLti $pattern))
        ($bin  (reduce (importanceBin $sti)))
        ($res (if (== (getValueType $pattern) %Undefined%)
                (add-atom &typeSpace ($pattern ((AV $sti $lti $vlti) (Bin $bin)) ))   
                   (let* 
                        (
                           ($stv (getStv $pattern))
                           ($value (match &typeSpace ($pattern $_) ($pattern $_)))
                           ($u (remove-atom &typeSpace $value))
                        )
                      (if (== $stv %Undefined%)
                          (add-atom &typeSpace ($pattern ((AV $sti $lti $vlti) (Bin $bin)) ))
                          (add-atom &typeSpace ($pattern (($stv (AV $sti $lti $vlti)) (Bin $bin)) )))
                   )
                )
           )

           ($stiDiff (- $oldSti $sti))
           ($ltiDiff (- $oldLti $lti))
        ;    ($_ (println! (lti $ltiDiff)))
           ($fundsSTI (getAttentionParam FUNDS_STI))
           ($fundsLTI (getAttentionParam FUNDS_LTI))
           ($newstifund (+ $fundsSTI $stiDiff))
           ($newltifund (+ $fundsLTI $ltiDiff))
        ;    ($hello (println! (new sti $newstifund)))
        ; ($hi (println! (inside setAv)))
           ($updater (attentionValueChanged $pattern $newstifund $newltifund))  ; Update attentional focus and global paremeter
           
    )
   ()
))


; Function to handle attention value changes and update global funds
; Description:
;    Updates the AttentionValue of an atom and adjusts the global STI and LTI funds
;    -set the new attention value of the atom 
;    - Remove the current FUNDS_STI and FUNDS_LTI values from the AtomSpace.
;    - Add the updated FUNDS_STI and FUNDS_LTI values to the AtomSpace.
;    - Inserts the atom to the attentional focus if possible
;    - Updates the Bin placement of the atom
;Parameters:
;     $pattern: The atom whose AttentionValue is being updated.
;     $newSTIFund: The new STI fund value.
;     $newLTIFund: The new LTI fund value.
;     $newAv: The new AttentionValue to be set for the atom.
;Returns: The result of updating the atomBin.


; (: attentionValueChanged (-> Atom Number Number Expression))
(= (attentionValueChanged $pattern $newSTIFund $newLTIFund)
   (let*(
         ($stiUpdated (updateAttentionParam FUNDS_STI $newSTIFund))
         ; ($_ (println! (getAttentionParam FUNDS_STI)))
         ($ltiUpdated (updateAttentionParam FUNDS_LTI $newLTIFund))

         ($globalUpdate  (update &typeSpace))
         ; ($_ (println! $globalUpdate))

         ; ($_ (println! (getAttentionParam MAX_STI)))
        )
        ()
    )
)

 ; set_stv function accepts a pattern/node with the truthvalues
 ; and set the simple truth value to the pattern/node.
 ; i.e !(set_stv A (0.1 0.9))
; (: setStv (-> Atom (Number Number) Atom))
(= (setStv $pattern ($mean $conf))
    (let $space (TypeSpace)
    (if (== (getValueType $pattern) %Undefined%)
        (add-atom $space ($pattern (STV $mean $conf)))
         (let* 
            (
                ($av (getAv $pattern))
                ($bin (getBin $pattern))
                ($value (match $space ($pattern $_) ($pattern $_)))
                ($b (remove-atom $space $value))
              )
            (if (== $av %Undefined%)
                (add-atom $space ($pattern (STV $mean $conf)))
                (add-atom $space ($pattern ( ((STV $mean $conf) $av) (Bin $bin))))))
    )
))



(= (getValueType $pattern) 
	(let $space (TypeSpace) 
        (let $a 
            (collapse (match $space ($pattern $value) $value))
            (if (== $a ())
                %Undefined%
                (car-atom $a)
            )
	)
)
)

 ; getAv function accepts a pattern/atom (it could be a symbol or an expression) and 
 ; returns the attention value attached to the atom.
 
 ; i.e !(getAv A)  output: (AV 400 400 1)


 (= (getAv $pattern)
 (case (getValueType $pattern)
   (
     ( ((AV $a $b $c) (Bin $bin)) (AV $a $b $c))
     ( (((STV $a $b) (AV $x $y $z)) (Bin $bin)) (AV $x $y $z))
     ($else %Undefined%)
     )
 )

)

; get the bin number of specific atom
(= (getBin $pattern)
(case (getValueType $pattern)
  (
    ( ((AV $a $b $c) (Bin $bin)) $bin)
    ( (((STV $a $b) (AV $x $y $z)) (Bin $bin)) $bin)
    ($else %Undefined%)
    )
)

)
 ; getStv function accepts a pattern/node and returns the simple truth
 ; value attaced to the pattern/node
 ;
 ; i.e !(getStv A)  output: (STV 0.1 0.9)


(= (getStv $pattern)
        (case (getValueType $pattern)
          (
            ( (STV $a $b) (STV $a $b))
            ( (((STV $a $b) (AV $x $y $z)) (Bin $bin)) (STV $a $b))
            ($else %Undefined%)
            )
        )

)


; getMean retrieves mean from a pattern
; i.e !(getMean A)  output: 1
; (: getMean (-> Atom Number))
(= (getMean $pattern)
    (case (getStv $pattern)
            ((%Undefined% 0.0)
            ((STV $mean $conf) $mean))
    )
)

; getConfidence retrieves Confidence from a pattern
; i.e !(getConfidence A)  output: 0.9 
; (: getConfidence (-> Atom Number))
(= (getConfidence $pattern)
    (case (getStv $pattern)
        ((%Undefined% 0)
        ((STV $mean $conf) $conf))
    )
)

; getSti retrieves STI from a pattern
; i.e !(getSti A)  output: 400 

; (: getSti (-> Atom Number))
(= (getSti $pattern)
    (case (getAv $pattern)
        ((%Undefined% 0.0)
        ((AV $sti $lti $vlti) $sti))
    )

)


; getLti retrieves LT from a pattern
; i.e !(getLti A)  output: 400 

; (: getLti (-> Atom Number))
(= (getLti $pattern)
    (case (getAv $pattern)
        ((%Undefined% 0.0)
        ((AV $sti $lti $vlti) $lti))
    )
)

; getVlti retrieves VLTI from a pattern
; i.e !(getLti A)  output: 1

; (: getVlti (-> Atom Number))
(= (getVlti $pattern)
    (case (getAv $pattern)
        ((%Undefined% 0.0)
        ((AV $sti $lti $vlti) $vlti)
        )
    )

)



;;setSTI function accepts a pattern/node with an Sti value to replace the original
;;and set the Sti to the pattern/node.
; i.e !(setSti A 500)
; (: setSti (-> Atom Number Atom)) 
(= (setSti $pattern $newSti)
    (case (getAv $pattern)
        ((%Undefined% (setAv $pattern ($newSti 0.0 0.0)))
        ((AV $sti $lti $vlti) (setAv $pattern ($newSti $lti $vlti))))
    )
)

;;setLti fnction accepts a pattern/node with an Lti value to replace the original
;;and set the Lti to the pattern/node.
; i.e !(setLti A 500)
; (: setLti (-> Atom Number Atom)) 
(= (setLti $pattern $newLTI)
    (case (getAv $pattern)
        ((%Undefined% (setAv $pattern  (0.0 $newLTI 0.0)))
        ((AV $sti $lti $vlti) (setAv $pattern ($sti $newLTI $vlti))))
    )
)

;;setVlti fnction accepts a pattern/node with an VLti value to replace the original
;;and set the VLti to the pattern/node.
; i.e !(setVlti A 500)
; (: setVlti (-> Atom Number Atom)) 
(= (setVlti $pattern $newVLTI)
    (case (getAv $pattern)
        ((%Undefined% (setAv $pattern  (0.0 0.0 $newVLTI)))
        ((AV $sti $lti $vlti) (setAv $pattern ($sti $lti $newVLTI))))
    )
)

;; globalIncomingSetByType a function that takes in an a pattern and retrives
;; all links it is an incoming set in and the predicate of the link is a defined type
;; used in Forgetting agent
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


;; globalIncomingSetByType a function that takes in an a pattern and retrives
;; all links it is an incoming set in
(= (globalIncomingSetwithoutType $atom)
    (globalIncomingSetByType $atom $_)
)

;; remoeTypeSpace a function that removes an atom from the typeSpace
;; used in Forgettingagent
; (: removeTypeSpace (-> Atom empty))
(= (removeTypeSpace $atom) 
	(let $a 
		(getValueType $atom)
		(if (== $a %Undefined%)
			()
			(remove-atom &typeSpace ($atom $a))
		)
	)
)


;; used to return all atoms that have an stv or an AV in typespace
; (: getAtomsInTypeSpace-helper (-> Expression))
(= (getAtomsInTypeSpace-helper) 
	(let $space (TypeSpace)
		(match $space ($pattern $x) $pattern)
	)
)

; Description : getAtomsInTypeSpace is a function that returns Expression of patterns in typespace
; params:
;	None
; return: Expression of patterns in the typeSpace without their types in and is more deterministic than matching
; (: getAtomsInTypeSpace (-> Expression))
(= (getAtomsInTypeSpace) 
	(collapse (getAtomsInTypeSpace-helper))
)

;; counts all atoms in the TypeSpace
(= (countAtomsInTypeSpace)
    (let $atoms
        (getAtomsInTypeSpace)
        (size-atom $atoms)
    )
)

; Function: getAtomsByBin
; Description: finds all atoms that is found in the specific bin
; parameters: 
;             - $binNumber: the bin number we will use to search atoms
; Returns: expression of atoms that have $binNumber bin

; (: getAtomsByBin (-> Number Expression))
(= (getAtomsByBin $binNumber)
    (collapse (match (TypeSpace) ($patt ($val (Bin $binNumber) ) ) $patt))
)

; Function: getAllAtomsWithBins
; Description: finds all atoms which have bin number
; Parameters: None
; Returns: Expression of atoms that have AV/bin number 
; (: getAllAtomsWithBins (-> Expression))
(= (getAllAtomsWithBins)
     (collapse (match (TypeSpace) ($patt ($val (Bin $binNumber))) $patt))
)

; Function: getSize
; Description: takes a bin number and calculate the size of atoms found in that bin
; Parameters: $binNumber
; Returns: size of atoms

; (: getSize (-> Number Number))
(= (getSize $binNumber)
    (let*(
        ($atoms (getAtomsByBin $binNumber))
        ($size (size-atom $atoms))
    ) 
    $size
    )
) 

; Function: getbinList
; Description: finds all bin numbers that contain at least one atom
; Parameters: space which we get bin numbers (TypeSpace)
; Returns: list of bin numbers

; (: getBinList (-> Grounded Expression))
(= (getBinList $space)
    (let $x (unique-atom (collapse (match $space ($patt ($val (Bin $num))) $num))) $x)
)

; Function: getnatoms
; Description: get n number of atoms from list of atoms
; Parameters: 
;             $atoms: list of atoms which it iterates
;             $n: the number of atoms it finds
; Return: expression of $n atoms
(= (getNatoms $atoms $n)
    (if (or (== $n 0.0) (== $atoms ()))
        ()
        (let* (
            (($head $tail) (decons-atom $atoms))
            ($res (getNatoms $tail (- $n 1.0))))
        (cons-atom $head $res)
        )
    )
)


(= (getStiHelper $atoms)
    (let
        $vals  (getSti (superpose $atoms))
    
    $vals
    )
)

; a function that find the maximum STI value of the  given atoms
; (: getAllMaxSTI  (-> Expression Number))
(= (getAllMaxSTI $atoms)
   (if (== $atoms ())
            0.0
            (let* (
                ($stiValues (collapse (getStiHelper $atoms)))
                ($maxSTI (max-atom $stiValues))
            )
            $maxSTI
            )
        )
    
)
; a function that find the minimum STI value of the  given atoms
; (: getAllMinSTI  (-> Expression Number))
(= (getAllMinSTI $atoms)
    (if (== $atoms ())
            0.0
            (let* (
                ($stiValues (collapse (getStiHelper $atoms)))
                ($minSTI (min-atom $stiValues))
            )
            $minSTI
            )
        )
    
)

(= (findMinNonEmptyBin $bin $max)
   (if (>= $bin $max)
       %Undefined%
       (if (> (getSize $bin) 0)
           $bin
           (findMinNonEmptyBin (+ $bin 1) $max)
       )
   )
)

(= (findMaxNonEmptyBin $bin)
   (if (< $bin 0)
       %Undefined%
       (if (> (getSize $bin) 0)
           $bin
           (findMaxNonEmptyBin (- $bin 1))
       )
   )
)


(= (getMinBinContents)
   (let $bins (findMinNonEmptyBin 0.0 104.0) (getAtomsByBin $bins))
)


(= (getMaxBinContents)
   (let $bins (findMaxNonEmptyBin 104.0) (getAtomsByBin $bins) )
)


(= (getSTIValues $atoms)
   (collapse (getStiHelper $atoms))
)

(= (computeMinSTI)
   (let $atoms (getMinBinContents)
        (if (== $atoms ())
            0.0
            (min-atom (getSTIValues $atoms))
        )
   )
)


(= (computeMaxSTI)
   (let $atoms (getMaxBinContents)
        (if (== $atoms ())
            0.0
            (max-atom (getSTIValues $atoms))
        )
   )
)

(= (clampMinSTI $minSTI $maxSTI)
   (if (> $minSTI $maxSTI)
       $maxSTI
       $minSTI)
)



(= (update $space)

    (let* (

       ($minSTI (computeMinSTI))
       ($maxSTI (computeMaxSTI))
       ($finalMin (clampMinSTI $minSTI $maxSTI))
       ($up  (updateAttentionParam MIN_STI $finalMin))
       ($upp (updateAttentionParam MAX_STI $maxSTI))
        )
         (trace! () ("Updated"))
    )
)
