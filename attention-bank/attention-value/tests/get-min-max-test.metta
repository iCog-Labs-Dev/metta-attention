!(register-module! ../../../../metta-attention)
!(import! &self metta-attention:attention:AttentionParam)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:attention-value:get-min-max)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:bank:attention-bank)

; Test Case 01: Testing Empty atomBin
; Ensure getMaxContent and getMinContent return empty lists when no atoms are present
 !(assertEqual (getMaxContent (TypeSpace)) ())
 !(assertEqual (getMinContent (TypeSpace)) ())
; Test Case 02: getSize for a Non-Existent Bin
; Ensure getSize returns 0 for bins that don't exist
!(assertEqual (binSize) 0)
!(assertEqual (getSize 20) 0)
; ; Setup: setAv values to atoms
!(setAv Human (100.0 100.0 1.0))
!(setAv Dog (200.0 200.0 1.0))
!(setAv Cat (300.0 300.0 1.0))
!(setAv Animal (400.0 400.0 1.0))
!(setAv Mother (500.0 500.0 1.0))


; Test Case 03: Testing getMaxContent and getMinContent with Initial Data
; Ensure they return correct values when bins are populated
; Since Mother and Human has highest and lowest sti, they should have highest and lowest bin respectively.
!(assertEqual (getMaxContent (TypeSpace)) (Mother))
!(assertEqual (getMinContent (TypeSpace)) (Human))

; SetUp: setAv values to atoms
!(setAv (EvaluationLink Dog Cat) (110.0 110.0 1.0)) ;getBin == 38.0
!(setAv (Hebbianlink (Hebbianlink Human Cat) Animal) (120.0 120.0 1.0)) ; getBin == 39.0
!(setAv (Hebbianlink (Hebbianlink Animal Human) (Hebbianlink Animal Mother)) (1030.0 130.0 1.0)) ; getBin == 65.0


 ; Test Case 04: Adding Atom to Max Bin

 ; Expected: Max bin = (Hebbianlink (Hebbianlink Animal Human) (Hebbianlink Animal Mother))
!(assertEqual (getMaxContent (TypeSpace)) (collapse (Hebbianlink (Hebbianlink Animal Human) (Hebbianlink Animal Mother))))

; Test Case 05: getMinContent for Multiple Min Bins
; Insert another atom with close sti and ensure both "Human" and "Father" are returned
; Father and Human will have the same Bin since they have close sti
!(setAv Father (103.0 210.0 1.0)) ; 
;!(getBin Father) ;[37.0]

;Test with Symbol Atom Type
; there may be reversed sequence due to non-deterministic-computation
!(let $content
    (getMinContent (TypeSpace))
    (assertEqual 
        (subtraction-atom 
            $content
            (Human Father)
        )
        ()
    )
)

; Test Case 06: Testing getSize Function
; Ensure getSize returns correct atom count in bins
; Expected: Bin 38 has 3 atoms, Bin 45 has 2 atoms, Bin 56 has 1 atoms, Bin 65 has 1 atom
!(setAv Humaner (104.0 220.0 1.0))
!(setAv Doger (201.0 230.0 1.0))
!(assertEqual (getSize 37.0) 3)
!(assertEqual (getSize 45.0) 2)
!(assertEqual (getSize 56.0) 1)
!(assertEqual (getSize 65.0) 1)

; Test Case 07: Testing binSize Function
; Ensure binSize correctly returns the total number of atoms across all bins
; Expected: Total atoms = 11
!(assertEqual (binSize) 11)



