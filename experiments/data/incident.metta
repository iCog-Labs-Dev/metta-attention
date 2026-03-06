!(bind! &incident (new-space))
!(bind! &result (new-space))


!(add-atom &incident ((InSynset relational relational.s.01)(0.3 0.5)))
!(add-atom &incident ((InSynset relational relational.s.02)(0.3 0.5)))
!(add-atom &incident ((InSynset relational.s.03 relational)(0.3 0.5)))
!(add-atom &incident ((InSynset relational.s.02 relational)(0.3 0.5)))
!(add-atom &incident ((Synset absorbent.a.01)(0.3 0.5)))
!(add-atom &incident ((InSynset absorbent absorbent.a.01)(0.3 0.5)))
!(add-atom &incident ((InSynset absorptive absorbent.a.01)(0.3 0.5)))
!(add-atom &incident ((Synset absorbefacient.s.01)(0.3 0.5)))
!(add-atom &incident ((InSynset absorbefacient absorbefacient.s.01)(0.3 0.5)))
!(add-atom &incident ((InSynset sorbefacient absorbefacient.s.01)(0.3 0.5)))
!(add-atom &incident ((Synset assimilating.s.01)(0.3 0.5)))
!(add-atom &incident ((InSynset assimilating assimilating.s.01)(0.3 0.5)))
!(add-atom &incident ((InSynset assimilative assimilating.s.01)(0.3 0.5)))
!(add-atom &incident ((InSynset assimilatory assimilating.s.01)(0.3 0.5)))

!(import! &self lib/lib_import)
!(import! &self lib/lib_spaces)
!(static-import! &wordnet wordnet_stv_clean)


(= (indexIncidentLinks $space)
   (let* 
    (
        ($out (let $atom2 (match $space ((insynset $x2 $atom2) $val) $atom2)
                    (($atom2 (match $space ((insynset $x2 $atom2) $val) ((insynset $x2 $atom2) $val))
                    )))
        )
   )
    $out
))


(= (indexIncidentLinks2 $space)
   (let* 
    (
        ($in (let $atom (match $space ((insynset $atom $x) $val) $atom)
                    (($atom (match $space ((insynset $atom $x) $val) ((insynset $atom $x) $val))
                    )))
        )
    
   )
   $in

))


; !(add-atom &result ((relational.s.01 ((InSynset relational relational.s.01) (0.3 0.5)))))
; !(add-atom &result ((relational.s.02 ((InSynset relational relational.s.02) (0.3 0.5)))))
; !(add-atom &result ((relational ((InSynset relational.s.03 relational) (0.3 0.5)))))
; !(add-atom &result ((relational ((InSynset relational.s.02 relational) (0.3 0.5)))))
; !(add-atom &result ((absorbent.a.01 ((InSynset absorbent absorbent.a.01) (0.3 0.5)))))
; !(add-atom &result ((absorbent.a.01 ((InSynset absorptive absorbent.a.01) (0.3 0.5)))))
; !(add-atom &result ((absorbefacient.s.01 ((InSynset absorbefacient absorbefacient.s.01) (0.3 0.5)))))
; !(add-atom &result ((absorbefacient.s.01 ((InSynset sorbefacient absorbefacient.s.01) (0.3 0.5)))))
; !(add-atom &result ((assimilating.s.01 ((InSynset assimilating assimilating.s.01) (0.3 0.5)))))
; !(add-atom &result ((assimilating.s.01 ((InSynset assimilative assimilating.s.01) (0.3 0.5)))))
; !(add-atom &result ((assimilating.s.01 ((InSynset assimilatory assimilating.s.01) (0.3 0.5)))))
; !(add-atom &result ((relational ((InSynset relational relational.s.01) (0.3 0.5)))))
; !(add-atom &result ((relational ((InSynset relational relational.s.02) (0.3 0.5)))))
; !(add-atom &result ((relational.s.03 ((InSynset relational.s.03 relational) (0.3 0.5)))))
; !(add-atom &result ((relational.s.02 ((InSynset relational.s.02 relational) (0.3 0.5)))))
; !(add-atom &result ((absorbent ((InSynset absorbent absorbent.a.01) (0.3 0.5)))))
; !(add-atom &result ((absorptive ((InSynset absorptive absorbent.a.01) (0.3 0.5)))))
; !(add-atom &result ((absorbefacient ((InSynset absorbefacient absorbefacient.s.01) (0.3 0.5)))))
; !(add-atom &result ((sorbefacient ((InSynset sorbefacient absorbefacient.s.01) (0.3 0.5)))))
; !(add-atom &result ((assimilating ((InSynset assimilating assimilating.s.01) (0.3 0.5)))))
; !(add-atom &result ((assimilative ((InSynset assimilative assimilating.s.01) (0.3 0.5)))))
; !(add-atom &result ((assimilatory ((InSynset assimilatory assimilating.s.01) (0.3 0.5)))))



; (= (findincident $space) 
;     (let* 
;     (
;         ($in (collapse (match &result $atoms $atoms)))
;         ($atoms (collapse (car-atom (superpose $in))))
;         ($atom  (unique-atom (collapse (car-atom (superpose $atoms)))))
;         ($find  (superpose $atom))
;         ($incident (collapse (match &result (($find ($links $val))) $links) ))

    
;    )
;    ($find $incident)
; ))


; !(findincident &result)



!(indexIncidentLinks &wordnet)
; !(indexIncidentLinks2 &incident)
!(hello)
