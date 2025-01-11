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
;Temporary need to be refactored!!

! (register-module! ../../../metta-attention)
! (import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
! (import! &self metta-attention:attention-bank:bank:atombins)
! (import! &self metta-attention:attention-bank:utilities:helper-functions)
! (bind! &globalVars (new-space))

; This is only for test purpose
!(add-atom &atombin (1 (a)))
!(add-atom &atombin (2 (d)))
!(add-atom &atombin (3 (c)))
!(add-atom &atombin (17 (s c)))
!(add-atom &atombin (18 (g j)))
!(add-atom &atombin (37 (f h j k)))

;Retrieves all the contents in atombin space
(= (getAllBinContents)
    (collapse (match &atombin ($x $y) ($x $y)))
)

;Extracts the index from binContent
(= (idxExractor $idx )
    (if (== $idx ())
        ()
        ( (let $temp (car-atom $idx) (car-atom $temp)) (idxExractor (cdr-atom $idx)))
    )
)

 ;simulation getContent
(= (getContent $max)
    (A B C)
)

; Retrieves the STI from tuple of Atoms
(= (getSTIFromList $atoms)
    (if (== $atoms ())
        ()
        ( (let $a (car-atom $atoms) (getSTI $a)) (getSTIFromList (cdr-atom $atoms)))
    )
)

;This function updates the global variables _minSTI and _maxSTI
(= (update)
    (let* (
            ($minBinContents (getAllBinContents))
            ($nums (idxExractor $minBinContents))
            ($max (max $nums))
            ($maxAtoms (getContent $max))
            ($allMaxSTI (getSTIFromList $maxAtoms))
            ($maxSTI (max $allMaxSTI))
            ($min (min $nums))
            ($minAtoms (getContent $min))
            ($allMinSTI (getSTIFromList $minAtoms))
            ($minSTI (min $allMinSTI))
            ($_ (remove-atom &globalVars (_minSTI $_)))
            ($_ (remove-atom &globalVars (_maxSTI $_)))
            ($_ (add-reduct &globalVars (_maxSTI $maxSTI)))
            ($_ (add-reduct &globalVars (_minSTI $minSTI)))
        )
        ("UPDATED")
    )
)

;####################### getMaxSTI ##################################
(= (getMaxSTI)
    (collapse (match &globalVars (_maxSTI $_) (_maxSTI $_)))
)

;####################### getMinSTI ##################################
(= (getMinSTI)
    (collapse (match &globalVars (_minSTI $_) (_minSTI $_)))
)


;####################### getHandleSet ##################################

; This functions retrievs bins between lowerBin and upperBin
(= (getBinsIn $lowerBin $upperBin)
    (if (== $lowerBin (+ 1 $upperBin))
        ()
        (let* (
                ($result (collapse (match &atombin ($lowerBin $_) ($lowerBin $_))))
            )
            (if (== $result ())
                (getBinsIn (+ $lowerBin 1) $upperBin)
                ( (let ($idx $content) (car-atom $result) $idx) (getBinsIn (+ $lowerBin 1) $upperBin))
            )
        )
    )
)

 ;Simulation Function
( = (getContentIf $binIndex)
    A
)

(= (binIndex $lowerBin $upperBin)
    (let $index (getBinsIn $lowerBin $upperBin)
        (contentExtractor $index)
    )
)

(= (contentExtractor ()) ())
(= (contentExtractor ($x $xs))
    ((getContentIf $x) (contentExtractor $xs))
)

;Receive lower and uper bound of sti and return atoms in that bound
(= (getHandleSet $lowerBound $upperBound)
    (if (or (< $lowerBound 0) (< $upperBound 0))
        ("Invalid bounds")
        (let* (
                ($lowerBin (importanceBin $lowerBound))
                ($upperBin (importanceBin $upperBound)))
            (binIndex $lowerBin $upperBin)
        )
    )
)

;####################### updateImportance ##################################

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
                    ($a (removeAtom $oldbin $atom))
                    ($b (addAtom $newbin $atom))
                    ($rem1 (remove-atom &atombin ($oldbin $elementOld)))
                    ($rem2 (remove-atom &atombin ($newbin $elementNew)))
                    ($add1 (add-atom &atombin ($newbin $b)))
                    ($add2 (add-atom &atombin ($oldbin $a)))
                )

            ("Importance Updated")))
    )
)

; Removes the atom from the tuple and return new tuple
(= (removeAtom $oldbin $atom)
    (let ($atomHolder) (collapse (match &atombin ($oldbin $atoms) $atoms))
        (removeHelper $atomHolder $atom )
    )
)

(= (removeHelper $tuple $value)
    (if (== $tuple ())
        ()
        (let $temp (car-atom $tuple)
            (if (== $temp $value)
                (removeHelper (cdr-atom $tuple) $value)
                (concatTuple ($temp) (removeHelper (cdr-atom $tuple) $value))
            )
        )
    )
)

; Add the atom to the tuple and return new tuple
(= (addAtom $newbin $atom)
    (let ($atomHolder) (collapse (match &atombin ($newbin $atoms) $atoms))
        (addHelper $atomHolder $atom )
    )
)

(= (addHelper $tuple $value)
    (if (== $tuple ())
        (cons-atom $value ())
        (let $temp (car-atom $tuple)
            (concatTuple ($temp) (addHelper (cdr-atom $tuple) $value))
        )
    )
)


! (updateImportance g 20 1)
! (match &atombin ($x $y) ($x $y))
! (update)
! (getMaxSTI)
! (getMinSTI)
! (getHandleSet 1 3)