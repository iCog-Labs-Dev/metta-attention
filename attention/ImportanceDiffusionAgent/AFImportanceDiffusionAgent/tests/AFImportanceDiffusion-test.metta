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
!(import! &self (library metta-attention attention/baching))
!(import! &self (library metta-attention attention-bank/utilities/helper-functions))
!(import! &self (library metta-attention attention-bank/attention-value/getter-and-setter))
!(import! &self (library metta-attention attention-bank/bank/attention-bank))
!(import! &self (library metta-attention attention-bank/utilities/recentVal))
!(import! &self (library metta-attention attention-bank/bank/attentional-focus/attentional-focus))
!(import! &self (library metta-attention attention-bank/bank/importance-index/importance-index))
!(import! &self (library metta-attention attention/Neighbors))
!(import! &self (library metta-attention attention/ImportanceDiffusionAgent/ImportanceDiffusionBase/ImportanceDiffusionBase))
!(import! &self (library metta-attention attention/ImportanceDiffusionAgent/getelement.py))
!(import! &self (library metta-attention attention/ImportanceDiffusionAgent/AFImportanceDiffusionAgent/AFImportanceDiffusionAgent))
!(bind! &incident (new-space))


;;This are the same tests as the c++

;########################## Stimlating atoms so that they enter AF #############################
!(stimulate source 500)
!(stimulate target1 400)
!(stimulate target2 400)
!(stimulate target3 400)
!(stimulate target4 400)
!(stimulate target5 400)
!(stimulate target6 0)

;########################## Creating incident links between atoms #############################
!(add-atom &incident 
    (source 
        (
            (INHERITANCE_LINK target3 source)
            (INHERITANCE_LINK source target4)
            (INHERITANCE_LINK source target5)
            (INHERITANCE_LINK source target6)
        )
    )
)

!(add-atom &incident (target3 ( (INHERITANCE_LINK target3 (ASYMMETRIC_HEBBIAN_LINK sorce target4)) (INHERITANCE_LINK target3 source))))
!(add-atom &incident (target4 ( (INHERITANCE_LINK source target4))))
!(add-atom &incident (target5 ( (INHERITANCE_LINK source target5))))
!(add-atom &incident (target6 ( (INHERITANCE_LINK source target6))))
!(add-atom &incident (target8 ( (INHERITANCE_LINK (ASYMMETRIC_HEBBIAN_LINK source target4) target8))))

;########################## Creating hebbian links between atoms #############################

!(setStv (ASYMMETRIC_HEBBIAN_LINK source target3) (0.6 0.1))
!(setStv (ASYMMETRIC_HEBBIAN_LINK source target4) (0.5 0.1))
!(setStv (ASYMMETRIC_HEBBIAN_LINK target1 target2) (0 1))
!(setStv (ASYMMETRIC_HEBBIAN_LINK target2 target3) (0 1))



;########################## Running the AF Importance Diffusion Agent #############################
!(AFImportanceDiffusionAgent-Run &incident (TypeSpace))
;########################## Testing the STI values #############################
!(test (getSti source) 6196.857142857143)
!(test (getSti target1) 8000.0)
!(test (getSti target2) 8000.0)
!(test (getSti target3) 4961.714285714286)
!(test (getSti target4) 4961.428571428572)
!(test (getSti target5) 4960.0)
!(test (getSti target6) 0.0)
!(test (getSti target7) 0.0)
!(test (getSti target8) 0.0)

!(test (getSti (HEBBIAN_LINK source target1)) 0.0)
!(test (getSti (HEBBIAN_LINK source target2)) 0.0)
!(test (getSti (ASYMMETRIC_HEBBIAN_LINK source target3)) 0.0)
!(test (getSti (INHERITANCE_LINK source target4)) 3990.0)
!(test (getSti (ASYMMETRIC_HEBBIAN_LINK target1 target2)) 0.0)
!(test (getSti (INHERITANCE_LINK source target5)) 3990.0)
!(test (getSti (INHERITANCE_LINK source target6)) 950.0)
!(test (getSti (INHERITANCE_LINK target3 source)) 2470.0)
!(test (getSti (ASYMMETRIC_HEBBIAN_LINK target2 target3)) 0.0)
!(test (getSti (INHERITANCE_LINK target3 (ASYMMETRIC_HEBBIAN_LINK sorce target4))) 1520.0)

; ;########################## Running the AF Importance Diffusion Agent #############################
!(AFImportanceDiffusionAgent-Run &incident (TypeSpace))
; ;########################## Testing the STI values #############################
!(test (getSti source) 6006.915338095238)
!(test (getSti target1) 8000.0)
!(test (getSti target2) 8000.0)
!(test (getSti target3) 3834.982542857143)
!(test (getSti target4) 3834.7021190476194)
!(test (getSti target5) 3833.3)
!(test (getSti target6) 180.5)
!(test (getSti target7) 0.0)
!(test (getSti target8) 0.0)

!(test (getSti (HEBBIAN_LINK source target1)) 0.0)
!(test (getSti (HEBBIAN_LINK source target2)) 0.0)
!(test (getSti (ASYMMETRIC_HEBBIAN_LINK source target3)) 0.0)
!(test (getSti (INHERITANCE_LINK source target4)) 4947.844285714285)
!(test (getSti (ASYMMETRIC_HEBBIAN_LINK target1 target2)) 0.0)
!(test (getSti (INHERITANCE_LINK source target5)) 4947.301428571429)
!(test (getSti (INHERITANCE_LINK source target6)) 1177.7014285714286)
!(test (getSti (ASYMMETRIC_HEBBIAN_LINK target2 target3)) 0.0)
!(test (getSti (INHERITANCE_LINK target3 (ASYMMETRIC_HEBBIAN_LINK sorce target4))) 1885.1257142857144)

