!(register-module! ../../../metta-attention)
!(import! &self metta-attention:attention:agents:mettaAgents:ForgettingAgent:ForgettingAgent)
!(import! &self metta-attention:attention:agents:mettaAgents:AttentionParam)
!(import! &self metta-attention:attention:agents:mettaAgents:RentCollectionAgent:RentCollectionBaseAgent:RentCollectionBaseAgent)
!(import! &self metta-attention:attention:agents:mettaAgents:RentCollectionAgent:WARentCollectionAgent:WARentCollectionAgent)
!(import! &self metta-attention:attention:agents:mettaAgents:RentCollectionAgent:AFRentCollectionAgent:AFRentCollectionAgent)
!(import! &self metta-attention:attention:agents:mettaAgents:ImportanceDiffusionAgent:ImportanceDiffusionBase:ImportanceDiffusionBase)
!(import! &self metta-attention:attention:agents:mettaAgents:ImportanceDiffusionAgent:WAImportanceDiffusionAgent:WAImportanceDiffusionAgent)
!(import! &self metta-attention:attention:agents:mettaAgents:ImportanceDiffusionAgent:AFImportanceDiffusionAgent:AFImportanceDiffusionAgent)
!(import! &self metta-attention:attention:agents:mettaAgents:HebbianUpdatingAgent:HebbianUpdatingAgent)
!(import! &self metta-attention:attention:agents:mettaAgents:HebbianCreationAgent:HebbianCreationAgent)
!(import! &self metta-attention:attention:agents:mettaAgents:AttentionParam)
!(import! &self metta-attention:attention:agents:mettaAgents:Neighbors)
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
!(import! &tempspace metta-attention:experiments:experiment2:data:sent-kb)
!(import! &insect metta-attention:experiments:experiment2:data:insect-sent)
!(import! &poison metta-attention:experiments:experiment2:data:poison-sent)
(collapse (match &insect (insect $x) $x))
(collapse (match &poison (poison $x) $x))
!(updateAttentionBank stiFundsBuffer 99900)
!(updateAttentionBank ltiFundsBuffer 99900)
!(updateAttentionBank targetSTI 99900)
!(updateAttentionBank targetLTI 99900)
!(updateAttentionParam MAX_AF_SIZE 8)
(=(spaceAdder) (get-atoms &tempspace)) 
!(spaceAdder)

; write the params to a file
!(let $vals (collapse (get-atoms &attentionParam)) (save_params $vals))

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
                    (collapse (write_csv_wrapper (attentionalFocus) outputFile.csv))
                    
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
