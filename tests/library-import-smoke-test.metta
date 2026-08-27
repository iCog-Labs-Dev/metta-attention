; Verifies that the public library entry point imports repo Python helpers.
!(import! &self (library lib_import))
!(import_prolog_function working_dir)
!(import_prolog_function directory_file_path)
!(import_prolog_function absolute_file_name)
!(import! &self (library lib_he))

(= (registerLocalMettaAttentionLibrary)
    (let*
        (
            ($testsDir (working_dir))
            ($parentDir (directory_file_path $testsDir ".."))
            ($repoRoot (absolute_file_name $parentDir))
        )
        (assertaPredicate (Predicate (library_path $repoRoot)))
    )
)

!(registerLocalMettaAttentionLibrary)
!(import! &self (library metta-attention lib))

(= (runLibraryImportSmokeTest)
    (progn
        (test (getAttentionParam FUNDS_STI) 100000)
        (test (py-call (getelement.getTopK (3 1 2) 2)) (3 2))
        (test (py-call (getelement.getK (3 1 2) 2)) (3 1))
        (test (py-call (topology_metrics.topology_metric_values ((A B) (B C) (C A)))) (1 1 0 0))
        (test (py-call (community_detector.get_dynamic_modules (A B) (((ASYMMETRIC_HEBBIAN_LINK A B) (STV 1.0 1.0))))) ((A B)))
        (test (py-call (logger.normalize_metric_name "af-resource")) af_resource)
        LibraryImportSmokeTestPassed
    )
)
