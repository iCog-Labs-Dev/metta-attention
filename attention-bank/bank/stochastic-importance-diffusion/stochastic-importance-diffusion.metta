! (bind! &atomBinInfo (new-space))
! (bind! timeTime (py-atom time.time))



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

(: updateBin (-> Atom empty))
(= (updateBin $atom)
    (let* (
            ($index (importanceBin (getSti $atom)))
            ($it (collapse (match &atomBinInfo ($index $a) $index)))
            ($firstTime   (timeTime))
          )
        (if (== $it ($index))
            (updateExistingBin $index)
            (let* (
                ($time (timeTime)) 
                )
                (add-atom &atomBinInfo 
                    ($index ((count 1) (index $index) (_size (getSize $index)) (update_rate (/ 1 (- $time $firstTime))) (last_update $time)))
            ))
        )
    )
)

(: updateExistingBin (-> Number empty))
(= (updateExistingBin $index)
    (let (($cnt $cntVal) ($idx $idxVal) ($size $sizeVal) ($updateRate $updateRateVal) ($lastUpdate $lastUpdateVal)) 
            (match &atomBinInfo ($index $info) 
                (let () (remove-atom &atomBinInfo ($index $info))
                    $info))
            (let* (
                    ($count (+ $cntVal 1))
                    ($now (timeTime))
                    ($newSec (- $now $lastUpdateVal))
                    ($newUpdateRate (/ $count $newSec))
                    ($newSize (getSize $index)))
                    (add-atom &atomBinInfo 
                        ($index ((count $count) (index $index) (_size $newSize) (update_rate $newUpdateRate) (last_update $now))))
            )
    )
)

;This function returns the elapsed time of the atom
;by dividing the size of the bin by the update rate

(: elapsedTime (-> Atom Number))
(= (elapsedTime $atom)
    (let* (
            ($index (importanceBin (getSti $atom)))
            ($averageElapsedTime (calcElapsedTime $index))
            ($res (updateBin $atom))
            
          )
        $averageElapsedTime
    )
)

(:calcElapsedTime (-> Number Number))
(= (calcElapsedTime $index)
    (if (== (collapse (match &atomBinInfo ($index $_) $index)) ($index))
        (let (($cnt $cntVal) ($idx $idxVal) ($size $sizeVal) ($updateRate $updateRateVal) ($lastUpdate $lastUpdateVal)) 
                (match &atomBinInfo ($index $info) $info)
                (if (== $updateRateVal 0)
                    ("updateRate can not be zero")
                    (/ $sizeVal $updateRateVal)
                )
        
        )
        0.0
    )
)

;the purpose of this function is to calculate the Estimated
;current STI value of the Atom after diffusion.
(: diffusedValue (-> Symbol Number Number))
(= (diffusedValue $atom $decayRate)
   (let* (
          ($averageElapsedTime (elapsedTime $atom))
          ($sti (getSti $atom))
          ($powerRes (pow-math (- 1 $decayRate) $averageElapsedTime))
        )
        (* $sti $powerRes)
    )
)

(= (AtomBinInfo)
    &atomBinInfo
)
