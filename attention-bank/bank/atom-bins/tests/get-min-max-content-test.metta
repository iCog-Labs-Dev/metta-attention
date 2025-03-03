!(register-module! ../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:bank:atom-bins:get-min-max-content)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)

;################### Prep: insert atoms to the atomBin ########################
!(add-atom &atombin (1 (a Cat)))
!(add-atom &atombin (2 (d)))
!(add-atom &atombin (3 (c Human)))
!(add-atom &atombin (17 (s c)))
!(add-atom &atombin (18 (g j (Hebbianlink (Hebbianlink Human Cat) Animal))))
!(add-atom &atombin (37 (f h j k (EvaluationLink a b))))

;################# Testing ##################################

; Test case 01: Testing getMaxContent asserting it returns bin with least bin index
! (assertEqual (getMaxContent) (f h j k (EvaluationLink a b)))

; Test case 02: Testing getMinContent asserting it returns bin with greatest bin index
! (assertEqual (getMinContent) (a Cat))

; Test case 03: Testing getMinContent asserting it changes with inserAtom function
! (setAv d (1.0 2.0 0.0))
! (insertAtom 1 d)
! (assertEqual (getMinContent) (d a Cat))

; Test case 04: Testing getSize asserting it returns number of atoms in bin
! (assertEqual (getSize 1) 3)
! (assertEqual (getSize 17) 2)
! (assertEqual (getSize 37) 5)

; Test case 05: Testing binSize asserting it returns the total number of atoms in atombins
! (assertEqual (binSize) 16)

; Test case 07: Testing binSize asserting it returns a differnet numbe after removeAtom
! (removeAtom 1 d)
! (assertEqual (binSize) 15)
