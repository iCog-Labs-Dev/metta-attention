(= (filterNodesByType $space $type)
   (match $space (: $node (Node $type $symbol $av $stv)) (Node $type $symbol $av $stv))
)

(= (filterLinksByType $space $type)
   (match $space (: $link (Link $type $source $target $av $stv)) (Link $type $source $target $av $stv))
)
