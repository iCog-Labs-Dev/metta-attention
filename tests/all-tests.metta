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
!(import_prolog_functions_from_file (library metta-attention tests/test_shell_runner.pl) (run_metta_attention_tests run_metta_attention_tests_detailed))

(= (runAllMettaTests)
    (run_metta_attention_tests)
)

(= (runAllMettaTestsDetailed)
    (run_metta_attention_tests_detailed)
)


