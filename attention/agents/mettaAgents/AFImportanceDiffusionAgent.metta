!(import! &self attention:agents:mettaAgents:adderUtil)
!("AFImportanceDiffusionAgent.metta")
! ((py-atom time.sleep) 1)

;This is for testing the state of the space if atom got stimulated multiple times
!(adder 1)
!(match &adder (x $num) $num)
