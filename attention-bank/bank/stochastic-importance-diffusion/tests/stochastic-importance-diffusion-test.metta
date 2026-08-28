!(import! &self (library lib_import))
!(import_prolog_function working_dir)
!(import_prolog_function directory_file_path)
!(import_prolog_function absolute_file_name)

(= (registerLocalMettaAttentionLibrary)
    (let*
        (
            ($testDir (working_dir))
            ($rootPath (directory_file_path $testDir "../../../.."))
            ($repoRoot (absolute_file_name $rootPath))
        )
        (assertaPredicate (Predicate (library_path $repoRoot)))
    )
)

!(registerLocalMettaAttentionLibrary)
!(import! &self (library lib_he))
!(import! &self (library lib_spaces))
!(import! &self (library metta-attention attention/AttentionParam))
!(import! &self (library metta-attention attention-bank/utilities/helper-functions))
!(import! &self (library metta-attention attention-bank/utilities/helper-functions))
!(import! &self (library metta-attention attention-bank/bank/importance-index/importance-index))
!(import! &self (library metta-attention attention-bank/attention-value/getter-and-setter))
!(import! &self (library metta-attention attention-bank/bank/stochastic-importance-diffusion/stochastic-importance-diffusion))
!(import! &self (library metta-attention attention-bank/bank/attention-bank))
!(import! &self (library metta-attention attention-bank/utilities/recentVal)); This sets the STI of a to 1 which will give bin index of 1
!(setAv a (1.0 1.0 1.0))


!(getSti a)
!(calcElapsedTime (getSti a))



!(updateBin a)
!(match &atomBinInfo (1.0 $t) $t)
!((py-call time.sleep) 1.0)

!(updateBin a)
!(match &atomBinInfo (1.0 $t) $t)
!((py-call time.sleep) 3.0)

!(updateBin a)
!(match &atomBinInfo (1.0 $t) $t)

!(updateBin a)
!(match &atomBinInfo (1.0 $t) $t)

!(updateBin a)
!(match &atomBinInfo (1.0 $t) $t)

!(updateBin a)
!(match &atomBinInfo (1.0 $t) $t)
!(importanceBin (getSti a))

!(calcElapsedTime 1.0)

;This will update the _bin
; !(timeTime)  
;!(updateBin a)
;!(updateBin a)
; ;This will the elapsed_time of the atom
; ;Since size is greater than zero it will return some value
; ;above zero
; !(elapsedTime a)

; ;Since we have updated the _bin 3 times (considering elapsedTime updating the bin) and since the size of 
; ;the bin is 2 the below should return (3 2)
;!(assertEqual (match (AtomBinInfo) (1 ((count $cnt_val) (index $idx_val) (_size $size_val) (update_rate $update_rate_val) (last_update $last_update_val))) 
;    ($cnt_val $size_val)) (3 2))
 
; !(match (AtomBinInfo) (1 ((count $cnt_val) (index $idx_val) (_size $size_val) (update_rate $update_rate_val) (last_update $last_update_val))) 
;     ($last_update_val)) 
;!(assertEqual (> (diffusedValue a 0.5) 0.5) True) 
;!(assertEqual (diffusedValue a 1) 0) ;after on round the sti value 1 will have decreased by the decay rate=1 therefore, output becomes 0
; !(elapsedTime a)



