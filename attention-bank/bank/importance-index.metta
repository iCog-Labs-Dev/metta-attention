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

;get all contents that are in atombin indices
;filter out empty contents
;find maximum sti
;find minumum sti
;if min_sti > max_sti: min_sti = max_sti
;_min_sti = min_sti, max_sti = max_sti

(: update (-> hyperon::space::DynSpace Atom))
(= (update $space)
    (let* (
            ($nums (idxExractor $space))
            ($vals (collapseAtomBin $space))
            ($filteredVals (filter $vals notEmpty))
            ($collectedContents (collectContents $filteredVals ()))
            ($max (findMaxSTI $collectedContents))
            ($min (findMinSTI $collectedContents))
            ($exitCondition (> $min $max))
        )
        (if $exitCondition
            (updateGlobalVars $max $max)
            (updateGlobalVars $min $max)
          )
    )
)

(= (updateGlobalVars $min $max)
   (let* (
            ($_ (remove-atom &globalVars (_minSTI $_)))
            ($_ (remove-atom &globalVars (_maxSTI $_)))
            ($_ (add-reduct &globalVars (_maxSTI $max)))
            ($_ (add-reduct &globalVars (_minSTI $min)))
          )
     ("Updated")
    )
)

;TODO.recent and .val need to be explored this are from the C++
; The getMaxSTI function returns the maxSTI from the &globalVars space
; which is the space that stores the global variables
; i.e (getMaxSTI) output: (_maxSTI Number)


;####################### updateImportance ##################################

; the updateImportance function receives atom, old and new sti value and updates 
; its bin location or update its position according to the new sti
;
; i.e (updateImportance a 1 100) output: "Importance Updated"
;
; What this does is remove the a atom from the 1st bin index and add it to the index
; that the STI 100 belongs to.

(: updateImportance (-> hyperon::space::DynSpace Atom Number Number Atom))
(= (updateImportance $space $atom $oldSTI $newSTI)
    (let* (
            ($oldBin (importanceBin $oldSTI))
            ($newBin (importanceBin $newSTI)))
        (if (== $oldBin $newBin)
            ()
            (let $result (relocateAtom $oldBin $newBin $atom)
              (if $result ("Importance Updated") ("Importance Not Updated"))
            )
        )
    )
)

(: relocateAtom (-> Number Number Symbol Bool))
(= (relocateAtom $oldBin $newBin $atom)
   (let $res1 (removeAtom $oldBin $atom)
     (if (or (== $res1 ("Atom is not valid")) (== $res1 ("Bin is empty")))
       False
       (== (insertAtom $newBin $atom) ("Atom Inserted"))
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

(: loop (-> Number Number Expression Expression))
(= (loop $i $term $acc)
   (if(== $i $term)
      $acc
      (let $next (+ 1 $i) (loop $next $term (getContent $i $acc)))
    )
)

(: getHandleSet (-> Number Number Expression))
(= (getHandleSet $lowerBound $upperBound)
   (if (or (< $lowerBound 0) (< $upperBound 0))
     ()
     (let*
       (
        ($lowerBin (importanceBin $lowerBound))
        ($upperBin (importanceBin $upperBound))
        ($gcIfRes (getContentIf $lowerBin pred $lowerBound $upperBound ())) ;gcIfRes - getContentIfResult (result obtained after calling getContentIf)
        ($exitCondition (== $upperBin $lowerBin))
        ($gcRes (loop $lowerBin $upperBin $gcIfRes)) ;gcRes - getContentResult (result obtained after calling getContent)
        ($res (getContentIf $upperBin pred $lowerBound $upperBound $gcRes))
        ($finalResult (if $exitCondition (removeDuplicates $gcIfRes) (removeDuplicates $res))) ;remove duplicates because the result needs to be a set of atoms.
      )
       $finalResult
    )
  )
)
