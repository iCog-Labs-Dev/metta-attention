 ; merge past and recent bin
 ; stracture of the bin
 ; (index((count $cnt_val) (index $idx_val) (_size $sizeVal)))
! (bind! &past-space (new-space))
! (bind! &recent-space (new-space))

;add atoms to past-space

; Function: helperToIdentifyParameter
; -----------------------------------
; Extracts key values (index, count, indexMap, size) from a nested bin list.
;Returns a list with these extracted values.
(: helperToIdentifyParameter (-> Expression Expression))
( = (helperToIdentifyParameter $list)
    (if ( == $list ())
        ()
        (let* (
                ($index (car-atom $list))
                ($countIndexSize (cdr-atom $list))
                ($binValues (car-atom $countIndexSize))
                ($count (car-atom $binValues))
                ($indexSize (cdr-atom $binValues))
                ($indexMap (car-atom $indexSize))
                ($sizeMap (cdr-atom $indexSize))
                ($size (car-atom $sizeMap))
                ($countList (cdr-atom $count))
                ($countVal (car-atom $countList))
            )
        ($index $countVal $indexMap $size)
        )
    )
)
 ; Function: mergeBin
 ; -------------------
 ; Merges recent bins with past bins by updating the count values based on a bias factor.
 ; If a matching past bin exists, it updates the count in recent-space.
 ; Otherwise, it proceeds without updating and continues merging recursively.
 ; Returns a confirmation message and recursively processes the remaining bins.
(: mergeBin (-> Symbol Number Expression))
( = (mergeBin  $recent $bias)
    (if ( == $recent ()) ; base case
        (collapse (get-atoms &recent-space))
        (
             ;pre defined variables
            let* (
                ($head (car-atom $recent))
                ($tail (cdr-atom $recent))
                ($values (helperToIdentifyParameter $head))
                ($index (car-atom $values))
                ($map (cdr-atom $values))
                ($count (car-atom $map))
                ($indexMap (cdr-atom $map))
                ($indexVal (car-atom $indexMap))
                ($sizeMap (cdr-atom $indexMap))
                ($sizeVal (car-atom $sizeMap))
                )
            (let*
                (
                    ; Extract the past bin with the same index
                    ($pastBin (collapse (match &past-space ($index ( (count $pastCount) (index $pastIndex) (Size $past_size) )) $pastCount)))
                )
                (if (== $pastBin ()) ;check if past bin not exist or not
                    (mergeBin $tail $bias)
                    (
                        ; extract past count if past bin with recent bin similar index exist
                        let* (
                            ($pastCount (car-atom $pastBin))
                        )
                        (match &recent-space ($index (  (count $count) $indexVal  $sizeVal))
                            ; update the count also remove existing recent bin and add updated one
                            (let* (
                                    ($_ (remove-atom &recent-space ($index (  (count $count) $indexVal  $sizeVal))) )
                                    ($update (+ (* $pastCount $bias) (* (- 1 $bias) $count)))
                                    ($_ (add-atom &recent-space ($index ( (count $update) $indexVal $sizeVal)))))
                                (mergeBin $tail $bias) 
                            )
                        )
                    )
                )
            )
        )
    )
)
