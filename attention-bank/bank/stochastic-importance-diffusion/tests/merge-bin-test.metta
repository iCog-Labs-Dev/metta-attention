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
!(import! &self (library metta-attention attention/AttentionParam))
!(import! &self (library metta-attention attention-bank/bank/stochastic-importance-diffusion/merge-bin))
!(import! &self (library metta-attention attention-bank/attention-value/getter-and-setter))
!(import! &self (library metta-attention attention-bank/bank/attention-bank))
!(import! &self (library metta-attention attention-bank/bank/importance-index/importance-index))
!(import! &self (library metta-attention attention-bank/utilities/helper-functions))
!(import! &self (library metta-attention attention-bank/bank/attentional-focus/attentional-focus))
 ;add atoms to past-space
!(add-atom &past-space (1 ( (count 1) (index 1) (Size 1))))
!(add-atom &past-space (2 ( (count 10) (index 2) (Size 1))))
!(add-atom &past-space (3 ( (count 1) (index 3) (Size 1))))
!(add-atom &past-space (4 ( (count 5) (index 4) (Size 1))))

 ;add atoms to recent-space
!(add-atom &recent-space (4 ( (count 1) (index 4) (Size 1))))
!(add-atom &recent-space (5 ( (count 1) (index 5) (Size 1))))
!(add-atom &recent-space (3 ( (count 3) (index 3) (Size 1))))
!(add-atom &recent-space (2 ( (count 5) (index 2) (Size 1))))

 ;check the function is returning Merge completed string after all thing done
!(test (mergeBin (collapse (get-atoms &recent-space)) 0.5) ((5 ((count 1) (index 5) (Size 1))) (4 ((count 3.0) (index 4) (Size 1))) (3 ((count 2.0) (index 3) (Size 1))) (2 ((count 7.5) (index 2) (Size 1)))))
 ;  after apply  merge function by bias 0.5 on recent space at index 2 the value of count change from 5 to 7.5
!(test (match &recent-space (2 ( (count $count) (index $x) (Size $y))) $count) 7.5)
 ;  after apply  merge function by bias 0.5 on recent space at index 4 the value of count change from 1 to 3
!(test (match &recent-space (4 ( (count $count) (index $x) (Size $y))) $count) 3.0)