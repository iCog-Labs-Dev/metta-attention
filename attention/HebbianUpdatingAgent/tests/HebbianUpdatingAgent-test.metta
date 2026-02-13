; !(register-module! ../../../../metta-attention)
; !(import! &self metta-attention:attention-bank:utilities:helper-functions)
; !(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
; !(import! &self metta-attention:attention-bank:bank:attention-bank)
; !(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
; !(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
; !(import! &self metta-attention:attention-bank:utilities:recentVal)
; !(import! &self metta-attention:attention:HebbianUpdatingAgent:HebbianUpdatingAgent)
; !(import! &self metta-attention:attention:AttentionParam)


!(import! &self ../../../../PeTTa/lib/lib_he)
!(import! &self ../../../../metta-attention/attention/AttentionParam)
!(import! &self ../../../../metta-attention/attention-bank/utilities/helper-functions)
!(import! &self ../../../../metta-attention/attention-bank/attention-value/getter-and-setter)
!(import! &self ../../../../metta-attention/attention-bank/utilities/recentVal)
!(import! &self ../../../../metta-attention/attention-bank/bank/attention-bank)
!(import! &self ../../../../metta-attention/attention-bank/bank/attentional-focus/attentional-focus)
!(import! &self ../../../../metta-attention/attention-bank/bank/importance-index/importance-index)
!(import! &self ../../../../metta-attention/attention/Neighbors)
!(import! &self ../../../../metta-attention/attention/HebbianUpdatingAgent/HebbianUpdatingAgent)


;################ Prep: giving atoms mean and confidence ####################
!(setStv source (0.1 0.9))
!(setStv target1 (0.1 0.9))
!(setStv target2 (0.1 0.9))
!(setStv target3 (0.1 0.9))
!(setStv target4 (0.1 0.9))

;################ Prep: setting up Hebbian link between atoms ####################
!(setStv (ASYMMETRIC_HEBBIAN_LINK source target1) (0.01 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK source target2) (0.01 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK source target3) (0.01 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK source target4) (0.01 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK target1 source) (0.01 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK target2 source) (0.01 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK target3 source) (0.01 0.9))
!(setStv (ASYMMETRIC_HEBBIAN_LINK target4 source) (0.01 0.9))

;################ Prep: stimulating atoms to add them into AF ####################
!(stimulate source 50)
!(stimulate target1 100)
!(stimulate target2 150)
!(stimulate target3 200)
!(stimulate target4 250)

;######################## test for utility functions ##################
!(test (targetConjunction (source target2)) 0.625)
!(test (mergeCalculation (0.7 0.8) (0.4 0.6) PLN_BOOK_REVISION) (0.6181818181818182 0.8387096774193549))
!(test (higherConfidenceMerge (0.7 0.8) (0.4 0.9)) (0.4 0.9))
!(test (mergeCalculation (0.7 0.8) (0.4 0.6) HIGHER_CONFIDENCE) (0.7 0.8))
!(test (getAllIncomingSetsForHUAgent target1 (TypeSpace) ASYMMETRIC_HEBBIAN_LINK) (ASYMMETRIC_HEBBIAN_LINK target1 source))

;################ Running the HebbianUpdatingAgent with source as parameter ####################
!(updateHebbianLinks source (TypeSpace))

;################ The weights should be updated ####################
; Forward links
!(test 
  (if (>= (getMean (ASYMMETRIC_HEBBIAN_LINK source target1)) 0.010635670731707318)
      True
      False)
  True)

!(test 
  (if (>= (getMean (ASYMMETRIC_HEBBIAN_LINK source target2)) 0.01075)      
      True
      False)
  True)

!(test 
  (if (>= (getMean (ASYMMETRIC_HEBBIAN_LINK source target3)) 0.010940548780487804)
           
      True
      False)
  True)

!(test 
  (if (>= (getMean (ASYMMETRIC_HEBBIAN_LINK source target4)) 0.01120731707317073)
      True
      False)
  True)

; Reverse links
!(test 
  (if (>= (getMean (ASYMMETRIC_HEBBIAN_LINK target1 source)) 0.01)
      True
      False)
  True)

!(test 
  (if (>= (getMean (ASYMMETRIC_HEBBIAN_LINK target2 source)) 0.01) 
      True
      False)
  True)

!(test 
  (if (>= (getMean (ASYMMETRIC_HEBBIAN_LINK target3 source)) 0.01)
      True
      False)
  True)

!(test 
  (if (>= (getMean (ASYMMETRIC_HEBBIAN_LINK target4 source)) 0.01)
      True
      False)
  True)
