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
!(import! &tempspace metta-attention:experiments:Metta:experiment1:data:links)
!(import! &insect metta-attention:experiments:Metta:experiment1:data:insect-words)
!(import! &poison metta-attention:experiments:Metta:experiment1:data:poison-words)

(=(spaceAdder) (get-atoms &tempspace))
!(spaceAdder)

; write the params to a file
!(start_log (attentionParam) (space) experiments/Metta/experiment1)

(= (insectPoisonExp $maxim $space $type)
   (
     (if (< $maxim 0)
         finished
           (let* (
             ($words (collapse (match $space ($type $x) $x)))
             ($randInt1 (random-int 0 (size-atom $words)))
             ($randInt2 (random-int 0 (size-atom $words)))
             ($randomWord1 (index-atom $words $randInt1))
           )
           (
                (stimulate $randomWord1 10)
                (println! $randomWord1)
                (collapse(test-superpose))
                (let $newMaxim (- $maxim 1)
                    (if (> $maxim 2)
                         (insectPoisonExp $newMaxim  &insect insect)
                         (insectPoisonExp $newMaxim  &poison poison)
                    )
                )
           )
           )
      )    
    )
)


!(insectPoisonExp 3 &insect insect)
!(getAtomList)
!(get-atoms (TypeSpace))
