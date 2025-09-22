!(register-module! ../../../../../metta-attention)
!(import! &self metta-attention:attention:AttentionParam) 
!(import! &self metta-attention:attention-bank:bank:atom-bins:get-min-max-content)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:attention-value:get-min-max)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)

; Test Case 01: Testing Empty atomBin
; Ensure getMaxContent and getMinContent return empty lists when no atoms are present
 ;!(assertEqual (getMaxContent) ())
 ;!(assertEqual (getMinContent) ())

; Test Case 02: getSize for a Non-Existent Bin
; Ensure getSize returns 0 for bins that don't exist
!(assertEqual (binSize) 0)

; Setup: setAv values to atoms
!(setAv Human (100.0 100.0 1.0))
!(setAv Dog (200.0 200.0 1.0))
!(setAv Cat (300.0 300.0 1.0))
!(setAv Animal (400.0 400.0 1.0))
!(setAv Mother (500.0 500.0 1.0))

; Test Case 03: Testing getMaxContent and getMinContent with Initial Data
; Ensure they return correct values when bins are populated
; Expected: Max bin (50) = Mother, Min bin (1) = Human
!(assertEqual (getMaxContent) (Mother))
!(assertEqual (getMinContent) (Human))

; SetUp: setAv values to atoms
!(setAv (EvaluationLink Dog Cat) (110.0 110.0 1.0))
!(setAv (Hebbianlink (Hebbianlink Human Cat) Animal) (120.0 120.0 1.0))
!(setAv (Hebbianlink (Hebbianlink Animal Human) (Hebbianlink Animal Mother)) (1130.0 1130.0 1.0))

; Test Case 04: Adding Atom to Max Bin

; Expected: Max bin to be 90 =  (Hebbianlink (Hebbianlink Animal Human) (Hebbianlink Animal Mother))

!(assertEqual (getMaxContent) (collapse (Hebbianlink (Hebbianlink Animal Human) (Hebbianlink Animal Mother))))

; Test Case 05: getMinContent for Multiple Min Bins
!(setAv Father (100.0 100.0 1.0))

;Test with Symbol Atom Type
!(let $content
    (getMinContent) 
    (subtraction-atom 
        $content
        (Human Father)
    )
)

; Test Case 06: Testing getSize Function
; Ensure getSize returns correct atom count in bins
; Expected: Bin 1 has 3 atoms, Bin 2 has 2 atoms, Bin 50 has 1 atoms, Bin 90 has 1 atom
!(setAv Humaner (220.0 220.0 1.0))
!(setAv Doger (220.0 220.0 1.0))

!(assertEqual (getSize 39) 1)
!(assertEqual (getSize 46) 2)
!(assertEqual (getSize 50) 1)
!(assertEqual (getSize 53) 1)

; Test Case 07: Testing binSize Function
; Ensure binSize correctly returns the total number of atoms across all bins
; Expected: Total atoms = 11
!(assertEqual (binSize) 11)

; Test Case 08: Testing sumSizes Function
; Ensure sumSizes correctly sums atoms in specified bins
; Expected: sumSizes(1 2) should return 5, sumSizes(70 60 90) should return 3
!(assertEqual (sumSizes (50 53)) 2)
!(assertEqual (sumSizes (46 60 90)) 2)

