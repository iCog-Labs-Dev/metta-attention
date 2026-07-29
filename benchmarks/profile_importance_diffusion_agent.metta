!(import! &self lib/lib_he)
!(import! &self lib/lib_spaces)
!(import! &self ../attention/AttentionParam)
!(import! &self ../attention/baching)
!(import! &self ../attention-bank/utilities/helper-functions)
!(import! &self ../attention-bank/utilities/recentVal)
!(import! &self ../attention-bank/attention-value/getter-and-setter)
!(import! &self ../attention-bank/bank/importance-index/importance-index)
!(import! &self ../attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../attention-bank/bank/attention-bank)
!(import! &self ../attention-bank/bank/stochastic-importance-diffusion/stochastic-importance-diffusion)
!(import! &self ../attention/Neighbors)
!(import! &self ../attention/ImportanceDiffusionAgent/ImportanceDiffusionBase/ImportanceDiffusionBase)
!(import! &self "../attention/ImportanceDiffusionAgent/getelement.py")
!(import! &self ../attention/ImportanceDiffusionAgent/AFImportanceDiffusionAgent/AFImportanceDiffusionAgent)
!(import! &self ../attention/ImportanceDiffusionAgent/WAImportanceDiffusionAgent/WAImportanceDiffusionAgent)

; Attention parameters
!(updateAttentionParam FUNDS_STI                   100000.0)
!(updateAttentionParam FUNDS_LTI                   100000.0)
!(updateAttentionParam TARGET_STI                  5000.0)
!(updateAttentionParam TARGET_LTI                  5000.0)
!(updateAttentionParam MAX_AF_SIZE                 20.0)
!(updateAttentionParam MAX_SPREAD_PERCENTAGE       0.4)
!(updateAttentionParam HEBBIAN_MAX_ALLOCATION_PERCENTAGE 0.05)
!(updateAttentionParam TOPK                        1)

; Seed atoms 
!(stimulate id-source  500)
!(stimulate id-target1 400)
!(stimulate id-target2 400)
!(stimulate id-target3 400)
!(stimulate id-target4 300)
!(stimulate id-target5 300)
!(stimulate id-target6 200)
!(stimulate id-target7 100)

; Hebbian links 
!(setStv (ASYMMETRIC_HEBBIAN_LINK id-source  id-target1) (0.8 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK id-source  id-target2) (0.6 0.7))
!(setStv (ASYMMETRIC_HEBBIAN_LINK id-target1 id-target3) (0.5 0.6))
!(setStv (ASYMMETRIC_HEBBIAN_LINK id-target2 id-target4) (0.4 0.5))
!(setStv (ASYMMETRIC_HEBBIAN_LINK id-target3 id-target5) (0.3 0.4))

; Incident space  
!(bind! &id-incident (new-space))
!(add-atom &id-incident
    (id-source
        (
            (INHERITANCE_LINK id-target3 id-source)
            (INHERITANCE_LINK id-source  id-target4)
            (INHERITANCE_LINK id-source  id-target5)
            (INHERITANCE_LINK id-source  id-target6)
        )
    )
)
!(add-atom &id-incident (id-target1 ((INHERITANCE_LINK id-target1 id-source))))
!(add-atom &id-incident (id-target2 ((INHERITANCE_LINK id-source  id-target2))))
!(add-atom &id-incident (id-target3 ((INHERITANCE_LINK id-target3 id-source) (INHERITANCE_LINK id-target3 id-target4))))
!(add-atom &id-incident (id-target4 ((INHERITANCE_LINK id-source  id-target4))))
!(add-atom &id-incident (id-target5 ((INHERITANCE_LINK id-source  id-target5))))
!(add-atom &id-incident (id-target6 ((INHERITANCE_LINK id-source  id-target6))))

; Scratch atoms for tradeSti / tradeList benchmarks 
!(stimulate id-trade-src 600)
!(stimulate id-trade-tgt 200)

; =============================================================================
; ImportanceDiffusionBase primitives
; =============================================================================

; filteroset
; Filters ASYMMETRIC_HEBBIAN_LINK atoms out of an outgoing-set list.
(= (profileFilteroset $n)
   (if (<= $n 0)
       0
       (let* (
               ($oset (collapse (match (TypeSpace) (($x $y $z) $val) ($x $y $z))))
               ($_ (collapse (filteroset $oset)))
             )
             (profileFilteroset (- $n 1))))
)

; incidentAtoms
; Looks up the incident-atom list for an atom in the incident space.
(= (profileIncidentAtoms $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (collapse (incidentAtoms id-source  &id-incident)))
               ($_ (collapse (incidentAtoms id-target1 &id-incident)))
             )
             (profileIncidentAtoms (- $n 1))))
)

; probabilityVectorIncident
; Builds uniform probability vector over incident atoms.
(= (profileProbabilityVectorIncident $n)
   (if (<= $n 0)
       0
       (let* (
               ($inc (collapse (incidentAtoms id-source &id-incident)))
               ($_   (collapse (probabilityVectorIncident $inc)))
             )
             (profileProbabilityVectorIncident (- $n 1))))
)

; probabilityVectorHebbianAjacent
; Builds weighted probability vector over hebbian-adjacent atoms.
(= (profileProbabilityVectorHebbian $n)
   (if (<= $n 0)
       0
       (let* (
               ($iset (collapse (match (TypeSpace) ((ASYMMETRIC_HEBBIAN_LINK id-source $b) $a) $b)))
               ($_    (collapse (probabilityVectorHebbianAjacent id-source $iset)))
             )
             (profileProbabilityVectorHebbian (- $n 1))))
)

; combineIncidentAdjacentVectors
; Merges incident and hebbian probability vectors with hebbian-cap logic.
(= (profileCombineVectors $n)
   (if (<= $n 0)
       0
       (let* (
               ($inc    (collapse (incidentAtoms id-source &id-incident)))
               ($pvInc  (collapse (probabilityVectorIncident $inc)))
               ($iset   (collapse (match (TypeSpace) ((ASYMMETRIC_HEBBIAN_LINK id-source $b) $a) $b)))
               ($pvHeb  (collapse (probabilityVectorHebbianAjacent id-source $iset)))
               ($_      (combineIncidentAdjacentVectors $pvInc $pvHeb))
             )
             (profileCombineVectors (- $n 1))))
)

; calculateHebbianDiffusionPercentation
; Computes mean × confidence for a hebbian link.
(= (profileCalcHebbianDiffusionPct $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (calculateHebbianDiffusionPercentation (ASYMMETRIC_HEBBIAN_LINK id-source id-target1)))
               ($_ (calculateHebbianDiffusionPercentation (ASYMMETRIC_HEBBIAN_LINK id-source id-target2)))
             )
             (profileCalcHebbianDiffusionPct (- $n 1))))
)

; hebbianDiffusionUsed
; Sums proportions already allocated to hebbian neighbours.
(= (profileHebbianDiffusionUsed $n)
   (if (<= $n 0)
       0
       (let* (
               ($iset  (collapse (match (TypeSpace) ((ASYMMETRIC_HEBBIAN_LINK id-source $b) $a) $b)))
               ($pvHeb (collapse (probabilityVectorHebbianAjacent id-source $iset)))
               ($hmax  (getAttentionParam HEBBIAN_MAX_ALLOCATION_PERCENTAGE))
               ($adjaSize (size-atom $pvHeb))
               ($hAlloc (if (== $adjaSize 0) 1 (/ $hmax $adjaSize)))
               ($hProp  (collapse (hebbianProportionSTI $pvHeb $hAlloc)))
               ($_      (hebbianDiffusionUsed $hProp))
             )
             (profileHebbianDiffusionUsed (- $n 1))))
)

; tradeSti
; Transfers a fixed STI amount between two atoms.
(= (profileTradeSti $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (tradeSti id-trade-src id-trade-tgt 5.0))
               ; Restore balance so subsequent iterations have meaningful work
               ($_ (tradeSti id-trade-tgt id-trade-src 5.0))
             )
             (profileTradeSti (- $n 1))))
)

; tradeList
; Aggregates a result list of (source target amount) triples and applies STI
; trades atomically using the same pattern as spreadImportance.
!(stimulate id-tl-a 400)
!(stimulate id-tl-b 300)
!(stimulate id-tl-c 200)
(= (idTradeResult)
    ((id-tl-a id-tl-b 10.0)
     (id-tl-b id-tl-c  8.0)
     (id-tl-a id-tl-c  5.0))
)
(= (profileTradeList $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (collapse (tradeList (idTradeResult))))
             )
             (profileTradeList (- $n 1))))
)

; diffuseAtom  (ImportanceDiffusionBase full pipeline)
(= (profileDiffuseAtomAF $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (collapse (diffuseAtom id-source (TypeSpace) AF)))
             )
             (profileDiffuseAtomAF (- $n 1))))
)

; diffuseAtom
(= (profileDiffuseAtomWA $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (collapse (diffuseAtom id-source (TypeSpace) WA)))
             )
             (profileDiffuseAtomWA (- $n 1))))
)

; =============================================================================
; AFImportanceDiffusionAgent
; =============================================================================

; diffuseIncident
(= (profileDiffuseIncident $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (collapse (diffuseIncident id-source &id-incident)))
               ($_ (collapse (diffuseIncident id-target1 &id-incident)))
             )
             (profileDiffuseIncident (- $n 1))))
)

; diffuseHebbian
(= (profileDiffuseHebbian $n)
   (if (<= $n 0)
       0
       (let* (
               ($afAtoms (getAfAtoms))
               ($kSize   (size-atom $afAtoms))
               ($_ (collapse (diffuseHebbian id-source &id-incident $kSize)))
             )
             (profileDiffuseHebbian (- $n 1))))
)

; AFImportanceDiffusionAgent-Run
(= (profileAFImportanceDiffusionRun $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (AFImportanceDiffusionAgent-Run &id-incident (TypeSpace)))
             )
             (profileAFImportanceDiffusionRun (- $n 1))))
)

; =============================================================================
; WAImportanceDiffusionAgent
; =============================================================================

; diffuseIncidentWA
(= (profileDiffuseIncidentWA $n)
   (if (<= $n 0)
       0
       (let* (
               ($sourceSti (getSti id-source))
               ($maxSpr    (getAttentionParam MAX_SPREAD_PERCENTAGE))
               ($hAlloc    (getAttentionParam HEBBIAN_MAX_ALLOCATION_PERCENTAGE))
               ($diffAmt   (- $sourceSti (diffusedValue id-source $maxSpr)))
               ($afpct     (* $maxSpr (- 1 $hAlloc)))
               ($_ (collapse (diffuseIncidentWA id-source &id-incident $diffAmt $afpct)))
             )
             (profileDiffuseIncidentWA (- $n 1))))
)

; diffuseHebbianWA
(= (profileDiffuseHebbianWA $n)
   (if (<= $n 0)
       0
       (let* (
               ($size    (* (getAttentionParam MAX_AF_SIZE) 0.3))
               ($srcSti  (getSti id-source))
               ($maxSpr  (getAttentionParam MAX_SPREAD_PERCENTAGE))
               ($hAlloc  (getAttentionParam HEBBIAN_MAX_ALLOCATION_PERCENTAGE))
               ($diffAmt (- $srcSti (diffusedValue id-source $maxSpr)))
               ($hebpct  (* $maxSpr $hAlloc))
               ($_ (collapse (diffuseHebbianWA id-source $size $diffAmt $hebpct)))
             )
             (profileDiffuseHebbianWA (- $n 1))))
)

; diffuseWA  (WA path — combined incident + hebbian for one atom)
(= (profileDiffuseWA $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (collapse (diffuseWA id-source &id-incident (TypeSpace))))
             )
             (profileDiffuseWA (- $n 1))))
)

; WAImportanceDiffusionAgent-Run 
(= (profileWAImportanceDiffusionRun $n)
   (if (<= $n 0)
       0
       (let* (
               ($_ (WAImportanceDiffusionAgent-Run &id-incident))
             )
             (profileWAImportanceDiffusionRun (- $n 1))))
)

 

; ImportanceDiffusionBase primitives

!(profileFilteroset                    1000)
!(profileIncidentAtoms                 1000)
!(profileProbabilityVectorIncident     1000)
!(profileProbabilityVectorHebbian      1000)
!(profileCombineVectors                 500)
!(profileCalcHebbianDiffusionPct       5000)
!(profileHebbianDiffusionUsed           500)
!(profileTradeSti                      2000)
!(profileTradeList                      500)
!(profileDiffuseAtomAF                  200)
!(profileDiffuseAtomWA                  200)

; AFImportanceDiffusionAgent

!(profileDiffuseIncident                500)
!(profileDiffuseHebbian                 500)
!(profileAFImportanceDiffusionRun       100)

; WAImportanceDiffusionAgent

!(profileDiffuseIncidentWA              500)
!(profileDiffuseHebbianWA               500)
!(profileDiffuseWA                      200)
!(profileWAImportanceDiffusionRun       100)
