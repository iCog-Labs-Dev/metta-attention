; importance management functions can be implemented here in this file.

; functions like the following


; - importanceBin - it recives importance value(sti value) and return bin value
; - updateImportance - it recives atom, old and new sti value and updates its bin location or update its position
; - update - update the global variables max sti and min sti value
; - getmaxsti - return the max sti value
; - getminsti - return the min sti value
; - getHandleSet - recive lower and uper bound of sti and return atoms in that bound
; - getMaxBinContents - return atoms found in max bin index
; - getMinBinContents - return atoms found in min bin index
; - bin_size - return the total bin size
; - size - it recives atom bin index and return the size or total number of atoms found inside that bin index

! (bind! &globalVars (new-space))

(: GroupSize Number)
(= (GroupSize) 8)

(: GroupNum Number)
(= (GroupNum) 12)

(: ImportanceIndexSize Number)
(= (ImportanceIndexSize) 104)

(: importanceBin (-> Number Number))
; Function to calculate the bin for a given importance value
(= (importanceBin $impo)
   (let $impo_int (truncate $impo) ; Ensure $impo is treated as an integer
      (if (< $impo_int 0)
          0 ; Importance is less than 0
          (if (< $impo_int (* 2 (GroupSize)))
              $impo_int ; Importance is within the first 2 groups
              (let $imp (ceil (/ (- $impo_int (GroupSize)) (GroupSize)))
                 (let $i (findGroup $imp 0 0) ; Find the group index
                    (let $ad (- (GroupSize) (ceil (/ $impo_int (pow 2 (- $i 1)))))
                       (let $bin (- (* $i (GroupSize)) $ad)
                          (if (> $bin (ImportanceIndexSize))
                              (ImportanceIndexSize)
                              $bin
                           )
                        )
                     )
                  )
               )
         )
      )
   )
)

;####################### update ##################################

; Retrieves all the indices from the $space in this case is
; the &atombin space and return them to the caller
;
; i.e (idxExractor &atombin) will return all the indices in &atombin

(: idxExractor (-> hyperon::space::DynSpace Tuple))
(= (idxExractor $space)
    (collapse (match $space ($x $y) $x))
)

;This function receives atom, old and new sti value and updates its bin location or update its position
(= (updateImportance $atom $oldav $newav)
    (let* (
            ($oldbin (importanceBin $oldav))
            ($newbin (importanceBin $newav)))
        (if (== $oldbin $newbin)
            ()
            (let*  (
                    ( ($elementOld) (collapse (match &atombin ($oldbin $atoms) $atoms)))
                    ( ($elementNew) (collapse (match &atombin ($newbin $atoms) $atoms)))
                    ($a (remove-Atom $oldbin $atom))
                    ($b (addAtom $newbin $atom))
                    ($rem1 (remove-atom &atombin ($oldbin $elementOld)))
                    ($rem2 (remove-atom &atombin ($newbin $elementNew)))
                    ($add1 (add-atom &atombin ($newbin $b)))
                    ($add2 (add-atom &atombin ($oldbin $a)))
                )

            ("Importance Updated")))
    )
)


; Retrieves all the STIs of the atoms in the tuple
;
; i.e (getSTIFromTuple (1 2 3)) will return sti values like (100 (200 (50))
(: getSTIFromTuple (-> Atoms (-> Atoms)))
(= (getSTIFromTuple $atoms)
    (if (== $atoms ())
        ()
        ( (let $a (car-atom $atoms) (getSTI $a)) (getSTIFromTuple (cdr-atom $atoms)))
    )
)

; This function updates the global variables _minSTI and _maxSTI for
; use by other methods or functions that need them
; the space that will be passed is the space that the atoms are stored in
;
; i.e (update &atombin) will update the global variables _minSTI and _maxSTI

(: update (-> hyperon::space::DynSpace Atom))
(= (update $space)
    (let* (
            ($nums (idxExractor $space))
            ($max (Max $nums))
            ($maxAtoms (getContent $max ()))
            ($allMaxSTI (getSTIFromTuple $maxAtoms))
            ($maxSTI (maxList $allMaxSTI))
            ($min (Min $nums))
            ($minAtoms (getContent $min ()))
            ($allMinSTI (getSTIFromTuple $minAtoms))
            ($minSTI (minList $allMinSTI))
            ($_ (remove-atom &globalVars (_minSTI $_)))
            ($_ (remove-atom &globalVars (_maxSTI $_)))
            ($_ (add-reduct &globalVars (_maxSTI $maxSTI)))
            ($_ (add-reduct &globalVars (_minSTI $minSTI)))
        )
        ("Updated")
    )
)

;.recent and .val need to be explored this are from the C++
; The getMaxSTI function returns the maxSTI from the &globalVars space
; which is the space that stores the global variables
; i.e (getMaxSTI) output: (_maxSTI Number)

(: getMaxSTI (-> Tuple))
(= (getMaxSTI)
    (let $temp (collapse (match &globalVars (_maxSTI $_) (_maxSTI $_))) (car-atom $temp))
)

;.recent and .val need to be explored this are from the C++
; The getMinSTI function returns the minSTI from the &globalVars space
; which is the space that stores the global variables
; i.e (getMinSTI) output: (_minSTI Number) 

(: getMinSTI (-> Tuple))
(= (getMinSTI)
    (let $temp (collapse (match &globalVars (_minSTI $_) (_minSTI $_))) (car-atom $temp))
)


;####################### updateImportance ##################################

; the updateImportance function receives atom, old and new sti value and updates 
; its bin location or update its position according to the new sti
;
; i.e (updateImportance a 1 100) output: "Importance Updated"
;
; What this does is remove the a atom from the 1st bin index and add it to the index
; that the STI 100 belongs to.

(: updateImportance (-> hyperon::space::DynSpace Atom Number Number Atom))
(= (updateImportance $space $atom $oldav $newav)
    (let* (
            ($oldbin (importanceBin $oldav))
            ($newbin (importanceBin $newav)))
        (if (== $oldbin $newbin)
            ()
            (let*  (
                    ( ($elementOld) (collapse (match $space ($oldbin $atoms) $atoms)))
                    ( ($elementNew) (collapse (match $space ($newbin $atoms) $atoms)))
                    ($a (removeAtom $oldbin $atom))
                    ($b (insertAtom $newbin $atom))
                    ($rem1 (remove-atom $space ($oldbin $elementOld)))
                    ($rem2 (remove-atom $space ($newbin $elementNew)))
                )

            ("Importance Updated")
            )
        )
    )
)

(: pred (-> Symbol Number Number Bool))
(= (pred $x $lower $higher) (
    let $sti (getSTI $x) 
      (and 
        (>=  $sti $lower) 
        (<=  $sti $higher)
      )
  )
)

(= (loop $i $term $acc)
   (if(== $i $term)
      $acc
      (getContent (+ 1 $i) $acc)
   )
)

(= (getHandleSet $lowerBound $upperBound)
   (if (or (< $lowerBound 0) (< $upperBound 0))
     ()
     (let*
       ($lowerBin (importanceBin $lowerBound))
       ($upperBin (importanceBin $upperBound))
       ($gcIfRes (getContentIf $lowerBin pred $lowerBound $upperBound ())) ;gcIfRes - getContentIfResult (result obtained after calling getContentIf)
       ($exitCondition (== $upperBin $lowerBin))
       ($gcRes (loop $lowerBin $upperBin $gcIfRes)) ;gcRes - getContentResult (result obtained after calling getContent)
       ($finalResult (getContentIf $upperBin pred $lowerBound $upperBound $gcRes))
      )
      (if $exitCondition
        $gcIfRes
        $finalResult
      )
    )
)
