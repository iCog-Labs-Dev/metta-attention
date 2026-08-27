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
!(import! &self (library metta-attention attention-bank/attention-value/getter-and-setter))
!(import! &self (library metta-attention attention-bank/bank/attention-bank))
!(import! &self (library metta-attention attention-bank/bank/importance-index/importance-index))
!(import! &self (library metta-attention attention-bank/bank/attentional-focus/attentional-focus))
!(import! &self (library metta-attention attention-bank/utilities/recentVal))
; Example usage to compute STI and LTI wages
!(test (calculateSTIWage) 20.0)
!(test (calculateLTIWage) 20.0)

; Initial AttentionValues
!(setAv x (200.0 200.0 0.0))
!(setAv y (200.0 200.0 0.0))
!(setAv z (200.0 200.0 1.0))


; Stimulate the atom with a stimulus of 1.5
!(stimulate x 1.5)

; Retrieve the updated AttentionValue
!(test (getAv x) (AV 230.0 230.0 0.0))

; Check updated funds
!(test (getAttentionParam FUNDS_STI) 99370.0)
!(test (getAttentionParam FUNDS_LTI) 99370.0)

; Stimulate the atom with a stimulus of 2
!(stimulate x 2)

; Retrieve the updated AttentionValue
!(test (getAv x) (AV 270.0 270.0 0.0))

; Check updated funds
!(test (getAttentionParam FUNDS_STI) 99330.0)
!(test (getAttentionParam FUNDS_LTI) 99330.0)

; Check the  attentional focus  is updated  when an atom is stimulated

!(stimulate y 2)

; Check new Atom is added to bin 0
!(stimulate w 0)

!(let $afAtoms
    (getAfAtoms)
    (test (subtraction-atom $afAtoms (x y z w)) ())
)
