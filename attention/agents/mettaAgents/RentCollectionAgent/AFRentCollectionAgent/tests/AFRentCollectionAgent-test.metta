!(register-module! ../../../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention:agents:mettaAgents:AttentionParam)
!(import! &self metta-attention:attention:agents:mettaAgents:RentCollectionAgent:RentCollectionBaseAgent:RentCollectionBaseAgent)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention:agents:mettaAgents:RentCollectionAgent:AFRentCollectionAgent:AFRentCollectionAgent)

;;inorder to see the rent collection in action,we have to decrease the size of the attentional focus 
;;run it with cognitive controller because it depends on time passed since last rent collected
;;i have tested with that and it works fine
!(setAv b (100.0 100.0 0.0))
!(setAv c (200.0 200.0 0.0))
!(setAv d (300.0 300.0 0.0))
!(setAv (Hebbianlink a b) (400.0 400.0 0.0))
!(setAv (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)) (400.0 400.0 0.0))
;; Get the rent frequency and compute the sleep duration


;; Run rent collection in a loop until enough time has passed
!(AFRentCollectionAgent-run)

;; Sleep for the computed time to match C++ behavior
! ((py-atom time.sleep) (/ 1.0 5.0))
!(AFRentCollectionAgent-run)
!(assertEqual (< (getSTI (Hebbianlink (Hebbianlink c d) (Hebbianlink c b))) 400.0) True)
!(assertEqual (< (getSTI b)100.0) True)
!(assertEqual (< (getSTI c) 200.0) True)
!(assertEqual (< (getSTI d)300.0) True)
!(assertEqual (< (getLTI (Hebbianlink (Hebbianlink c d) (Hebbianlink c b))) 400.0) True)
!(assertEqual (< (getLTI b)100.0) True)
!(assertEqual (< (getLTI c) 200.0) True)
!(assertEqual (< (getLTI d)300.0) True)







