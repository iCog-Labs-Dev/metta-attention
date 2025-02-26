!(register-module! ../../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &self metta-attention:attention:important-diffusion-agent:helper:removeHebbianLink)
!(import! &self metta-attention:attention:ImportanceDiffusionBase:importanceDiffusion)
!(import! &self metta-attention:attention:ImportanceDiffusionBase:diffusionAtom)
!(import! &self metta-attention:attention-bank:bank:atom-bins:get-min-max-content)
!(import! &self metta-attention:attention:AFImportantDiffusionAgent:AFImportanceDiffusionAgent)


;preparing the test dummy data
!(add-atom &atombin (1 (A)))
!(add-atom &atombin (2 (B)))
!(add-atom &atombin (3 (C)))
!(add-atom &atombin (4 (D)))
!(setAv A (0.0 0.0 0.0))
!(setAv B (7.0 4.0 0.0))
!(setAv c (0.0 0.0 0.0))
!(setAv D (100.0 200.0 300.0))
! (setStv A (400 400))
! (setStv B (400 400))
! (setStv C (400 400))
! (setStv D (400 400))
! (setAv A (10 20 1))
! (setAv B (30 40 1))
! (setAv C (50 50 1))
! (setAv D (400 400 1))
!(addAtomToAF A)
!(addAtomToAF B)
!(addAtomToAF C)
;add hebbian link between two atom
!(add-atom &attentionalFocus (habbianlink A B))
!(add-atom &attentionalFocus (habbianlink A C))
!(add-atom &attentionalFocus (habbianlink A D))
!(add-atom &attentionalFocus (habbianlink C B))
;add type hebbian link
!(add-atom &heabinLink (A HebbianLink))
!(add-atom &heabinLink (B HebbianLink))


!(incidentAtoms A)

;add ASYMMETRIC_HEBBIAN_LINK for mock test
!(add-atom &atombin (1 (E)))
!(add-atom &atombin (2 (F)))
!(add-atom &atombin (3 (G)))
!(add-atom &atombin (4 (H)))
!(setAv E (0.0 0.0 0.0))
!(setAv F (7.0 4.0 0.0))
!(setAv G (0.0 0.0 0.0))
!(setAv H (100.0 200.0 300.0))
! (setStv E (4 5))
! (setStv F (1 2))
! (setStv G (3 3))
! (setStv H (1 0.7))
! (setAv E (10 20 1))
! (setAv F (30 40 1))
! (setAv G (50 50 1))
! (setAv H (400 400 1))

!(addAtomToAF E)
!(addAtomToAF F)
!(addAtomToAF G)
!(add-atom &attentionalFocus (ASYMMETRIC_HEBBIAN_LINK A F))
!(add-atom &attentionalFocus (ASYMMETRIC_HEBBIAN_LINK A G))
!(hebbianAdjacentAtoms A)

;for this test I assume the random from atoms that is not present in AF is A 
;because the only element that is not added to AF is A
;this function return the incoming atoms to the target atom also
;the order is random so the answer may be (C D) or (D C)
!(incidentAtoms A)
!(assertEqual (size-atom (incidentAtoms A)) 2)

;for ASYMMETRIC_HEBBIAN_LINK the result should be F G
;this function return the incoming atoms to the target atom also
; the order is random so the answer may be (F G) or (G F)
!(hebbianAdjacentAtoms A)
!(assertEqual (size-atom (hebbianAdjacentAtoms A)) 2)

;this function return the probability vector for the incident atoms
; this function return value is must be ((C 0.5) (D 0.5)) 
; the order is random so the answer may be ((D 0.5) (C 0.5)) or ((C 0.5) (D 0.5))
!(let* (
    ($incidentAtoms (incidentAtoms A))
    ($hebbianAdjacentAtoms (hebbianAdjacentAtoms A))
    ($probabilityVectorIncident (probabilityVectorIncident $incidentAtoms))

    )
    $probabilityVectorIncident
)

;function calculateHebbianDiffusionPercentage return the value of the diffusion amount
;this function return value is must be 2
!(assertEqual (calculateHebbianDiffusionPercentage F ) 2)

;function probabilityVectorHebbianAdjacent return the probability vector for the hebbian adjacent atoms
; this function return value is must be ((F 1) (G 4.5))
; the order is random so the answer may be ((G 4.5) (F 1)) or ((F 1) (G 4.5))
!(let* (
        ($incidentAtoms (incidentAtoms A))
        ($hebbianAdjacentAtoms (hebbianAdjacentAtoms A))
        ($probabilityVectorIncident (probabilityVectorIncident $incidentAtoms))
        ($calculateDiffusionAmount (calculateHebbianDiffusionPercentage F))
        ($probabilityVectorHebbianAdjacent (probabilityVectorHebbianAdjacent  A $hebbianAdjacentAtoms))
    )
    $probabilityVectorHebbianAdjacent
)

;function combineIncidentAdjacentVectors return the combined probability vector for the incident and hebbian adjacent atoms
; this function return value is must be [((D 0.43125) (C 0.43125) (F 0.025) (G 0.1125))]
; the order is random so the answer may be [((C 0.43125) (D 0.43125) (G 0.1125) (F 0.025))] or [((D 0.43125) (C 0.43125) (F 0.025) (G 0.1125))]
!(let* (
        ($incidentAtoms (incidentAtoms A))
        ($hebbianAdjacentAtoms (hebbianAdjacentAtoms A))
        ($probabilityVectorIncident (probabilityVectorIncident $incidentAtoms))
        ($calculateDiffusionAmount (calculateHebbianDiffusionPercentage F))
        ($probabilityVectorHebbianAdjacent (probabilityVectorHebbianAdjacent  A $hebbianAdjacentAtoms))
        ($probabilityVector (combineIncidentAdjacentVectors $probabilityVectorIncident $probabilityVectorHebbianAdjacent))
    )
    $probabilityVector
)

;function calculateDiffusionAmount return the value of the diffusion amount
;this function return value is must be 4
!(assertEqual (calculateDiffusionAmount A) 4)

;function diffuseAtomHelper return the empty value
;this function return value is must be ()
;before this function when we try to get-atoms from space it must be empty
!(get-atoms &diffusedAtomSpace)
!(let* (
        ($incidentAtoms (incidentAtoms A))
        ($hebbianAdjacentAtoms (hebbianAdjacentAtoms A))
        ($probabilityVectorIncident (probabilityVectorIncident $incidentAtoms))
        ($calculateDiffusionAmount (calculateHebbianDiffusionPercentage F))
        ($probabilityVectorHebbianAdjacent (probabilityVectorHebbianAdjacent  A $hebbianAdjacentAtoms))
        ($probabilityVector (combineIncidentAdjacentVectors $probabilityVectorIncident $probabilityVectorHebbianAdjacent))
        ($totalDiffusionAmount (calculateDiffusionAmount A))
        ($_ (diffuseAtomHelper $probabilityVector $totalDiffusionAmount A))
    )
    $_
)
;after the above function when we try to get-atoms from space  the space must have some value
;the vaule of the space is [(A F 0.1), (A G 0.45), (A C 1.725), (A D 1.725)]
!(get-atoms &diffusedAtomSpace)

