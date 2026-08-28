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
!(import! &self (library metta-attention attention-bank/bank/importance-index/importance-index))
!(import! &self (library metta-attention attention-bank/attention-value/getter-and-setter))
!(import! &self (library metta-attention attention-bank/bank/attention-bank))
!(import! &self (library metta-attention attention-bank/bank/attentional-focus/attentional-focus))
!(import! &self (library metta-attention attention-bank/bank/stochastic-importance-diffusion/stochastic-importance-diffusion)); !(import! &self ../../../../../metta-attention/attention-bank/utilities/recentVal)
!(import! &self (library metta-attention attention/Neighbors))
!(import! &self (library metta-attention attention/RentCollectionAgent/RentCollectionBaseAgent/RentCollectionBaseAgent))
!(import! &self (library metta-attention attention/RentCollectionAgent/WARentCollectionAgent/WARentCollectionAgent))




;lower max AFsize for testing
!(updateAttentionParam MAX_AF_SIZE 4.0)

!(test (getAttentionParam MAX_AF_SIZE) 4.0)


!(stimulate b 3000.0)
!(stimulate c 1500.0)
!(stimulate d 290.0)
!(stimulate (Hebbianlink a b) 50.0)
!(stimulate (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)) 5.0)


!(test (getSti b) 60000.0)
!(test (getSti c) 30000.0)
!(test (getSti d) 2900.0)
!(test (getSti (Hebbianlink a b)) 355.0)
!(test (getSti (Hebbianlink (Hebbianlink c d) (Hebbianlink c b))) 33.725)
!(test (selectTargets) (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)))

; !(getSti (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)))

!((let $res (selectTargets) (elapsedTime $res) ))

; !(match &atomBinInfo ($in $val) $val)

!(WARentCollectionAgent-Run)

; Sleep for the computed time to match C++ behavior

; !(py-call (time.sleep 0.5))

; !(WARentCollectionAgent-Run)


!(test (< (getSti (Hebbianlink (Hebbianlink c d) (Hebbianlink c b))) 33.725) True) ;must have lower sti

; !(getSti (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)))

!(test (getSti b) 60000.0)
!(test (getSti c) 30000.0)
!(test (getSti d) 2900.0)
!(test (getSti (Hebbianlink a b)) 355.0)



