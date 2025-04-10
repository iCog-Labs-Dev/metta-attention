!(register-module! ../../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &self metta-attention:attention-bank:utilities:recentVal)
!(import! &self metta-attention:attention:agents:mettaAgents:HebbianUpdatingAgent:HebbianUpdatingAgent)
!(import! &self metta-attention:attention-bank:utilities:recentVal)

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

;################ Running the HebbianUpdatingAgent with source as parameter ####################
!(updateHebbianLinks source (TypeSpace))

;################ The weights should be updated ####################
; Forward links
!(assertEqual 
  (if (and (>= (getMean (ASYMMETRIC_HEBBIAN_LINK source target1)) 0.010664669700632868)
           (<= (getMean (ASYMMETRIC_HEBBIAN_LINK source target1)) 0.010664669700632868))
      True
      False)
  True)
! (getMean (ASYMMETRIC_HEBBIAN_LINK source target1))

!(assertEqual 
  (if (and (>= (getMean (ASYMMETRIC_HEBBIAN_LINK source target2)) 0.010861742058695056)
           (<= (getMean (ASYMMETRIC_HEBBIAN_LINK source target2)) 0.010861742058695056))
      True
      False)
  True)
! (getMean (ASYMMETRIC_HEBBIAN_LINK source target2))
!(assertEqual 
  (if (and (>= (getMean (ASYMMETRIC_HEBBIAN_LINK source target3)) 0.011188841539602402)
           (<= (getMean (ASYMMETRIC_HEBBIAN_LINK source target3)) 0.011188841539602402))
      True
      False)
  True)
! (getMean (ASYMMETRIC_HEBBIAN_LINK source target3))
!(assertEqual 
  (if (and (>= (getMean (ASYMMETRIC_HEBBIAN_LINK source target4)) 0.011201158561981287)
           (<= (getMean (ASYMMETRIC_HEBBIAN_LINK source target4)) 0.011201158561981287))
      True
      False)
  True)
! (getMean (ASYMMETRIC_HEBBIAN_LINK source target4))
; Reverse links
!(assertEqual 
  (if (and (>= (getMean (ASYMMETRIC_HEBBIAN_LINK target1 source)) 0.01)
           (<= (getMean (ASYMMETRIC_HEBBIAN_LINK target1 source)) 0.01))
      True
      False)
  True)
! (getMean (ASYMMETRIC_HEBBIAN_LINK target1 source))
!(assertEqual 
  (if (and (>= (getMean (ASYMMETRIC_HEBBIAN_LINK target2 source)) 0.01)
           (<= (getMean (ASYMMETRIC_HEBBIAN_LINK target2 source)) 0.01))
      True
      False)
  True)
! (getMean (ASYMMETRIC_HEBBIAN_LINK target2 source))
!(assertEqual 
  (if (and (>= (getMean (ASYMMETRIC_HEBBIAN_LINK target3 source)) 0.01)
           (<= (getMean (ASYMMETRIC_HEBBIAN_LINK target3 source)) 0.01))
      True
      False)
  True)
! (getMean (ASYMMETRIC_HEBBIAN_LINK target3 source))
!(assertEqual 
  (if (and (>= (getMean (ASYMMETRIC_HEBBIAN_LINK target4 source)) 0.01)
           (<= (getMean (ASYMMETRIC_HEBBIAN_LINK target4 source)) 0.01))
      True
      False)
  True)
! (getMean (ASYMMETRIC_HEBBIAN_LINK target4 source))