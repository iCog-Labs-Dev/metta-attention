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


; knowldge base

!(static-import! &incident ../../experiments/data/wordnet_stv_clean)


; runner
!(import! &self ../runner-Def)

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

!(updateAttentionParam MAX_AF_SIZE 20.0)
!(updateAttentionParam TARGET_STI 10000.0) 
!(updateAttentionParam TARGET_LTI 10000.0) 
!(updateAttentionParam STI_FUNDS_BUFFER 1000.0) 
!(updateAttentionParam LTI_FUNDS_BUFFER 1000.0) 
!(updateAttentionParam FUNDS_STI 20000.0) 
!(updateAttentionParam FUNDS_LTI 20000.0) 

!(updateAttentionParam AFRentFrequency 9.0)

!(getAfAtoms)


; !(stimulate 1 50)

!(getAfAtoms)
!(size-atom (getAfAtoms))


(= (testDynamicity $number) 
    (if (== $number 0) ()

(let* (

    ($stimulate (stimulate $number 50))
    ($sti (getSti $number))
    ($size (size-atom (getAfAtoms)))
    ($num (- $number 1))
    ($fund (getAttentionParam FUNDS_STI))
    ($atom (println! (af size $size stimulated atom is $number with sti $sti)))

    ; ($rent (println! (amount of rent collected )))
    ($f (println! (total fund $fund)))

    ($agents (collapse (test-superpose &incident)))

   )

   (testDynamicity $num)

)))

!(testDynamicity 15)

!(size-atom (getAfAtoms))



