!(bind! &incident (new-space))

!(add-atom &incident (InSynset relational relational.s.01))
!(add-atom &incident (InSynset relational relational.s.02))
!(add-atom &incident (InSynset relational.s.03 relational))
!(add-atom &incident (InSynset relational.s.02 relational))
!(add-atom &incident (Synset absorbent.a.01))
!(add-atom &incident (InSynset absorbent absorbent.a.01))
!(add-atom &incident (InSynset absorptive absorbent.a.01))
!(add-atom &incident (Synset absorbefacient.s.01))
!(add-atom &incident (InSynset absorbefacient absorbefacient.s.01))
!(add-atom &incident (InSynset sorbefacient absorbefacient.s.01))
!(add-atom &incident (Synset assimilating.s.01))
!(add-atom &incident (InSynset assimilating assimilating.s.01))
!(add-atom &incident (InSynset assimilative assimilating.s.01))
!(add-atom &incident (InSynset assimilatory assimilating.s.01))



(= (indexIncidentLinks $space)
   (let* 
    (
        ; ($in (let $atom (match $space ($link $atom $x) $atom)
        ;             (($atom (match $space ($type $atom $x) ($type $atom $x))
        ;             )))
        ; )
        ($out (let $atom2 (match $space ($link2 $x2 $atom2) $atom2)
                    (($atom2 (match $space ($type2 $x2 $atom2) ($type2 $x2 $atom2))
                    )))
        )
   )
   $out

) 
    
)


(= (indexIncidentLinks2 $space)
   (let* 
    (
        ($in (let $atom (match $space ($link $atom $x) $atom)
                    (($atom (match $space ($type $atom $x) ($type $atom $x))
                    )))
        )
    
   )
   $in

) 
    
)


!(indexIncidentLinks &incident)
!(hello)
!(indexIncidentLinks2 &incident)
