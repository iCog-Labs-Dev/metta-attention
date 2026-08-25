!(bind! &incident (new-space))
!(import! &self lib/lib_he)
!(import! &self lib/lib_spaces)
!(import! &self (library lib_import))

!(import! &self ../AttentionParam)
!(import! &self ../baching)

; utitlities
!(import! &self ../../attention-bank/utilities/helper-functions)
!(import! &self ../../attention-bank/utilities/recentVal)

!(import! &self ../../attention-bank/attention-value/getter-and-setter)
!(import! &self ../../attention-bank/bank/importance-index/importance-index)
!(import! &self ../../attention-bank/bank/attention-bank)
!(import! &self ../../attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../attention-bank/bank/stochastic-importance-diffusion/stochastic-importance-diffusion)

; loggers
!(import! &self ../../experiments/logger)
!(import! &self "../../experiments/utils/logger.py")

!(import! &self ../Neighbors)
!(import! &self ../HebbianCreationAgent/HebbianCreationAgent)
!(import! &self ../HebbianUpdatingAgent/HebbianUpdatingAgent)
!(import! &self ../ImportanceDiffusionAgent/ImportanceDiffusionBase/ImportanceDiffusionBase)
!(import! &self ../ImportanceDiffusionAgent/AFImportanceDiffusionAgent/AFImportanceDiffusionAgent)
!(import! &self ../ImportanceDiffusionAgent/WAImportanceDiffusionAgent/WAImportanceDiffusionAgent)
!(import! &self "../ImportanceDiffusionAgent/getelement.py")
!(import! &self ../RentCollectionAgent/RentCollectionBaseAgent/RentCollectionBaseAgent)
!(import! &self ../RentCollectionAgent/WARentCollectionAgent/WARentCollectionAgent)
!(import! &self ../RentCollectionAgent/AFRentCollectionAgent/AFRentCollectionAgent)
!(import! &self ../RentCollectionAgent/AFRentCollectionAgent/AFRentCollectionAgent2)

!(import! &self ../runner-Def)

; knowldge base

!(add-atom &incident (mush_up_v ((relatedto mush_up_v mushy) (relatedto mush_up_v paste))))
!(add-atom &incident (frosty_a ((formof frostier frosty_a) (formof frostiest frosty_a) (relatedto frosty_a alert) (relatedto frosty_a frost) (relatedto frosty_a chilly) (hascontext frosty_a slang) (derivedfrom frosted frosty_a))))
!(add-atom &incident (dented_a_wn ((synonym dented_a_wn crumpled_a_wn))))
!(add-atom &incident (makhnovism_n ((relatedto makhnovism_n theory) (relatedto makhnovism_n strategy) (relatedto makhnovism_n makhnovist) (relatedto makhnovism_n makhnovite) (hascontext makhnovism_n anarchism) (hascontext makhnovism_n communism))))
!(add-atom &incident (making_mountains ((relatedto mole making_mountains))))
!(add-atom &incident (high_angle_fire_n_wn_act ((isa high_angle_fire_n_wn_act artillery_fire_n_wn_act))))
!(add-atom &incident (divine_law_n_wn_cognition ((isa divine_law_n_wn_cognition law_n_wn_cognition))))
!(add-atom &incident (sir_joseph_john_thomson_n_wn_person ((synonym thomson_n_wn_person sir_joseph_john_thomson_n_wn_person) (synonym joseph_john_thomson_n_wn_person sir_joseph_john_thomson_n_wn_person))))
!(add-atom &incident (john_stuart_mill_n_wn_person ((synonym mill_n_wn_person john_stuart_mill_n_wn_person) (synonym john_mill_n_wn_person john_stuart_mill_n_wn_person))))
!(add-atom &incident (anticize_v ((relatedto anticize_v antic))))
!(add-atom &incident (mutual_induction_n_wn_phenomenon ((isa mutual_induction_n_wn_phenomenon induction_n_wn_phenomenon))))
!(add-atom &incident (lesages_n ((formof lesages_n lesage))))
!(add-atom &incident (effloresce_v_wn_change ((synonym effloresce_v_wn_change crystallize_v_wn_change) (synonym burst_forth_v_wn_change effloresce_v_wn_change) (mannerof effloresce_v_wn_change bloom_v_wn_change) (mannerof effloresce_v_wn_change encrust_v_wn_change))))
!(add-atom &incident (resequencing_n ((relatedto resequencing_n genome) (relatedto resequencing_n reordering) (relatedto resequencing_n sequencing) (hascontext resequencing_n genetics))))
!(add-atom &incident (damper_a ((formof damper_a damp))))
!(add-atom &incident (butadiyne_n ((relatedto butadiyne_n diacetylene) (hascontext butadiyne_n organic_chemistry))))
!(add-atom &incident (chain_stories_n ((formof chain_stories_n chain_story))))
!(add-atom &incident (e_readers_n ((formof e_readers_n e_reader))))
!(add-atom &incident (gliriform_a ((isa gliran gliriform_a) (isa glirine gliriform_a) (isa gliriform_a euarchontogliran) (relatedto gliriform_a gliran) (relatedto gliriform_a glirine))))
!(add-atom &incident (decorrelated_a ((relatedto decorrelated_a decorrelation))))
!(add-atom &incident (sandquists_n ((formof sandquists_n sandquist))))
!(add-atom &incident (aqueousness ((derivedfrom aqueousness aqueous))))
!(add-atom &incident (sumitriptan_n ((isa sumitriptan_n analgesic_n))))
!(add-atom &incident (aluminum_floating_foot_bridge_n ((isa aluminum_floating_foot_bridge_n temporary_floating_bridge_n))))
!(add-atom &incident (life_n_wn_attribute ((synonym life_n_wn_attribute liveliness_n_wn_attribute))))
!(add-atom &incident (sister_souljah_moments_n ((formof sister_souljah_moments_n sister_souljah_moment))))
!(add-atom &incident (go_on_v_wn_contact ((synonym come_on_v_wn_contact go_on_v_wn_contact) (synonym come_up_v_wn_contact go_on_v_wn_contact) (mannerof go_on_v_wn_contact start_v_wn_motion))))
!(add-atom &incident (prodigalizes_v ((formof prodigalizes_v prodigalize))))
!(add-atom &incident (flare_v ((relatedto flare_v emit) (relatedto flare_v erupt) (relatedto flare_v gaudy) (relatedto flare_v showy) (relatedto flare_v bright) (relatedto flare_v flight) (relatedto flare_v happen) (relatedto flare_v sudden) (relatedto flare_v inflame) (relatedto flare_v operate) (relatedto flare_v outward) (relatedto flare_v aircraft) (relatedto flare_v brightly) (relatedto flare_v dazzling) (relatedto flare_v downward) (relatedto flare_v suddenly) (relatedto flare_v unsteady) (relatedto flare_v intensify) (relatedto flare_v painfully) (relatedto flare_v transition) (relatedto flare_v offensively) (relatedto flare_v inflammation) (hascontext flare_v aviation))))
!(add-atom &incident (amniocytic_a ((relatedto amniocytic_a amniocyte))))
!(add-atom &incident (served_in_cup ((receivesaction sauce served_in_cup))))

(let $expression (mush_up_v frosty_a dented_a_wn makhnovism_n making_mountains high_angle_fire_n_wn_act divine_law_n_wn_cognition
sir_joseph_john_thomson_n_wn_person john_stuart_mill_n_wn_person anticize_v mutual_induction_n_wn_phenomenon lesages_n
effloresce_v_wn_change resequencing_n damper_a butadiyne_n chain_stories_n e_readers_n gliriform_a decorrelated_a sandquists_n
aqueousness sumitriptan_n aluminum_floating_foot_bridge_n life_n_wn_attribute sister_souljah_moments_n 
go_on_v_wn_contact prodigalizes_v flare_v amniocytic_a served_in_cup) $expression)

; runner


; if the difference between fund and target is more than buffer we will stimulate with full capacity which is 20
; if the difference between fund and target is less than buffer but +ve we will stimulate with less capacity but still +ve amount
; if the difference between fund and target is less than buffer with -ve value but its abslute value is less than buffer we stimulate with less than 10/sti wage value
; if the difference between fund and target is less than buffer with -ve value but its absolute is greater than buffer we stimulate 0(this senario wont happen!!)

; RECOMMENDATIONS

; 1 make sure the fund is more larger than the target
; 2 keep an eye on the rate of the fund decreasing
; 3 buffer should be around target with similar amount rate decreasing 

; TARGET

; 1 to be able to recover from deficit state and make sure atoms are getting preper stimulation amount
; 

!(updateAttentionParam MAX_AF_SIZE 10.0)
!(updateAttentionParam TARGET_STI 10000.0) 
!(updateAttentionParam TARGET_LTI 10000.0) 
!(updateAttentionParam STI_FUNDS_BUFFER 1000.0) 
!(updateAttentionParam LTI_FUNDS_BUFFER 1000.0) 
!(updateAttentionParam FUNDS_STI 20000.0) 
!(updateAttentionParam FUNDS_LTI 20000.0) 
!(updateAttentionParam STARTING_FUNDS_STI 20000.0)
!(updateAttentionParam STARTING_FUNDS_LTI 20000.0)
 



!(size-atom (getAfAtoms))


(= (testDynamicity $exp) 
    (if (== $exp ()) ()

(let* (

    ($first (car-atom $exp))
    ($rest (cdr-atom $exp))

    ($stimulate (stimulate $first 50))
    ($sti (getSti $first))
    ($size (size-atom (getAfAtoms)))

    ($atom (println! (af size $size stimulated atom is $first with sti $sti)))
    
    ; ($rent (println! (amount of rent collected )))
    ($agents (collapse (test-superpose &incident)))
    
    ($fund (getAttentionParam FUNDS_STI))
    ($f (println! (total fund $fund)))


   )

   (testDynamicity $rest)

)))

!(testDynamicity (mush_up_v frosty_a dented_a_wn makhnovism_n making_mountains high_angle_fire_n_wn_act divine_law_n_wn_cognition
sir_joseph_john_thomson_n_wn_person john_stuart_mill_n_wn_person anticize_v mutual_induction_n_wn_phenomenon lesages_n
effloresce_v_wn_change resequencing_n damper_a butadiyne_n chain_stories_n e_readers_n gliriform_a decorrelated_a sandquists_n
aqueousness sumitriptan_n aluminum_floating_foot_bridge_n life_n_wn_attribute sister_souljah_moments_n 
go_on_v_wn_contact prodigalizes_v flare_v amniocytic_a served_in_cup))

!(size-atom (getAfAtoms))



