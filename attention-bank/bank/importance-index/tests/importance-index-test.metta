!(register-module! ../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &test-kb metta-attention:attention-bank:bank:importance-index:tests:test-kb)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:utilities:recentVal)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:bank:attention-bank)

;For Testing the update, getMaxSTI, getMinSTI
!(add-atom &atombin (1 (node_a)))
!(add-atom &atombin (10 (node_d)))
!(add-atom &atombin (18 (node_c)))

!(assertEqual (getHandleSet 1 20 &test-kb) (node_c node_d node_a ))
!(assertEqual (getHandleSet 10 10 &test-kb) ())

; Test importanceBin function
!(assertEqual (importanceBin -5)  0)    ; Should return 0
!(assertEqual (importanceBin 10)   10)   ; Should return 10 (direct assignment)
!(assertEqual (importanceBin 20)  18)    ; Should calculate based on group logic 18
!(assertEqual (importanceBin 50)  29)    ; Should calculate based on group logic 29

!(assertEqual (update &test-kb) ("Updated"))
!(assertEqual (getMaxSTI) 2.0)
!(assertEqual (getMinSTI) 1.0)

!(setAV &test-kb node_x (200.0 200.0 200.0))
!(stimulate node_x 1.5 &test-kb)
!(getAfMaxSTI &test-kb)
!(assertEqual (updateImportance node_a 1 20 &test-kb) ("Importance Updated"))
!(assertEqual (getContent 1 () ()) ())
!(assertEqual (getNormalisedZeroToOneSTI node_a True True &test-kb) 1.0)
!(assertEqual (getNormalisedZeroToOneSTI node_d True False &test-kb) 3.0)
!(assertEqual (getNormalisedZeroToOneSTI node_c  False False &test-kb) 0.5)
!(assertEqual(getNormalisedSTI node_a &test-kb) 2.0)

!(assertEqual (getNormalisedSTI node_x &test-kb) 230.0)
!(assertEqual (getNormalisedSTI node_a True True &test-kb) -1.0)
!(assertEqual (getNormalisedSTI node_d True False &test-kb) -1.0218340611353711)
