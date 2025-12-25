!(import! &self ../../../PeTTa/lib/lib_he)
!(import! &self ../../../metta-attention/attention/AttentionParam)
!(import! &self ../../../metta-attention/attention-bank/utilities/helper-functions)
!(import! &self ../../../metta-attention/attention-bank/utilities/recentVal)

!(import! &self ../../../metta-attention/attention-bank/attention-value/getter-and-setter)

!(import! &self ../../../metta-attention/attention-bank/bank/importance-index/importance-index)
!(import! &self ../../../metta-attention/attention/Neighbors)
!(import! &self ../../../metta-attention/experiments/logger)
!(import! &self "../../../metta-attention/experiments/utils/logger.py")
!(import! &self ../../../metta-attention/attention-bank/bank/attention-bank)
!(import! &self ../../../metta-attention/attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../../metta-attention/attention-bank/bank/stochastic-importance-diffusion/stochastic-importance-diffusion)
!(import! &self ../../../metta-attention/attention/RentCollectionAgent/RentCollectionBaseAgent/RentCollectionBaseAgent)
!(import! &self ../../../metta-attention/attention/RentCollectionAgent/WARentCollectionAgent/WARentCollectionAgent)
!(import! &self ../../../metta-attention/attention/RentCollectionAgent/AFRentCollectionAgent/AFRentCollectionAgent)
!(import! &self ../../../metta-attention/attention/ImportanceDiffusionAgent/ImportanceDiffusionBase/ImportanceDiffusionBase)
!(import! &self ../../../metta-attention/attention/ImportanceDiffusionAgent/WAImportanceDiffusionAgent/WAImportanceDiffusionAgent)
!(import! &self ../../../metta-attention/attention/ImportanceDiffusionAgent/AFImportanceDiffusionAgent/AFImportanceDiffusionAgent)
!(import! &self ../../../metta-attention/attention/HebbianUpdatingAgent/HebbianUpdatingAgent)
!(import! &self ../../../metta-attention/attention/HebbianCreationAgent/HebbianCreationAgent)
!(import! &self ../../../metta-attention/experiments/runner-Def)
; =================== Set hyperparameters =====================
!(updateAttentionParam MAX_AF_SIZE 5.0)
!(updateAttentionParam TARGET_STI 1000.0) 
!(updateAttentionParam TARGET_LTI 1000.0) 
!(updateAttentionParam STI_FUNDS_BUFFER 1000.0) 
!(updateAttentionParam LTI_FUNDS_BUFFER 1000.0) 
!(updateAttentionParam FUNDS_STI 2000.0) 
!(updateAttentionParam FUNDS_LTI 2000.0) 
!(updateAttentionParam AFRentFrequency 9.0)

; =================== Set links containing prior to testing ==============
!(setStv (SimilarityLink abamectin  Ants) (0.245 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK  aphids abamectin) (0.245 0.9))
!(setStv (SimilarityLink  aldicarb  aflatoxin) (0.075 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK  aconite  aldicarb) (0.253 0.9))
!(setStv (SimilarityLink  acetamiprid  Botulinum) (0.075 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK  alcohol  acetamiprid) (0.253 0.9))

; ================== assertions About inital state of Ecan spaces =============
!(assertEqual (getAfAtoms) ())
!(assertEqual (getAllAtomsWithBins) ())
!(assertEqual (match &timer (firstTime $x) $x) True)


; !(stimulate Ants 30)
; !(stimulate aphid 30)
; !(stimulate armyworm 30)
; !(stimulate beetwebworm 30)
; !(stimulate spider 30)
; !(stimulate beanpodborer 30)
; !(getAfAtoms)


!(stimulate Ants 30.0)
!(test-superpose)
!(size-atom (getAfAtoms))

!(test (getAfAtoms) (Ants (SimilarityLink abamectin Ants)))
!(test (getSti Ants) 360.0)
!(test (getLti Ants) 600.0)
!(test (getSti (SimilarityLink abamectin Ants)) 240.0)
!(test (getLti (SimilarityLink abamectin Ants)) 0.0)
!(test (getAllAtomsWithBins) (Ants (SimilarityLink abamectin Ants)))
!(test (getBin Ants) 52.0)
!(test (getBin (SimilarityLink abamectin Ants)) 47.0)

; !(out (match &timer (firstTime $x) $x))
!(test (match &timer (firstTime $x) $x) False)

(test 
    (let $asym 
        (collapse (match (TypeSpace) ((ASYMMETRIC_HEBBIAN_LINK $x $y) $z) (ASYMMETRIC_HEBBIAN_LINK $x $y))) 
        (size-atom $asym)
    )
    5
)


!(stimulate aflatoxin 30.0)
!(test (getAttentionParam FUNDS_STI) 980.0)
; ; !(py-call (time.sleep 1))
!(test-superpose)

!(test (> (getAttentionParam FUNDS_STI) 980.0) True)

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

!(test
    (let $asym 
        (collapse (match (TypeSpace) ((ASYMMETRIC_HEBBIAN_LINK $x $y) $z) (ASYMMETRIC_HEBBIAN_LINK $x $y))) 
        (size-atom $asym)
    )
    23
)
