!(register-module! ../../../../metta-attention)
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
!(import! &self metta-attention:experiments:logger)

!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:utilities:recentVal)

!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)

!(import! &self metta-attention:attention-bank:bank:atom-bins:get-min-max-content)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &self metta-attention:attention-bank:bank:stochastic-importance-diffusion:stochastic-importance-diffusion)
!(import! &tempspace metta-attention:experiments:Metta:experiment2:data:sent-kb)
!(import! &insect metta-attention:experiments:Metta:experiment2:data:insect-sent)
!(import! &poison metta-attention:experiments:Metta:experiment2:data:poison-sent)

!(updateAttentionParam STI_FUNDS_BUFFER 99900)
!(updateAttentionParam LTI_FUNDS_BUFFER 99900)
!(updateAttentionParam TARGET_STI 99900)
!(updateAttentionParam TARGET_LTI 99900)
!(updateAttentionParam AFRentFrequency 2.0)
!(updateAttentionParam MAX_AF_SIZE 12)
(=(spaceAdder) (get-atoms &tempspace)) 
!(spaceAdder)

; write the params to a file
!(start_log (attentionParam) experiments/Metta/experiment2)

(= (insectPoisonReadExp $space $type $expr)
    (
        (if (and (== $type poisonSent) (== $expr ()))
            finished
            (let* 
                (
                    ($now (car-atom $expr))
                    ($rest (cdr-atom $expr))
                    
                )
                (
                    (stimulate $now 700)
                    (println! $now)
                    (collapse (test-superpose))
                    (if (== $rest ())
                            (if (== $type insectSent)
                                (insectPoisonReadExp &poison poisonSent (match &poison (poisonSent $x) $x))
                                finished
                    )
                 
                 (insectPoisonReadExp $space $type $rest)
             )
                    
                )
            )
        )     
    )
)

!(insectPoisonReadExp &insect insectSent (match &insect (insectSent $x) $x))
!(getAtomList)
!(get-atoms (TypeSpace))
