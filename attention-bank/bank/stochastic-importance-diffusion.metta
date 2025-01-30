
;need to avoid devision by zero
! (bind! &diffusionrecordbin (new-space))
! (bind! time-mod (py-atom time))
! (bind! time-time (py-dot time-mod time (-> Number)))
! (time-time)

! (add-atom &diffusionrecordbin (1 ((count 0) (index 1) (_size 1) (update_rate 5) (last_update 0))))

(= (update_bin $atom)
    (let* (
            ($index (importanceBin (getSTI $atom)))
            ($it (match &diffusionrecordbin ($index $_) $index))
          )
        (if (== $it $index)
            (let (($cnt $cnt_val) ($idx $idx_val) ($size $size_val) ($update_rate $update_rate_val) ($last_update $last_update_val)) 
                    (match &diffusionrecordbin ($index $ret) $ret)
                    (let* (
                            ($count (+ $cnt_val 1))
                            ($newSec (- (time-time) $last_update_val))
                            ($newupdate-rate (/ $count $newSec))
                            ($newsize (getSize $index))
                            ($_ (remove-atom &diffusionrecordbin 
                                    ($index (($cnt $cnt_val) ($idx $idx_val) ($size $size_val) ($update_rate $update_rate_val) ($last_update $last_update_val)))
                                )
                            )
                            )
                            (add-atom &diffusionrecordbin 
                                ($index ((count $count) (index $index) (_size $newsize) (update_rate $newupdate-rate) (last_update (time-time)))))
                    )
            )
            (add-atom &diffusionrecordbin 
                ($index ((count 1) (index $index) (_size (getSize $index)) (update_rate (/ 1 (time-time)) )) (last_update (time-time)))
            )
        )
    )
)

(= (elapsed_time $atom)
    (let* (
            ($index (importanceBin (getSTI $atom)))
            ($average_elapsed_time 
                (if (== (collapse (match &diffusionrecordbin ($index $_) $index)) ($index))
                    (let (($cnt $cnt_val) ($idx $idx_val) ($size $size_val) ($update_rate $update_rate_val) ($last_update $last_update_val)) 
                            (match &diffusionrecordbin ($index $ret) $ret)
                            (/ $size_val $update_rate_val)
                    )
                    0
                )
            )
            ($_ (update_bin $atom))
          )
        $average_elapsed_time
    )
)
