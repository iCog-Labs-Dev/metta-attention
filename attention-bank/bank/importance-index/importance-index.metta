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

; Function to calculate the bin for a given importance value
(: importanceBin (-> Number Number))
(= (importanceBin $impo)
   (
    let*
    (
      ($groupSize (GroupSize))
      ($impo_int (truncate $impo)) ; Ensure $impo is treated as an integer
      ($firstCondition (< $impo_int 0))
      ($secondCondition (< $impo_int (* 2 $groupSize)))
    )
    (if $firstCondition
      0
      (if $secondCondition
        $impo_int
        (let*
          (
            ($imp (ceil (/ (- $impo_int $groupSize) $groupSize)))
            ($i (findGroup $imp 0 0))
            ($temp (ceil (/ $impo_int (pow 2 (- $i 1)))))
            ($ad (- $groupSize $temp))
            ($bin (- (* $i $groupSize) $ad))
          )
          $bin
        )
      )
    )
  )
)

;####################### update ##################################

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
            ($nums (collapse (match $space ($x $y) $x)))
            ($vals (collapseAtomBin $space))
            ($filteredVals (filter $vals notEmpty))
            ($collectedContents (collectContents $filteredVals ()))
            ($max (findMaxSTI $collectedContents))
            ($min (findMinSTI $collectedContents))
            ($exitCondition (> $min $max))
        )
        (if $exitCondition
            (updateGlobalMaxAndMinSTI $max $max)
            (updateGlobalMaxAndMinSTI $min $max)
          )
    )
)

(= (updateGlobalMaxAndMinSTI $min $max)
    (let*
      (
       ($firstRes (updateMin $min))
       ($secondRes (updateMax $max))
      )
      ("Updated")
     )
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

(: loop (-> Number Number $list_t $list_t $list_t))
(= (loop $i $term $atomBins $acc)
   (if(== $i $term)
      $acc
      (let $next (+ 1 $i) (loop $next $term $atomBins (getContent $i $atomBins $acc)))
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
        ($atomBins (collapseAtomBin (AtomBin)))
        ($gcIfRes (getContentIf $lowerBin pred $lowerBound $upperBound $atomBins ())) ;gcIfRes - getContentIfResult (result obtained after calling getContentIf)
        ($exitCondition (== $upperBin $lowerBin))
        ($gcRes (loop $lowerBin $upperBin $atomBins $gcIfRes)) ;gcRes - getContentResult (result obtained after calling getContent)
        ($res (getContentIf $upperBin pred $lowerBound $upperBound $atomBins $gcRes))
        ($finalResult (if $exitCondition (removeDuplicates $gcIfRes) (removeDuplicates $res))) ;remove duplicates because the result needs to be a set of atoms.
      )
       $finalResult
    )
  )
)

(: getMaxSTI (-> Bool Number))
(= (getMaxSTI $avg) 
   (let $recentVal (RecentVal)
    (if $avg
      (match $recentVal (recent_max $_) $_)
      (match $recentVal (value_max $_) $_)
      )
   )
)

(: getMaxSTI (-> Number))
(= (getMaxSTI) (let $recentVal (RecentVal) (match $recentVal (recent_max $_) $_)))

(: getMinSTI (-> Bool Number))
(= (getMinSTI $avg)
   (let $recentVal (RecentVal)
    (if $avg
      (match $recentVal (recent_min $_) $_)
      (match $recentVal (value_min $_) $_)
      )
   )
)

(: getMinSTI (-> Number))
(= (getMinSTI) (let $recentVal (RecentVal) (match $recentVal (recent_min $_) $_)))
; Normalizes the STI of an atom to the range [0,1] with optional clipping.
(: getNormalisedZeroToOneSTI (-> Atom Bool Bool Number))
(= (getNormalisedZeroToOneSTI $atom $average $clip)
   (let*
       (   ($sti  (getSTI $atom))
           ($maxSTI (getMaxSTI $average))
           ($minSTI (getMinSTI $average))
           ($normaliser (- $maxSTI $minSTI))
           ($diff (- $sti $minSTI))
          
           ($value (if (== $normaliser 0)
                      0.0
                      (/ $diff $normaliser)))
            ($minim  (Min ($value 1.0)))
           ($clippedValue 
                     (if $clip
                           (Max (0.0 $minim))
                           $value
                     )
            )
           
       )
       $clippedValue
   )
)

; Normalizes the STI of an atom relative to a fixed max/min STI value.

(: getNormalisedSTI (-> Atom Number))
(= (getNormalisedSTI $atom)
   (let*
       (
           ($s (getSTI $atom))
           ($afMax (getAfMaxSTI))
           ($normaliser
               (if (> $s $afMax)
                   (getMaxSTI)
                   (getMinSTI)
               )
            )
       )
       (if (== $normaliser 0)
           0.0
           (/ $s $normaliser)
       )
   )
)


; Normalizes the STI of an atom with respect to attentional focus max STI, with optional clipping.
(: getNormalisedSTI (-> Atom Bool Bool Number))
(= (getNormalisedSTI $atom $average $clip)
   (let*
       (
           ($s (getSTI $atom))
           ($afMax (getAfMaxSTI)) 
           ($diff (- $s $afMax))
           ($sum (+ $s $afMax)) 
           ($normaliser
               (if (> $s $afMax)
                   (- (getMaxSTI $average) $afMax)
                   (- (getMinSTI $average) $afMax)
               )
           )
       )
       (if (== $normaliser 0)
           0.0
           (let*
               (
                   ($val 
                       (if (> $s $afMax)
                           (/ $diff $normaliser)  
                           (/ $sum $normaliser)
                       )
                   )
               )
               (if $clip
                   (Max (-1.0 (Min ($val 1.0))))
                   $val
               )
           )
       )
   )
)
