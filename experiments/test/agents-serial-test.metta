!(register-module! ../../../metta-attention)
!(import! &self metta-attention:attention:ForgettingAgent:ForgettingAgent)
!(import! &self metta-attention:attention:AttentionParam)
!(import! &self metta-attention:attention:RentCollectionAgent:RentCollectionBaseAgent:RentCollectionBaseAgent)
!(import! &self metta-attention:attention:RentCollectionAgent:WARentCollectionAgent:WARentCollectionAgent)
!(import! &self metta-attention:attention:RentCollectionAgent:AFRentCollectionAgent:AFRentCollectionAgent)
!(import! &self metta-attention:attention:ImportanceDiffusionAgent:ImportanceDiffusionBase:ImportanceDiffusionBase)
!(import! &self metta-attention:attention:ImportanceDiffusionAgent:WAImportanceDiffusionAgent:WAImportanceDiffusionAgent)
!(import! &self metta-attention:attention:ImportanceDiffusionAgent:AFImportanceDiffusionAgent:AFImportanceDiffusionAgent)
!(import! &self metta-attention:attention:HebbianUpdatingAgent:HebbianUpdatingAgent)
!(import! &self metta-attention:attention:HebbianCreationAgent:HebbianCreationAgent)
!(import! &self metta-attention:attention:AttentionParam)
!(import! &self metta-attention:attention:Neighbors)
!(import! &self metta-attention:experiments:runner-Def)

!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:utilities:recentVal)

!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:attention-value:get-min-max)

!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &self metta-attention:attention-bank:bank:stochastic-importance-diffusion:stochastic-importance-diffusion)

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
!(assertEqual (getAfAtoms) ())

; ======================= inital stimulation of Atom ==========================
!(stimulate Ants 30)

; ========================== RentCollectionAgent ==============================
!(assertEqual (match &timer (firstTime $x) $x) True)

!(AFRentCollectionAgent-run)

; => assert sti is not changed and parameter firstTime is changed
!(assertEqual (getSti Ants) 600)
!(assertEqual (match &timer (firstTime $x) $x) False)


; ======================== AFImportanceDiffusionAgent =========================
!(AFImportanceDiffusionAgent-Run (TypeSpace))

; => assert changes to attentional focus and atoms sti lti and bin
!(assertEqual (getAfAtoms) ((SimilarityLink abamectin Ants) Ants))
!(assertEqual (getSti Ants) 360)
!(assertEqual (getLti Ants) 600)
!(assertEqual (getSti (SimilarityLink abamectin Ants)) 240)
!(assertEqual (getLti (SimilarityLink abamectin Ants)) 0)
!(assertEqual (getAllAtomsWithBins) ((SimilarityLink abamectin Ants) Ants))

; ======================== HebbianCreationAgent =========================
!(HebbianCreationAgent-Run (TypeSpace))

; => assert the state of newAtomInAV and number of ASYMMETRIC_HEBBIAN_LINK
!(assertEqual 
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
    (assertEqual (> $sizeStv 3) True)
)

; => second iteration of agents
!(stimulate aflatoxin 30)

; ========================== RentCollectionAgent ==============================
!(assertEqual (getAttentionParam FUNDS_STI) 980)
!(AFRentCollectionAgent-run)

; => assert FUNDS_STI retrived from atoms
!(assertEqual (> (getAttentionParam FUNDS_STI) 980) True)

; ======================== AFImportanceDiffusionAgent =========================
!(AFImportanceDiffusionAgent-Run (TypeSpace))

; => assert changes to attentional focus and atoms sti lti and bin
!(let $afAtoms
    (getAfAtoms)
    (assertEqual
        (subtraction-atom 
            $afAtoms
            (Ants (SimilarityLink abamectin Ants) aflatoxin abamectin (SimilarityLink aldicarb aflatoxin))
        )
        ()
    )
)
!(assertEqual (getLti (SimilarityLink abamectin Ants)) 0)

; ======================== HebbianCreationAgent =========================
!(HebbianCreationAgent-Run (TypeSpace))

!(assertEqual 
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
    (assertEqual (> $sizeStv 4) True)
)

