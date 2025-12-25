!(import! &self ../../../../PeTTa/lib/lib_he)
!(import! &self ../../../../metta-attention/attention/AttentionParam)
!(import! &self ../../../../metta-attention/attention-bank/utilities/helper-functions)
!(import! &self ../../../../metta-attention/attention-bank/bank/importance-index/importance-index)
!(import! &self ../../../../metta-attention/attention-bank/attention-value/getter-and-setter)
!(import! &self ../../../../metta-attention/attention-bank/bank/attention-bank)
!(import! &self ../../../../metta-attention/attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../../../metta-attention/attention-bank/utilities/recentVal)
!(import! &self ../../../../metta-attention/attention/Neighbors)
!(import! &self ../../../../metta-attention/attention/HebbianCreationAgent/HebbianCreationAgent)

!(updateAttentionParam MAX_AF_SIZE 4.0)
; !(bind! 900.0.0 900.0.0)
; Populate the AtomSpace with the example atoms

!(setStv Kermit (0.001 900.0.0))

!(setStv Frog (0.01 900.0.0))

!(setStv Animal (0.1 900.0.0))

!(setStv alive (0.01 900.0.0))

!(setStv slimy (0.01 900.0.0))

; Create the links

!(setStv (INHERITANCE_LINK Kermit Frog) (0.9 900.0.0))

!(setStv (INHERITANCE_LINK Frog Animal) (0.9 900.0.0))

!(setStv (EVALUATION_LINK Frog alive) (0.9 900.0))

!(setStv (EVALUATION_LINK Frog slimy) (0.9 900.0))

!(setStv (EVALUATION_LINK animal slimy) (0.9 900.0))

; Populate the AtomSpace with additional dummy atoms

!(setStv Dummy1 (0.001 900.0))

!(setStv Dummy2 (0.001 900.0))

!(setStv Dummy3 (0.001 900.0))

; Create the links for dummy atoms

!(setStv (INHERITANCE_LINK Dummy1 Dummy2) (0.9 900.0.0))

!(setStv (INHERITANCE_LINK Dummy2 Dummy3) (0.9 900.0.0))

; Stimulate the atoms in the AttentionalFocus with a stimulus of 200

!(stimulate Kermit 200.0)
!(stimulate Frog 200.0)
!(stimulate Animal 200.0)
!(stimulate alive 200.0)
!(stimulate (EVALUATION_LINK animal slimy) 100.0)

!(HebbianCreationAgent-Run (TypeSpace))

;;Confirm that only n*(n-1) = 12 AsymmetricHebbianLinks were formed,
;;indicating that none incorrectly include "slimy" nor the dummy atoms
!(let $afAtoms
    (getAfAtoms)
    (test (size-atom $afAtoms) 4)
)
!(getAfAtoms)
; !(collapse (match (TypeSpace) ((ASYMMETRIC_HEBBIAN_LINK $x $y) $value) (ASYMMETRIC_HEBBIAN_LINK $x $y)))

!(test   
    (let $atoms (collapse 
                    (match (TypeSpace) ((ASYMMETRIC_HEBBIAN_LINK $x $y) $value) 
                            (ASYMMETRIC_HEBBIAN_LINK $x $y))) (size-atom $atoms))
    12
)