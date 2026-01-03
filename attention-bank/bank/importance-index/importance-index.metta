; importance management functions can be implemented here in this file.

; functions like the following

; - importanceBin - it recives importance value(sti value) and return bin value
; - update - update the global variables max sti and min sti value
; - getmaxsti - return the max sti value
; - getminsti - return the min sti value
; - getHandleSet - recive lower and uper bound of sti and return atoms in that bound
; - getMaxBinContents - return atoms found in max bin index
; - getMinBinContents - return atoms found in min bin index
; - bin_size - return the total bin size

(: GroupSize (-> Number))
(= (GroupSize) 8.0)
(: GroupNum (-> Number))
(= (GroupNum) 12.0)

(: ImportanceIndexSize (-> Number))
(= (ImportanceIndexSize) 104.0)

;Function: importanceBin
;Description: Computes the bin index for a given importance value (STI value of an atom).
;             The bin index is determined based on a grouping strategy that adjusts 
;             the value into a structured set of bins.
;             The grouping strategy is defined by the GroupSize and GroupNum constants.
;The grouping strategy: Small values (less than 2 * GroupSize) go directly into bins with their number as the bin index.
;                       Big values are grouped into bins that get wider as numbers get larger. This means higher numbers are stored in fewer, bigger bins.
;                       The function adjusts the bin number to keep the bins evenly spaced and organized.
;Parameters:
;           $impo: The importance value (STI value of an atom) to be categorized into a bin.
;Returns: The computed bin index for the given importance value.
(: importanceBin (-> Number Number))
(= (importanceBin $impo)
   (
    let*
    (
      ($groupSize (GroupSize))
      ($impo_int (trunc-math $impo)) ; Ensure $impo is treated as an integer
      ($firstCondition (< $impo_int 0))
      ($secondCondition (< $impo_int (* 2.0 $groupSize)))
    )
    (if $firstCondition
      0.0
      (if $secondCondition
        $impo_int
        (let*
          (
            ($imp (trunc-math (/ (- $impo_int $groupSize) $groupSize)))
            ($i (findGroup $imp 0.0 0.0))
            ($num (- $i 1.0))
            ($temp (ceil-math (/ $impo_int (pow-math 2.0 (- $i 1.0)))))
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
; i.e (update &typeSpace) will update the global variables _minSTI and _maxSTI

;get all contents that are in typeSpace indices
;filter out empty contents
;find maximum sti
;find minumum sti
;if min_sti > max_sti: min_sti = max_sti
;_min_sti = min_sti, max_sti = max_sti

; (: update (-> hyperon::space::DynSpace Atom))
(= (update $space)
    (let* (
            ; ($1 (println! (inside update)))

            ($collectedContents (getAllAtomsWithBins))
            ($minCon (getMinBinContents) )
            ; ($1 (println! (collecteds $collectedContents)))
            ($max  (getAllMaxSTI $collectedContents))
            ; ($2 (println! (maxx $max)))

            ($min (getAllMinSTI $collectedContents))
            ; ($3 (println! (minn $min)))

            ($exitCondition (> $min $max))
        )
         (if $exitCondition
            (updateGlobalMaxAndMinSTI $max $min)
            (updateGlobalMaxAndMinSTI $min $max)
          )
    )
)






(= (updateGlobalMaxAndMinSTI $min $max)
    (let*
      (
       ($firstRes (updateMin $min))
      ;  ($4 (println! (updatemin $firstRes)))

       ($secondRes (updateMax $max))
      )
      (trace! (Updated) ("Updated"))

     )
)

; Recursive helper to calculate the group index
(= (findGroup $imp $sum $i)
   (if ( <= $imp 0)
    0
    (
        let* (
            ($num (+ $imp 1))
            ($log_num (log-math 2 $num))
            ($int_num (ceil-math $log_num))
            
        )
        
        (let $x (GroupNum)
         (if (<= $int_num $x)
            $int_num
            $x
        ))
    )
   )
)

; Filters atoms in expression whose STI values fall between lower and higher bounds.
; (: filterContents (-> Expression Number Number Expression))
(= (filterContents $contents $lower $higher)
   (if (== $contents ())
        () 
        (collapse 
          (let 
            $x (superpose $contents)
            (if (and (>= (getSti $x) $lower) (<= (getSti $x) $higher))
                 $x
                () 
            )
          ) 
        )
   )
     

)

; Function: getContent
; Description:  Recursively collects all atoms from bins indexed between $lower and $higher, inclusive.
; Parameters: 
;             - $lower: the lower bin number of the range
;             - $higher: the higher bin number from the range

; (: getContent (-> Number Number Expression))
(= (getContent $lower $higher)
  (if (> $lower $higher)
    ()  
    (let*
      (
        ($vals (getAtomsByBin $lower))
        ($r (println! $lower))
        ($rest (getContent (+ $lower 1.0) $higher))
      )
      (union-atom $vals $rest)
    )
  )
)


; Retrieves atoms from bins whose STI values fallin lowerbound and upperBound. it utilizes filterContents function.
; (: getHandleSet (-> Number Number Expression))
(= (getHandleSet $lowerBound $upperBound)
   (if (or (< $lowerBound 0.0) (< $upperBound 0.0))
     ()
     (let*
       (
        ($lowerBin (importanceBin $lowerBound))
        ($upperBin (importanceBin $upperBound))
        ($allContents (getContent $lowerBin $upperBin))
        ($filteredContents  (filterContents $allContents $lowerBound $upperBound))
        ($finalContents  (filter $filteredContents notEmpty))
        
      )
     $finalContents 
        
    )
  )
)

; (: getMaxSTI (-> Bool Number))
; (= (getMaxSTI $avg) 
;    (let $recentVal (RecentVal)
;     (if $avg
;       (match $recentVal (recent_max $_) $_)
;       (match $recentVal (value_max $_) $_)
;       )
;    )
; )

; (: getMaxSTI (-> Number))
; (= (getMaxSTI) (let $recentVal (RecentVal) (match $recentVal (recent_max $_) $_)))

; (: getMinSTI (-> Bool Number))
; (= (getMinSTI $avg)
;    (let $recentVal (RecentVal)
;     (if $avg
;       (match $recentVal (recent_min $_) $_)
;       (match $recentVal (value_min $_) $_)
;       )
;    )
; )

; (: getMinSTI (-> Number))
; (= (getMinSTI) (let $recentVal (RecentVal) (match $recentVal (recent_min $_) $_)))

; (: getMaxSTI (-> Bool Number))
; (= (getMaxSTI $avg) 

;     (if $avg
;       (getAttentionParam RECENT_MAX)
;       (getMaxSTI)
;       )
; )

; (: getMaxSTI (-> Number))
(= (getMaxSTI) (getAttentionParam MAX_STI))

; (: getMinSTI (-> Bool Number))
; (= (getMinSTI $avg)
;    (if $avg
;       (getAttentionParam RECENT_MIN)
;       (getMinSTI)
;       )
; )

; (: getMinSTI (-> Number))
(= (getMinSTI) (getAttentionParam MIN_STI))

;Function: getNormalisedZeroToOneSTI
;Description: Normalizes an atom's STI based on the minimum and maximum STI values.
;             If clipping is enabled, the output is restricted between 0 and 1.
;             Otherwise, it can be outside this range.
;Parameters:
;           $atom: The atom whose STI is being normalized.
;           $average: If True, uses recent_max and recent_min for normalization.
;                     If False, uses value_max and value_min.
;           $clip: If True, restricts the normalized value to the range [0,1].
;Returns: The normalized STI value, possibly clipped between 0 and 1.
; (: getNormalisedZeroToOneSTI (-> Atom Bool Bool Number))
(= (getNormalisedZeroToOneSTI $sti $average $clip )
   (let*
       (   
          ;  ($_ (println! (sti $sti)))
           ($maxSTI (getMaxSTI))
           
          ;  ($_ (println! (maxSTI $maxSTI)))
           ($minSTI (getMinSTI))
           ($normaliser (- $maxSTI $minSTI))
           ($diff (- $sti $minSTI))
          
           ($value (if (== $normaliser 0.0)
                      0.0
                      (/ $diff $normaliser)))
           ($minim  (min-atom ($value 1.0)))
           ($clippedValue 
                     (if $clip
                           (max-atom (0.0 $minim))
                           $value
                     )
            )
           
       )
       $clippedValue
   )
)
;Function: getNormalisedSTI (Single Argument)
;Description: Normalizes an atom's STI relative to a fixed max/min STI value.
;             If the atom's STI is higher than the  maximum STI in the attentional focus, 
;             it normalizes using the global max STI; otherwise, it normalizes using the min STI.
;Parameters:
;          $atom: The atom whose STI is being normalized.
;Returns: A normalized STI value
; (: getNormalisedSTI (-> Atom Number))
(= (getNormalisedSTI $sti)
   (let*
       (
          ($atoms (getAfAtoms))
           ($afMax  (getAllMaxSTI $atoms))
           ($normaliser
               (if (> $sti $afMax)
                   (getMaxSTI)
                   (getMinSTI)
               )
            )
       )
       (if (== $normaliser 0.0)
           0.0
           (/ $sti $normaliser)
       )
   )
)



;Function: getNormalisedSTI
;Description: Normalizes an atom's STI relative to the attentional focus max STI.
;             The normalization formula varies based on whether the STI is above or below the attentional max STI.
;             Optionally, the normalized value can be clipped to the range [-1, 1].
;Parameters:
;          $atom: The atom whose STI is being normalized.
;          $average: If True, uses recent_max/recent_min for normalization; otherwise, uses value_max/value_min.
;          $clip: If True, restricts the normalized value to the range [-1, 1].
;Returns: A normalized STI value, possibly clipped to the range [-1, 1].
; (: getNormalisedSTI (-> Atom Bool Bool Number))
(= (getNormalisedSTI $sti $average $clip)
   (let*
       (
           ($atoms (getAfAtoms))
           ($afMax  (getAllMaxSTI $atoms))
           ($diff (- $sti $afMax))
           ($sum (+ $sti $afMax)) 
           ($normaliser
               (if (> $sti $afMax)
                   (- (getMaxSTI) $afMax)
                   (- (getMinSTI) $afMax)
               )
           )
       )
       (if (== $normaliser 0.0)
           0.0
           (let*
               (
                   ($val 
                       (if (> $sti $afMax)
                           (/ $diff $normaliser)  
                           (/ $sum $normaliser)
                       )
                   )
                   ($minim  (min-atom ($val 1.0)))
               )
               
               (if $clip
                   (max-atom (-1.0 $minim))
                   $val
               )
           )
       )
   )
)



