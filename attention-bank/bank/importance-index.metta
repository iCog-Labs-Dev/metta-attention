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

;it recives importance value(sti value) and return bin value
(: importanceBin (-> Number Number))
(= (importanceBin $impo)
   (if (< $impo 0)
       0 ; Importance is less than 0
       (if (< $impo (* 2 (GroupSize)))
           $impo ; Importance is within the first 2 groups
           (let $imp (ceil (/ (- $impo (GroupSize)) (GroupSize)))
               (let $i (findGroup $imp 0 0) ; Find the group index
                   (let $ad (- (GroupSize) (ceil (/ $impo (pow 2 (- $i 1)))))
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



