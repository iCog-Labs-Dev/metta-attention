!(register-module! ../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:utilities:recentVal)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:bank:attention-bank)


;For Testing the update, getMaxSTI, getMinSTI
###################### Prep: adding atoms to the atom bin #####################
!(setAv a (2.0 2.0 2.0))
!(setAv d (4.0 2.0 2.0))
!(setAv c (3.0 2.0 2.0))
!(setAv x (200.0 200.0 0.0))

!(add-atom &atombin (1 (a)))
!(add-atom &atombin (10 (d)))
!(add-atom &atombin (18 (c)))

########################### Testing ###########################################

; Test case 01: Testing importanceBin with different number values

!(assertEqual (importanceBin -5.0)  0)    ; Should return 0
!(assertEqual (importanceBin 10.0)   10)   ; Should return 10 (direct assignment)
!(assertEqual (importanceBin 20.0)  18)    ; Should calculate based on group logic 18
!(assertEqual (importanceBin 50.0)  29)    ; Should calculate based on group logic 29


; Test case 02: Testing getHandleSet with lowerbound and upperbound

!(assertEqual (getHandleSet 1 20) (d c a))
!(assertEqual (getHandleSet 10 10) ())
!(assertEqual (getHandleSet 0 -1.0) ())

; Test case 03: Testing update function
!(assertEqual (update &atombin) ("Updated"))
!(assertEqual (getMaxSTI) 2.0)
!(assertEqual (getMinSTI) 1.0)


; Test cases 04: Testing stimulate that need to be refactored

!(stimulate x 1.5)

; Test case 05: Testing updateImportance updates the importance of an atom

! (assertEqual (updateImportance &atombin a 1 20) ("Importance Updated"))
!(assertEqual (getContent 1 (collapseAtomBin &atombin) ()) ())


; Test case 06: Testing getNormalisedZeroToOneSTI with different average and clip values both on and off

!(assertEqual (getNormalisedZeroToOneSTI a True True) 1.0)
!(assertEqual (getNormalisedZeroToOneSTI d True False) 3.0)
!(assertEqual (getNormalisedZeroToOneSTI c  False False) 0.5)


; Test case 07: Testing getNormalisedSTI 

!(assertEqual(getNormalisedSTI a) 2.0)
!(assertEqual (getNormalisedSTI x) 230.0)


; Test case 08: Testing getNormalisedSTI with different average and clip values

!(assertEqual (getNormalisedSTI a True True) -1.0)
!(assertEqual (getNormalisedSTI d True False) -1.0218340611353711)


