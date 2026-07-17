!(import! &self lib/lib_he)
!(import! &self lib/lib_spaces)
!(import! &self ../../../attention/AttentionParam)
!(import! &self ../../../attention/baching)
!(import! &self ../../utilities/helper-functions)
!(import! &self ../../utilities/recentVal)

!(import! &self ../../attention-value/getter-and-setter)

!(import! &self ../../bank/importance-index/importance-index)
!(import! &self ../../../attention/Neighbors)
!(import! &self "../../../experiments/utils/logger.py")
!(import! &self ../../../experiments/logger)
!(import! &self ../../bank/attention-bank)
!(import! &self ../../bank/attentional-focus/attentional-focus)
!(import! &self ../../bank/stochastic-importance-diffusion/stochastic-importance-diffusion)
!(import! &self ../../../attention/RentCollectionAgent/RentCollectionBaseAgent/RentCollectionBaseAgent)
!(import! &self ../../../attention/RentCollectionAgent/WARentCollectionAgent/WARentCollectionAgent)
!(import! &self ../../../attention/RentCollectionAgent/AFRentCollectionAgent/AFRentCollectionAgent)
!(import! &self ../../../attention/RentCollectionAgent/AFRentCollectionAgent/AFRentCollectionAgent2)
!(import! &self ../../../attention/ImportanceDiffusionAgent/ImportanceDiffusionBase/ImportanceDiffusionBase)
!(import! &self ../../../attention/ImportanceDiffusionAgent/WAImportanceDiffusionAgent/WAImportanceDiffusionAgent)
!(import! &self "../../../attention/ImportanceDiffusionAgent/getelement.py")
!(import! &self ../../../attention/ImportanceDiffusionAgent/AFImportanceDiffusionAgent/AFImportanceDiffusionAgent)
!(import! &self ../../../attention/HebbianUpdatingAgent/HebbianUpdatingAgent)
!(import! &self ../../../attention/HebbianCreationAgent/HebbianCreationAgent)
!(import! &self ../../../experiments/utils/community_detector.py)
!(import! &self ../../../attention/runner-Def)
!(import! &self "../topology_metrics.py")
!(import! &self ../utils)
!(import! &self ../synapse)

!(bind! &incident (new-space))

!(add-atom &incident (Ants ( (SimilarityLink abamectin Ants))))
!(add-atom &incident (abamectin ( (SimilarityLink abamectin hellenophone))))
!(add-atom &incident (aldicarb ( (SimilarityLink aldicarb aflatoxin))))
!(add-atom &incident (aflatoxin ( (SimilarityLink aldicarb aflatoxin))))
!(add-atom &incident (acetamiprid ( (SimilarityLink acetamiprid Botulinum))))
!(add-atom &incident (Botulinum ( (SimilarityLink acetamiprid Botulinum))))


; =================== Set hyperparameters =====================
!(updateAttentionParam MAX_AF_SIZE 5.0)
!(updateAttentionParam TARGET_STI 1000.0) 
!(updateAttentionParam TARGET_LTI 1000.0) 
!(updateAttentionParam STI_FUNDS_BUFFER 1000.0) 
!(updateAttentionParam LTI_FUNDS_BUFFER 1000.0) 
!(updateAttentionParam FUNDS_STI 3000.0) 
!(updateAttentionParam FUNDS_LTI 3000.0) 
!(updateAttentionParam AFRentFrequency 9.0)



!(setStv (ASYMMETRIC_HEBBIAN_LINK A B) (0.8 0.5))
!(setStv (ASYMMETRIC_HEBBIAN_LINK B C) (0.2 0.5))

!(assertEqual
    (getHebLinksWithValues (A) ())
    (((ASYMMETRIC_HEBBIAN_LINK A B) (STV 0.8 0.5)))
)

!(assertEqual
    (identifyModules (lonely) ())
    ((lonely))
)
!(assertEqual
    (identifyModules (A B C) (getHebLinksWithValues (A B) ()))
    ((A) (B) (C)))

!(identifyAllHebbianModules)
!(assertEqual
    (identifyAllHebbianModules)
    ((A) (B) (C)))


!(setStv (ASYMMETRIC_HEBBIAN_LINK A B) (0.5 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK B C) (0.5 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK C A) (0.5 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK B A) (0.5 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK D E) (0.5 0.9))


!(assertEqual (averageMetricScore ((afResource 1.0) (triangleCount 1000) (betti0 2) (betti1 3) (betti2 4) (stiConcentration 3.0))) 2.0)


; =================== Set links containing prior to testing ==============
; !(setStv (ASYMMETRIC_HEBBIAN_LINK  aphids abamectin) (0.245 0.9))
; !(setStv (ASYMMETRIC_HEBBIAN_LINK  aconite  aldicarb) (0.253 0.9))
; !(setStv (ASYMMETRIC_HEBBIAN_LINK  alcohol  acetamiprid) (0.253 0.9))

; ================== assertions About inital state of Ecan spaces =============
!(assertEqual (getAfAtoms) ())
!(assertEqual (getAllAtomsWithBins) ())
!(assertEqual (match &timer (firstTime $x) $x) True)

; here we have total of 3000 global sti fund
!(getAttentionParam FUNDS_STI)

; !(assertEqual (initialize-baseline-cip) true)
; !(assertEqual (transition-to-next-cip) (CIPSnapshot 1 1779340647.1364384 () 
;     ((afResource 0.0) 
;      (stiConcentration 0.0)
;      (linkDensity 0.0)
;      (connectionRatio 0.0)
;      (preallocation 0.0) 
;      (cognitiveSynergy 0.0)
;      (modulation 0.0) 
;      (coordination 0.0) 
;      (contextRetention 0.0)))
; ) ; --- IGNORE --- time can not be asserted

!(get-cip-snapshots 0)
!(get-cip-af 0)

; we have total 5 atoms stimulated
; 3 similarity links getting sti through diffusion
; we have total 23 asymetic hebbian links created

!(stimulate Ants 30.0)
!(stimulate abamectin 30.0)
!(stimulate aldicarb 30.0)
!(stimulate aflatoxin 30.0)
!(stimulate acetamiprid 30.0)

!(getSti Ants) ; 600
!(getSti abamectin) ; 600
!(getSti aldicarb) ; 540
!(getSti aflatoxin) ; 378.0
!(getSti acetamiprid) ; 264.6

; now we have (3000 - 600 + 600 + 540 + 378.0 + 264.6 = 617.4)

!(getAttentionParam FUNDS_STI)

; the first atoms gets higher sti value and full wdge of sti
; when the buffer sti target reached atoms start to get sti according to the global fund budget rule
; during aget excution all agent excute on the existing attentional focus atoms

!(collapse (test-superpose &incident))


; 1 n * (n - 1) aymetric hebbian link will be created 
; 2 1 random atom from attentional focus will be picked and its asymetric hebbian link will be update
; 3 all atoms inside attentional focus will diffuse N% of thire sti to thire related/nighbor links
; 4 rent will be collected from all attentional focus atoms if conditiond are statisfied

!(getSti Ants) ; 372.35652000000005
!(getSti abamectin) ; 371.88
!(getSti aldicarb) ; 334.692
!(getSti aflatoxin) ; 234.28439999999998
!(getSti acetamiprid) ; 163.99908

!(getAttentionParam FUNDS_STI)


!(size-atom (getAfAtoms))

!(getAfAtoms)

!(getAllAtomsWithBins) 

!(size-atom (collapse (match (TypeSpace) ((ASYMMETRIC_HEBBIAN_LINK $x $y) $val) (ASYMMETRIC_HEBBIAN_LINK $x $y))))


; write your synapse metrice tests here

!(initialize-baseline-cip)
!(getAfResourceUsage)
!(getStiConcentration)
!(getLinkDensity)
!(getConnectionRatio)
!(getPreallocationSpace)
!(getCognitiveSynergy)
!(getSelectionModulation)
!(getGlobalCoordination (getAfAtoms))
!(getContextRetention)
!(getCognitiveMaintenance)
!(getEffectiveness)



!(add-atom &cipspace (CIPSnapshot 1 1 (a b c) ()))
!(add-atom &cipspace (CIPSnapshot 2 2 (a b c) ()))
!(add-atom &cipspace (CIPSnapshot 3 2 (d e f) ()))
!(add-atom &cipspace (CIPSnapshot 4 2 (d h i) ()))

; !(match &cipspace (CIPSnapshot 3 $x $y $z) (CIPSnapshot 3 $x $y $z))
!(assertEqual (get-cip-snapshots 3) (CIPSnapshot 3 2 (d e f) ()))


!(assertEqual (get-cip-af 2) (a b c))
!(assertEqual (get-cip-af 3) (d e f))
!(assertEqual (get-cip-af 4) (d h i))



!(add-atom &stiSeries (a (1 2 3 4 5)))
!(add-atom &stiSeries (b (2 3 4 5 6)))
!(add-atom &stiSeries (c (3 4 5 6 7)))

!(assertEqual (getStiSeries a) (1 2 3 4 5))
!(assertEqual (getStiSeries b) (2 3 4 5 6))
!(assertEqual (getStiSeries c) (3 4 5 6 7))

!(cip-af-series 0 4)
!(average-context-retention-pairs (cip-af-series 0 4))

; lettest cip index 4, its retenion with 3 should be 
; 1 common atom (d) and 5 unique atoms (a,b,c,e,f,h,i) so retention should be 1/5 = 0.2

!(assertEqual (getContextRetention (get-cip-af 3) (get-cip-af 4)) 0.2)

; !(collapse (averageList (getStiSeries (superpose (k a b c))))) ; should be (3 4 5)
; !(collapse (averageList (getStiSeries ())))

!(assertEqual (collapse (averageList (getStiSeries (superpose (a b c))))) (3.0 4.0 5.0))

!(collapse (test-superpose &incident))

; ; this changes of sti for atoms shows everytime agents called thire sti will be diffused for thire related links

!(getSti Ants) ; 230.821096464
!(getSti abamectin) ; 230.456362584
!(getSti aldicarb) ; 273.716590584
!(getSti aflatoxin) ; 211.56428618399997
!(getSti acetamiprid) ; 164.26172258399998

!(getAttentionParam FUNDS_STI) ; the fund is consistent accross all agent call?? it should be due to rent collection

