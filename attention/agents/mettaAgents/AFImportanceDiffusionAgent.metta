!("AFImportanceDiffusionAgent.metta")
! ((py-atom time.sleep) 1)
!("AFImportanceDiffusionAgent.metta")

(x 1)

(= (adder $x)
    (add-atom &self (x (+ $x 1)))
)

;This is for testing the state of the space if atom got stimulated multiple times
!(adder 1)
!(match &self (x $num) $num)
