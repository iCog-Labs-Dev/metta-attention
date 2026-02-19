!(import! &self lib/lib_he)
!(import! &self lib/lib_spaces)
!(import! &self ../AttentionParam.metta)
!(import! &self ../../attention-bank/utilities/helper-functions)
!(import! &self ../../attention-bank/utilities/recentVal)

!(import! &self ../../attention-bank/attention-value/getter-and-setter)

!(import! &self ../../attention-bank/bank/importance-index/importance-index)
!(import! &self ../Neighbors)
!(import! &self "../../experiments/utils/logger.py")
!(import! &self ../../experiments/logger)
!(import! &self ../../attention-bank/bank/attention-bank)
!(import! &self ../../attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../attention-bank/bank/stochastic-importance-diffusion/stochastic-importance-diffusion)
!(import! &self ../RentCollectionAgent/RentCollectionBaseAgent/RentCollectionBaseAgent)
!(import! &self ../RentCollectionAgent/WARentCollectionAgent/WARentCollectionAgent)
!(import! &self ../RentCollectionAgent/AFRentCollectionAgent/AFRentCollectionAgent)
!(import! &self ../ImportanceDiffusionAgent/ImportanceDiffusionBase/ImportanceDiffusionBase)
!(import! &self ../ImportanceDiffusionAgent/WAImportanceDiffusionAgent/WAImportanceDiffusionAgent)
!(import! &self ../ImportanceDiffusionAgent/AFImportanceDiffusionAgent/AFImportanceDiffusionAgent)
!(import! &self ../HebbianUpdatingAgent/HebbianUpdatingAgent)
!(import! &self ../HebbianCreationAgent/HebbianCreationAgent)
!(import! &self ../runner-Def)

; =================== Set hyperparameters =====================
!(updateAttentionParam MAX_AF_SIZE 5.0)
!(updateAttentionParam TARGET_STI 1000.0) 
!(updateAttentionParam TARGET_LTI 1000.0) 
!(updateAttentionParam STI_FUNDS_BUFFER 1000.0) 
!(updateAttentionParam LTI_FUNDS_BUFFER 1000.0) 
!(updateAttentionParam FUNDS_STI 2000.0) 
!(updateAttentionParam FUNDS_LTI 2000.0) 

; =================== Set links containing prior to testing ==============
!(setStv (SimilarityLink abamectin  Ants) (0.245 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK  aphids abamectin) (0.245 0.9))
!(setStv (SimilarityLink  aldicarb  aflatoxin) (0.075 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK  aconite  aldicarb) (0.253 0.9))
!(setStv (SimilarityLink  acetamiprid  Botulinum) (0.075 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK  alcohol  acetamiprid) (0.253 0.9))


; ================== assertions About inital state of Ecan spaces =============
!(test (getAfAtoms) ())

; ======================= inital stimulation of Atom ==========================
!(stimulate Ants 30)

; ========================== RentCollectionAgent ==============================
!(test (match &timer (firstTime $x) $x) True)

!(AFRentCollectionAgent-run)

; => assert sti is not changed and parameter firstTime is changed
!(test (getSti Ants) 600.0)
!(test (match &timer (firstTime $x) $x) False)


; ======================== AFImportanceDiffusionAgent =========================
!(AFImportanceDiffusionAgent-Run (TypeSpace))

; => assert changes to attentional focus and atoms sti lti and bin
!(test (subtraction-atom (getAfAtoms) (Ants (SimilarityLink abamectin Ants))) ())
!(test (getSti Ants) 360.0)
!(test (getLti Ants) 600.0)
!(test (getSti (SimilarityLink abamectin Ants)) 240.0)
!(test (getLti (SimilarityLink abamectin Ants)) 0.0)
!(test (subtraction-atom (getAllAtomsWithBins) ((SimilarityLink abamectin Ants) Ants)) ())

; ======================== HebbianCreationAgent =========================
!(HebbianCreationAgent-Run (TypeSpace))

; => assert the state of newAtomInAV and number of ASYMMETRIC_HEBBIAN_LINK
!(test 
    (let $asym 
        (collapse (match (TypeSpace) ((ASYMMETRIC_HEBBIAN_LINK $x $y) $z) (ASYMMETRIC_HEBBIAN_LINK $x $y))) 
        (size-atom $asym)
    )
    5
)


; ======================== HebbianUpdatingAgent =========================
!(HebbianUpdatingAgent-Run (TypeSpace))
; => assert the number of unique Stv values has increased
!(let* 
    (
        ($stvs (collapse (match (TypeSpace) ((ASYMMETRIC_HEBBIAN_LINK $x $y) $val) $val)))
        ($uniqueStv (unique-atom $stvs))
        ($sizeStv (size-atom $uniqueStv))
    )
    (test (> $sizeStv 3) True)
)

; => second iteration of agents
!(stimulate aflatoxin 30)

; ========================== RentCollectionAgent ==============================
!(test (getAttentionParam FUNDS_STI) 980.0)
!(py-call (time.sleep 0.3))
!(AFRentCollectionAgent-run)

; => assert FUNDS_STI retrived from atoms
!(test (> (getAttentionParam FUNDS_STI) 980.0) True)

; ======================== AFImportanceDiffusionAgent =========================
!(AFImportanceDiffusionAgent-Run (TypeSpace))

; => assert changes to attentional focus and atoms sti lti and bin
!(let $afAtoms
    (getAfAtoms)
    (test
        (subtraction-atom 
            $afAtoms
            (Ants (SimilarityLink abamectin Ants) aflatoxin abamectin (SimilarityLink aldicarb aflatoxin))
        )
        ()
    )
)
!(test (getLti (SimilarityLink abamectin Ants)) 0.0)

; ======================== HebbianCreationAgent =========================
!(HebbianCreationAgent-Run (TypeSpace))

!(test 
    (let $asym 
        (collapse (match (TypeSpace) ((ASYMMETRIC_HEBBIAN_LINK $x $y) $z) (ASYMMETRIC_HEBBIAN_LINK $x $y))) 
        (size-atom $asym)
    )
    23
)

; ======================== HebbianUpdatingAgent =========================
!(HebbianUpdatingAgent-Run (TypeSpace))

; => assert the number of unique Stv values has increased
!(let* 
    (
        ($stvs (collapse (match (TypeSpace) ((ASYMMETRIC_HEBBIAN_LINK $x $y) $val) $val)))
        ($uniqueStv (unique-atom $stvs))
        ($sizeStv (size-atom $uniqueStv))
    )
    (test (> $sizeStv 4) True)
)

