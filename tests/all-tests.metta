; Single MeTTa entry point for the repository's isolated MeTTa test suites.
; It can be run directly, or imported after metta-attention is registered.
!(import! &self (library lib_import))
!(import_prolog_function working_dir)
!(import_prolog_function directory_file_path)
!(import_prolog_function absolute_file_name)

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
!(import! &self (library metta-attention tests/all_tests_runner.py))

(= (runAllMettaTests)
    (py-call (all_tests_runner.run_all_metta_tests))
)

(= (runAllMettaTestsDetailed)
    (py-call (all_tests_runner.run_all_metta_tests_detailed))
)

!(runAllMettaTests)
