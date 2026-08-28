:- use_module(library(process)).

metta_attention_repo_root(Root) :-
    source_file(metta_attention_repo_root(_), File),
    file_directory_name(File, TestsDir),
    directory_file_path(TestsDir, '..', Root0),
    absolute_file_name(Root0, Root).

metta_attention_test_script(Script) :-
    metta_attention_repo_root(Root),
    directory_file_path(Root, 'scripts/run-tests.sh', Script).

run_metta_attention_tests('AllTestsPassed') :-
    metta_attention_repo_root(Root),
    metta_attention_test_script(Script),
    process_create(path(bash), [Script], [cwd(Root), process(PID)]),
    process_wait(PID, Status),
    ( Status = exit(0)
    -> true
    ;  throw(error(metta_attention_tests_failed(Status),
             context(run_metta_attention_tests/1, Script)))
    ).

run_metta_attention_tests_detailed(Result) :-
    run_metta_attention_tests(Result).
