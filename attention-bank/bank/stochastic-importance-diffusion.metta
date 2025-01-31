
! (bind! &diffusionrecordbin (new-space))
! (bind! time-mod (py-atom time))
! (bind! time-time (py-dot time-mod time (-> Number)))
! (time-time)

;The udate_bin function receives an atom and updates this values
; struct DiffusionRecordBin {
;             unsigned int count = 0; // Number of atoms diffused.
;             unsigned int index = 0; // The index of this Bin in ImportanceIndex vec.
;             unsigned int size = 0;  // The total size of this Bin in ImportanceIndex vec.
;             float update_rate = 0;  // Estimated update rate for this bin.

;             // Latest time of diffusion event in this bin.
;             time_point<high_resolution_clock> last_update = high_resolution_clock::now(); 
;}

;from the diffusionrecordbin space.
;I have represented this in metta as an Expression
;($index ((count $cnt_val) (index $idx_val) (_size $size_val) (update_rate $update_rate_val) (last_update $last_update_val)))
;I used _size instead of size because size is use in metta as a function name

(: update_bin (-> Atom empty))
(= (update_bin $atom)
    (let* (
            ($index (importanceBin (getSTI $atom)))
            ($it (collapse (match &diffusionrecordbin ($index $_) $index)))
          )
        (if (== $it ($index))
            (let (($cnt $cnt_val) ($idx $idx_val) ($size $size_val) ($update_rate $update_rate_val) ($last_update $last_update_val)) 
                    (match &diffusionrecordbin ($index $ret) 
                        (let () (remove-atom &diffusionrecordbin ($index $ret))
                            $ret
                        )
                    )
                    (let* (
                            ($count (+ $cnt_val 1))
                            ($newSec (- (time-time) $last_update_val))
                            ($newupdate-rate (/ $count $newSec))
                            ($newsize (getSize $index))
                            )
                            (add-atom &diffusionrecordbin 
                                ($index ((count $count) (index $index) (_size $newsize) (update_rate $newupdate-rate) (last_update (time-time)))))
                    )
            )
            (add-atom &diffusionrecordbin 
                ($index ((count 1) (index $index) (_size (getSize $index)) (update_rate (/ 1 (time-time)) ) (last_update (time-time))) )
            )
        )
    )
)

;This function returns the elapsed time of the atom
;by dividing the size of the bin by the update rate

(: elapsed_time (-> Atom Number))
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

(= (diffusionrecordbin)
    &diffusionrecordbin
)