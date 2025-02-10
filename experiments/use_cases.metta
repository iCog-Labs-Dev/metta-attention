!(bind! &depTypes (dT))

(= (filterNodesByType $type)
   (match &depTypes (: $node (Node $type $symbol $av $stv)) (Node $type $symbol $av $stv))
)

(= (filterLinksByType $type)
   (match &depTypes (: $link (Link $type $source $target $av $stv)) (Link $type $source $target $av $stv))
)
