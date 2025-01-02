(: GROUP_SIZE Number)
(= (GROUP_SIZE) 8)

(: GROUP_NUM Number)
(= (GROUP_NUM) 12)

(: IMPORTANCE_INDEX_SIZE Number)
(= (IMPORTANCE_INDEX_SIZE) 104)

; Define importanceBin function
(: importanceBin (-> Number Number))
(= (importanceBin $impo)
   (if (< $impo 0)
       0 ; Importance is less than 0
       (if (< $impo (* 2 (GROUP_SIZE)))
           $impo ; Importance is within the first 2 groups
           (let $imp (ceil (/ (- $impo (GROUP_SIZE)) (GROUP_SIZE)))
               (let $i (find_group $imp 0 0) ; Find the group index
                   (let $ad (- (GROUP_SIZE) (ceil (/ $impo (pow 2 (- $i 1)))))
                       (let $bin (- (* $i (GROUP_SIZE)) $ad)
                           (if (> $bin (IMPORTANCE_INDEX_SIZE))
                               (IMPORTANCE_INDEX_SIZE)
                               $bin))))))))
