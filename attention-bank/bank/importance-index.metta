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



