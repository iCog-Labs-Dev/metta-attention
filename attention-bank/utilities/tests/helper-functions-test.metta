!(import! &self (library lib_import))
!(import_prolog_function working_dir)
!(import_prolog_function directory_file_path)
!(import_prolog_function absolute_file_name)

(= (registerLocalMettaAttentionLibrary)
    (let*
        (
            ($testDir (working_dir))
            ($rootPath (directory_file_path $testDir "../../.."))
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
!(import! &self (library metta-attention attention-bank/bank/attentional-focus/attentional-focus))
!(import! &self (library metta-attention attention-bank/bank/attention-bank))
!(import! &self (library metta-attention attention-bank/attention-value/getter-and-setter))
!(import! &self (library metta-attention attention-bank/bank/importance-index/importance-index))
!(test (filter ((c)(a)(f h j k)(s c)(g j)(d)()()) notEmpty) ((c)(a)(f h j k)(s c)(g j)(d)))

!(test (filter (()()) notEmpty) ())

;!(test (size ((3 (c)) (1 (a)) (37 (f h j k)) (17 (s c)) (18 (g j)) (2 (d)))) 6)
;!(test (size ()) 0)

;! (test (Max (1 2 3 17 18 37)) 37)
;! (test (Max (34 22 1 17 18 107)) 107)

;! (test (Min (34 22 1 17 18 107)) 1)
;! (test (Min (1 2 3 17 18 37)) 1)

!(setAv a (1 2 4))
!(setAv B (18 2 4))
!(setAv v (19 2 4))
!(setAv p (100 2 4))
!(test (removeDuplicates (a a d c)) (a d c))
!(test (removeDuplicates (a a)) (a))
!(test (flattener ((s c) (G E) (a) (g) (f h j k) (d))) (s c G E a g f h j k d))

!(test (concatTuple (A B C) (D)) (A B C D))
!(test (reverseExpr (a b c d)) (d c b a))
!(test (reverseExpr ()) ())

!(test (contains (Abebe Kebede Chala Almaz) Gemechu) False)
!(test (collectContents ((q) (w) (e r) (t t)) ()) (q w e r t t))
!(test (sortDecend (5 1 8 3)) (8 5 3 1))
!(test (sorter (4 9 2 6 1)) (1 2 4 6 9))
!(test (sortAtomsDescending (p B a v) getSti) (p v B a))
