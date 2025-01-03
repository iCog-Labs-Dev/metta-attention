!(register-module! ../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)

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

; Function to insert an atom into the correct bin
!(bind! &atom-bin (new-space))
(: importanceBin (-> Symbol empty))
(= (insert_atom $pattern)
   (let $sti (getSTI $pattern)
      (let $bin_index (importanceBin $sti)
      (if (== (collapse(match &atom-bin  ($bin_index $x) $x)) ())
      (add-atom &atom-bin ($bin_index $pattern))
      (match  &atom-bin  ($bin_index $x)
          (let ()
           (remove-atom  &atom-bin  ($bin_index $x))
           (add-atom  &atom-bin ($bin_index ($pattern $x)))
          ))))))

!(set_av E (200 200 0))
!(insert_atom E)
!(match &atom-bin  (45 $x) $x)
!(set_av G (200 200 0))
!(insert_atom G)
!(match &atom-bin  (45 $x) $x)

