 ; merge past and recent bin
 ; stractuer of the bin
 ; (index((count $cnt_val) (index $idx_val) (_size $size_val)))
! (bind! &past-space (new-space))
! (bind! &recent-space (new-space))
! (bind! &my-space (new-space))
! (add-atom &past-space (1 ( (count 1) (index 1) (size 1))))
! (add-atom &past-space (2 ( (count 10) (index 2) (size 1))))
! (add-atom &past-space (3 ( (count 1) (index 3) (size 1))))
! (add-atom &past-space (4 ( (count 5) (index 4) (size 1))))
! (add-atom &recent-space (4 ( (count 1) (index 4) (size 1))))
! (add-atom &recent-space (5 ( (count 1) (index 5) (size 1))))
! (add-atom &recent-space (3 ( (count 3) (index 3) (size 1))))
! (add-atom &recent-space (2 ( (count 5) (index 2) (size 1))))

 ; Function: helperToIdentifyParameter
 ; -----------------------------------
 ; Extracts key values (index, count, index_map, size) from a nested bin list.
 ; Returns a list with these extracted values.
(: helperToIdentifyParameter (-> List List))
( = (helperToIdentifyParameter $list)
    (
        if ( == $list ())
        ()
        (
            let* (
                ($index (car-atom $list))
                ($count_index_size (cdr-atom $list))
                ($bin_values (car-atom $count_index_size))
                ($count (car-atom $bin_values))
                ($index_size (cdr-atom $bin_values))
                ($index_map (car-atom $index_size))
                ($size_map (cdr-atom $index_size))
                ($size (car-atom $size_map))
                ($count_list (cdr-atom $count))
                ($count_val (car-atom $count_list))
            )
        ($index $count_val $index_map $size)
    )
)
)
 ; Function: merge_bin
 ; -------------------
 ; Merges recent bins with past bins by updating the count values based on a bias factor.
 ; If a matching past bin exists, it updates the count in recent-space.
 ; Otherwise, it proceeds without updating and continues merging recursively.
 ; Returns a confirmation message and recursively processes the remaining bins.
(: merge_bin (-> space Number empty))
(= (merge_bin $recent $bias)
    (if (not  (== $recent ()))
        ("Merge completed")
        (empty)))
( = (merge_bin  $recent $bias)
    (
        if ( == $recent ()) ; base case
        (empty)
        (
             ;pre defined variables
            let* (
                ($head (car-atom $recent))
                ($tail (cdr-atom $recent))
                ($values (helperToIdentifyParameter $head))
                ($index (car-atom $values))
                ($map (cdr-atom $values))
                ($count (car-atom $map))
                ($index_map (cdr-atom $map))
                ($index_val (car-atom $index_map))
                ($size_map (cdr-atom $index_map))
                ($size_val (car-atom $size_map))
            )
        (let*
            (
                 ; Extract the past bin with the same index
                ($past_bin (collapse (match &past-space ($index ( (count $past_count) (index $past_index) (size $past_size) )) $past_count)))
            )
        (if (== $past_bin ()) ;check if past bin not exist or not
            (merge_bin $tail $bias)
            (
                 ; extract past count if past bin with recent bin similar index exist
                let* (
                    ($past_count (car-atom $past_bin))
                )
            (match &recent-space ($index (  (count $count) $index_val  $size_val))
                 ; update the count also remove existing recent bin and add updated one
                (let* (
                        ($_ (remove-atom &recent-space ($index (  (count $count) $index_val  $size_val))) )
                        ($update (+ (* $past_count $bias) (* (- 1 $bias) $count)))
                        ($_ (add-atom &recent-space ($index ( (count $update) $index_val $size_val)))))
                    (merge_bin $tail $bias) )
            )
    )
)
)
)))
! ( merge_bin  (collapse (get-atoms &recent-space)) 0.5)
! (get-atoms &recent-space)