!(bind! &incident (new-space))

!(add-atom &self (InSynset relational relational.s.01))
!(add-atom &self (InSynset relational relational.s.02))
!(add-atom &self (Synset absorbent.a.01))
!(add-atom &self (InSynset absorbent absorbent.a.01))
!(add-atom &self (InSynset absorptive absorbent.a.01))
!(add-atom &self (Synset absorbefacient.s.01))
!(add-atom &self (InSynset absorbefacient absorbefacient.s.01))
!(add-atom &self (InSynset sorbefacient absorbefacient.s.01))
!(add-atom &self (Synset assimilating.s.01))
!(add-atom &self (InSynset assimilating assimilating.s.01))
!(add-atom &self (InSynset assimilative assimilating.s.01))
!(add-atom &self (InSynset assimilatory assimilating.s.01))



(= (indexIncidentLinks $space)
    ; (superpose
    ;     (
    ;         (match $space ((InSynset $a $b) $v)
    ;             (add-atom &incident (incident $a $b))
    ;         )

    ;         (match $space ((InSynset $a $b) $v)
    ;             (add-atom &incident (incident $b $a))
    ;         )

    ;         (match $space ((isa $a $b) $v)
    ;             (add-atom &incident (incident $a (isa $a $b)))
    ;         )

    ;         (match $space ((isa $a $b) $v)
    ;             (add-atom &incident (incident $b (isa $a $b)))
    ;         )
    ;     )
    ; )
    (let $atom 
        (match $space ($link $atom $x) $atom)
        (collapse ($atom 
            (superpose
        (
            (match $space ($type $atom $x) ($type $atom $x))
            (match $space ($type $x $atom) ($type $x $atom))
        )

    )
        ))
    )
)


!(indexIncidentLinks &self)
