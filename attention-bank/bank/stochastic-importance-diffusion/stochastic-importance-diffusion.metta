!(bind! &atomBinInfo (new-space))

(= (currentTime) (let $time (py-call (time.time)) $time) )

; !(timeTime)
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

; (: updateBin (-> Atom empty))
(= (updateBin $atom)
    (let* (
            ($index (importanceBin (getSti $atom)))
            ($it (collapse (match &atomBinInfo ($index $_) $index)))
            ($firstTime   (currentTime))
            ; ($i (println! (index of atom $atom in update bin $index $it with current time $firstTime)))
          )
        (if (== $it ($index))
            (updateExistingBin $index)
            (let* (
                ($time (currentTime)) 
                ($size (getSize $index))
                ($rate (/ 1 (- $time $firstTime)) ) 
                ; ($diff (- $time $firstTime))
                ; ($safeDiff (max-atom ($diff 0.000001)))
                ; ($rate (/ 1 $safeDiff) )
                ; ($el (println! (this is inside else condition)))
            )
                (add-atom &atomBinInfo 
                    ($index ((count 1) (index $index) (_size $size) (update_rate $rate) (last_update $time)))
            ))
        )
    )
)

; (: updateExistingBin (-> Number empty))
(= (updateExistingBin $index)
            (let* 
                 (
                    ; ($upexist (println! (=====> this is inside update existing atom )))
                    ((($cnt $cntVal) ($idx $idxVal) ($size $sizeVal) ($updateRate $updateRateVal) ($lastUpdate $lastUpdateVal)) (match &atomBinInfo ($index $info)  $info ))
                    ($prev (let $y (match &atomBinInfo ($index $info) ($index $info)) (remove-atom &atomBinInfo $y)))
                    ($count (+ $cntVal 1))
                    ($now (currentTime))
                    ($newSec (- $now $lastUpdateVal))
                    ($newUpdateRate (/ $count $newSec))
                    ; ($safeNewSec (max-atom ($newSec 0.000001)))
                    ; ($newUpdateRate (/ $count $safeNewSec))
                    ($newSize (getSize $index)))
                    (add-atom &atomBinInfo 
                        ($index ((count $count) (index $index) (_size $newSize) (update_rate $newUpdateRate) (last_update $now))))
            )
    )


;This function returns the elapsed time of the atom
;by dividing the size of the bin by the update rate

; (: elapsedTime (-> Atom Number))
(= (elapsedTime $atom)
    (let* (
            ($index (importanceBin (getSti $atom)))
            ; ($ind (println! (bin index $index for atom $atom)))
            ($averageElapsedTime (calcElapsedTime $index))
            ; ($cal (println! (calculated elpased time $averageElapsedTime for atom $atom)))
            ; ($time (println! (this current time (currentTime))))
            ($res (updateBin $atom))
            ; ($r (println! (what is result here $res)))
            
          )
        $averageElapsedTime
    )
)

; (:calcElapsedTime (-> Number Number))
(= (calcElapsedTime $index)
    (if (== (collapse (match &atomBinInfo ($index $_) $index)) ($index))
        (let*
            (
                ( (($cnt $cntVal) ($idx $idxVal) ($size $sizeVal) ($updateRate $updateRateVal) ($lastUpdate $lastUpdateVal)) (match &atomBinInfo ($index $info) $info))
                ; ($upd (println! (this is update rate val ========> $updateRateVal for atom with index $index $sizeVal)))
                
            ) 
                
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
; (: diffusedValue (-> Symbol Number Number))
(= (diffusedValue $atom $decayRate)
   (let* (
          ($averageElapsedTime (elapsedTime $atom))
          
          ($sti (getSti $atom))
          ($powerRes (pow-math (- 1 $decayRate) $averageElapsedTime))
        ;   ($elps (println! (elpased time $averageElapsedTime $decayRate $powerRes $sti (* $sti $powerRes) )))
        )
        (* $sti $powerRes)
    )
)

(= (AtomBinInfo)
    &atomBinInfo
)
