; MeTTa frontier candidates for Mettaclaw.
; Native port of goal_candidates.py -- computes EXPAND / BREAK candidates
; for the LLM goal-setting agent based on graph topology and optionally
; live Hebbian links from AtomSpace.

(= (goalCandidatesUseDynamic) False)
(= (goalCandidatesGroupSize) 5)
(= (goalCandidatesHebbianTopPercentile) 0.20)
(= (goalCandidatesHebbianMinWeight) 0.05)

(= (goalCandidatesToggle $value)
    (if (== $value False) False True))

; Sorting utilities

(= (goalCandidatesSortCompareLessEqBy $elem $pivot $fun)
   (<= ($fun $elem) ($fun $pivot)))

(= (goalCandidatesSortCompareGreaterBy $elem $pivot $fun)
   (> ($fun $elem) ($fun $pivot)))

(= (goalCandidatesSortBinaryFilter $f $pivot $tuple $fun)
   (if (== $tuple ()) ()
       (let*
           (($head (car-atom $tuple))
            ($tail (cdr-atom $tuple))
            ($isValid ($f $head $pivot $fun))
            ($filteredTail (goalCandidatesSortBinaryFilter $f $pivot $tail $fun)))
           (if $isValid
               (cons-atom $head $filteredTail)
               $filteredTail))))

; Quicksort descending by score
(= (goalCandidatesSortAtomsDescending $atoms $fun)
   (if (== $atoms ()) ()
       (let*
           (($pivot (car-atom $atoms))
            ($tail  (cdr-atom $atoms))
            ($greater (goalCandidatesSortAtomsDescending
                          (goalCandidatesSortBinaryFilter goalCandidatesSortCompareGreaterBy $pivot $tail $fun) $fun))
            ($lesser  (goalCandidatesSortAtomsDescending
                          (goalCandidatesSortBinaryFilter goalCandidatesSortCompareLessEqBy $pivot $tail $fun) $fun)))
           (goalCandidatesLocalConcatTuple $greater (cons-atom $pivot $lesser)))))

(= (goalCandidatesSortExpand $entries)
   (goalCandidatesSortAtomsDescending $entries goalCandidatesExpandScore))

(= (goalCandidatesSortBreak $entries)
   (goalCandidatesSortAtomsDescending $entries goalCandidatesBreakScore))

(= (goalCandidatesSortEdgeWeight $entries)
   (goalCandidatesSortAtomsDescending $entries goalCandidatesEdgeWeight))

(= (goalCandidatesSortExpandDyn $entries)
   (goalCandidatesSortAtomsDescending $entries goalCandidatesExpandDynScore))

(= (goalCandidatesSortBreakFallback $entries)
   (goalCandidatesSortAtomsDescending $entries goalCandidatesBreakFallbackScore))

; Ceiling function
(= (goalCandidatesCeil $x)
   (let $int_part (trunc-math $x)
      (if (== $x $int_part)
          $int_part
          (+ $int_part 1))))

; List utilities
(= (goalCandidatesLocalConcatTuple $xs $ys)
   (if (== $xs ()) $ys
       (let* (
           ($head (car-atom $xs))
           ($tail (cdr-atom $xs))
           ($tailNew (goalCandidatesLocalConcatTuple $tail $ys)))
       (cons-atom $head $tailNew))))

; Check if element is in list
(= (goalCandidatesLocalContains $list $elem)
   (if (== $list ()) False
       (if (== (car-atom $list) $elem) True
           (goalCandidatesLocalContains (cdr-atom $list) $elem))))

; Remove duplicate elements from list
(= (goalCandidatesLocalRemoveDuplicates $list)
   (if (== $list ()) ()
       (let* (
           ($head (car-atom $list))
           ($tail (cdr-atom $list))
           ($rest (goalCandidatesLocalRemoveDuplicates $tail)))
       (if (goalCandidatesLocalContains $rest $head)
           $rest
           (cons-atom $head $rest)))))

; Take first n elements from list
(= (goalCandidatesTake $n $list)
   (if (or (== $list ()) (<= $n 0))
       ()
       (cons-atom (car-atom $list)
                  (goalCandidatesTake (- $n 1) (cdr-atom $list)))))

; $graph is a MeTTa space (e.g. &graph) loaded via static-import!.
; match queries the space to get all atoms as edge lists.
(= (goalCandidatesEdges $graph)
   (collapse (match $graph ($edge $value) ($edge $value))))

(= (goalCandidatesEdgeSource $edge)
   (car-atom (cdr-atom (car-atom $edge))))

(= (goalCandidatesEdgeTarget $edge)
   (car-atom (cdr-atom (cdr-atom (car-atom $edge)))))

(= (goalCandidatesEdgeWeight $edge)
   (let* (
       ($val (car-atom (cdr-atom $edge)))
       ($mean (car-atom $val))
       ($conf (car-atom (cdr-atom $val)))
   )
   (* $mean $conf)))

; Extract all nodes from edge list
(= (goalCandidatesNodesFromEdges $edges)
   (if (== $edges ()) ()
       (goalCandidatesNodesFromEdgesAux
           (car-atom $edges)
           (cdr-atom $edges))))

(= (goalCandidatesNodesFromEdgesAux $head $tail)
   (goalCandidatesLocalRemoveDuplicates
       (cons-atom (goalCandidatesEdgeSource $head)
                  (cons-atom (goalCandidatesEdgeTarget $head)
                             (goalCandidatesNodesFromEdges $tail)))))

; Find neighbors of a node in edge list
(= (goalCandidatesNeighborsFromEdges $edges $node)
   (if (== $edges ()) ()
       (let* (
           ($head (car-atom $edges))
           ($tail (cdr-atom $edges))
           ($src (goalCandidatesEdgeSource $head))
           ($tgt (goalCandidatesEdgeTarget $head))
           ($rest (goalCandidatesNeighborsFromEdges $tail $node))
       )
       (if (== $src $node)
           (cons-atom $tgt $rest)
               (if (== $tgt $node)
               (cons-atom $src $rest)
               $rest)))))

; Count elements from list that are in set
(= (goalCandidatesCountInSet $list $set)
   (if (== $list ()) 0
       (let*
           (($head (car-atom $list))
            ($tail (cdr-atom $list))
            ($rest (goalCandidatesCountInSet $tail $set)))
            (if (goalCandidatesLocalContains $set $head)
               (+ 1 $rest)
               $rest))))

; FormatOneExpand
(= (goalCandidatesFormatOneExpand $entry)
   (if (== $entry ()) ""
       (let* (
           ($name (car-atom $entry))
           ($count (car-atom (cdr-atom $entry)))
       )
       (atom_concat (atom_concat (atom_concat $name ":") (atom_concat $count "af")) ""))))

; FormatExpand
(= (goalCandidatesFormatExpand $entries)
   (if (== $entries ()) "none"
       (let* (
           ($head (car-atom $entries))
           ($tail (cdr-atom $entries))
           ($headStr (goalCandidatesFormatOneExpand $head))
           ($restStr (goalCandidatesFormatExpand $tail))
       )
       (if (== $restStr "none")
           $headStr
           (atom_concat (atom_concat $headStr " ") $restStr)))))

; FormatOneBreak
(= (goalCandidatesFormatOneBreak $entry)
   (if (== $entry ()) ""
       (let* (
           ($name (car-atom $entry))
           ($degree (car-atom (cdr-atom $entry)))
       )
       (atom_concat (atom_concat (atom_concat $name ":d") $degree) ""))))

; FormatBreak
(= (goalCandidatesFormatBreak $entries)
   (if (== $entries ()) "none"
       (let* (
           ($head (car-atom $entries))
           ($tail (cdr-atom $entries))
           ($headStr (goalCandidatesFormatOneBreak $head))
           ($restStr (goalCandidatesFormatBreak $tail))
       )
       (if (== $restStr "none")
           $headStr
           (atom_concat (atom_concat $headStr " ") $restStr)))))

; FilterEntries
(= (goalCandidatesFilterEntries $list)
   (if (== $list ()) ()
       (let* (
           ($head (car-atom $list))
           ($tail (cdr-atom $list))
           ($rest (goalCandidatesFilterEntries $tail))
       )
       (if (== $head ())
           $rest
           (cons-atom $head $rest)))))

(= (goalCandidatesExpandScore ($name $afCount))
   (- 0 $afCount))

(= (goalCandidatesBreakScore ($name $degree))
   (- 0 $degree))

(= (goalCandidatesBreakFallbackScore ($name $afConn))
   (- 0 $afConn))

; FormatOneBreakFallback
(= (goalCandidatesFormatOneBreakFallback $entry)
   (if (== $entry ()) ""
       (let* (
           ($name (car-atom $entry))
           ($afConn (car-atom (cdr-atom $entry)))
       )
       (atom_concat (atom_concat (atom_concat $name ":c") $afConn) ""))))

; FormatBreakFallback
(= (goalCandidatesFormatBreakFallback $entries)
   (if (== $entries ()) "none"
       (let* (
           ($head (car-atom $entries))
           ($tail (cdr-atom $entries))
           ($headStr (goalCandidatesFormatOneBreakFallback $head))
           ($restStr (goalCandidatesFormatBreakFallback $tail))
       )
       (if (== $restStr "none")
           $headStr
           (atom_concat (atom_concat $headStr " ") $restStr)))))

; FindEdge
(= (goalCandidatesFindEdge $edges $src $tgt)
   (if (== $edges ()) ()
       (let* (
           ($head (car-atom $edges))
           ($tail (cdr-atom $edges))
           ($eSrc (goalCandidatesEdgeSource $head))
           ($eTgt (goalCandidatesEdgeTarget $head))
       )
       (if (or (and (== $eSrc $src) (== $eTgt $tgt))
               (and (== $eSrc $tgt) (== $eTgt $src)))
           $head
           (goalCandidatesFindEdge $tail $src $tgt)))))

(= (goalCandidatesExpandDynScore ($name $staticAf $hebbAf $score))
   (- 0 $score))

; FormatOneExpandDyn
(= (goalCandidatesFormatOneExpandDyn $entry)
   (if (== $entry ()) ""
       (let* (
           ($name (car-atom $entry))
           ($staticAf (car-atom (cdr-atom $entry)))
           ($hebbAf (car-atom (cdr-atom (cdr-atom $entry))))
       )
       (if (> $hebbAf 0)
           (atom_concat (atom_concat (atom_concat (atom_concat $name ":") (atom_concat $staticAf "af+")) (atom_concat $hebbAf "heb")) "")
           (atom_concat (atom_concat (atom_concat $name ":") (atom_concat $staticAf "af")) "")))))

; FormatExpandDyn
(= (goalCandidatesFormatExpandDyn $entries)
   (if (== $entries ()) "none"
       (let* (
           ($head (car-atom $entries))
           ($tail (cdr-atom $entries))
           ($headStr (goalCandidatesFormatOneExpandDyn $head))
           ($restStr (goalCandidatesFormatExpandDyn $tail))
       )
       (if (== $restStr "none")
           $headStr
           (atom_concat (atom_concat $headStr " ") $restStr)))))

; Join formatted expand and break strings
(= (goalCandidatesJoinStatic $expandStr $breakStr)
   (atom_concat (atom_concat "EXPAND(out-AF, adjacent) " $expandStr)
                (atom_concat " | BREAK(out-AF, distant) " $breakStr)))

(= (goalCandidatesJoinDynamic $expandStr $breakStr)
   (atom_concat (atom_concat "EXPAND(out-AF, dynamic-adj) " $expandStr)
                (atom_concat " | BREAK(out-AF, isolated) " $breakStr)))

; ---------------------------------------------------------------------------
; STATIC MODE
; ---------------------------------------------------------------------------

(= (goalCandidatesStaticExpandEntry $node $edges $af)
   (let* (
       ($neigh (goalCandidatesNeighborsFromEdges $edges $node))
       ($afNeigh (intersection-atom $af $neigh))
       ($count (size-atom $afNeigh))
   )
   (if (> $count 0)
       (cons-atom $node (cons-atom $count ()))
       ())))

(= (goalCandidatesStaticBreakEntry $node $edges $af)
   (let* (
       ($neigh (goalCandidatesNeighborsFromEdges $edges $node))
       ($afCount (goalCandidatesCountInSet $af $neigh))
       ($degree (size-atom $neigh))
   )
   (if (== $afCount 0)
       (cons-atom $node (cons-atom $degree ()))
       ())))

(= (goalCandidatesStaticExpandEntries $nodes $edges $af)
   (goalCandidatesFilterEntries (map-atom $nodes $node (goalCandidatesStaticExpandEntry $node $edges $af))))

(= (goalCandidatesStaticBreakEntries $nodes $edges $af)
   (goalCandidatesFilterEntries (map-atom $nodes $node (goalCandidatesStaticBreakEntry $node $edges $af))))

(= (goalCandidatesComputeExpandStr $size $outside $edges $af)
   (goalCandidatesFormatExpand
       (goalCandidatesTake $size
           (goalCandidatesSortExpand
               (goalCandidatesStaticExpandEntries $outside $edges $af)))))

(= (goalCandidatesComputeBreakStr $size $outside $edges $af)
   (goalCandidatesFormatBreak
       (goalCandidatesTake $size
           (goalCandidatesSortBreak
               (goalCandidatesStaticBreakEntries $outside $edges $af)))))

(= (goalCandidatesStatic $afAtoms $graph $groupSize)
   (let* (
       ($size (if (== $groupSize ()) (goalCandidatesGroupSize) $groupSize))
       ($edges (goalCandidatesEdges $graph))
       ($allNodes (goalCandidatesNodesFromEdges $edges))
       ($outside (subtraction-atom $allNodes $afAtoms))
   )
   (goalCandidatesJoinStatic
       (goalCandidatesComputeExpandStr $size $outside $edges $afAtoms)
       (goalCandidatesComputeBreakStr $size $outside $edges $afAtoms))))


; ---------------------------------------------------------------------------
; DYNAMIC MODE — extract lambda bodies as helper functions
; ---------------------------------------------------------------------------

(= (goalCandidatesFilterStrongHebb $edge)
   (if (>= (goalCandidatesEdgeWeight $edge)
           (goalCandidatesHebbianMinWeight))
       $edge
       ()))

(= (goalCandidatesHebbWeightForNode $node $hebbAfNodes $strongHebbian)
   (foldl-atom $hebbAfNodes 0 $acc $n
       (+ $acc (goalCandidatesEdgeWeight
                    (goalCandidatesFindEdge $strongHebbian $node $n)))))

(= (goalCandidatesDynamicExpandEntry $node $staticEdges $strongHebbian $af)
   (let* (
       ($staticNeigh (goalCandidatesNeighborsFromEdges $staticEdges $node))
       ($hebbNeigh (goalCandidatesNeighborsFromEdges $strongHebbian $node))
       ($staticAfCount (goalCandidatesCountInSet $staticNeigh $af))
       ($hebbAfCount (goalCandidatesCountInSet $hebbNeigh $af))
       ($hebbAfNodes (intersection-atom $af $hebbNeigh))
       ($hebbWeight (goalCandidatesHebbWeightForNode $node $hebbAfNodes $strongHebbian))
       ($score (+ (+ (* $staticAfCount 1.0) (* $hebbAfCount 2.0)) $hebbWeight))
   )
   (if (or (> $staticAfCount 0) (> $hebbAfCount 0))
       (cons-atom $node (cons-atom $staticAfCount (cons-atom $hebbAfCount (cons-atom $score ()))))
       ())))

(= (goalCandidatesDynamicBreakEntry $node $staticEdges $strongHebbian $af)
   (let* (
       ($staticNeigh (goalCandidatesNeighborsFromEdges $staticEdges $node))
       ($hebbNeigh (goalCandidatesNeighborsFromEdges $strongHebbian $node))
       ($staticAfCount (goalCandidatesCountInSet $staticNeigh $af))
       ($hebbAfCount (goalCandidatesCountInSet $hebbNeigh $af))
       ($degree (+ (size-atom $staticNeigh) (size-atom $hebbNeigh)))
   )
   (if (and (== $staticAfCount 0) (== $hebbAfCount 0))
       (cons-atom $node (cons-atom $degree ()))
       ())))

(= (goalCandidatesDynamicFallbackEntry $node $staticEdges $strongHebbian $af)
   (let* (
       ($staticNeigh (goalCandidatesNeighborsFromEdges $staticEdges $node))
       ($hebbNeigh (goalCandidatesNeighborsFromEdges $strongHebbian $node))
       ($staticAfCount (goalCandidatesCountInSet $staticNeigh $af))
       ($hebbAfCount (goalCandidatesCountInSet $hebbNeigh $af))
       ($afConn (+ $staticAfCount $hebbAfCount))
   )
   (cons-atom $node (cons-atom $afConn ()))))

(= (goalCandidatesComputeStrongHebbian $hebbianLinks)
   (goalCandidatesFilterEntries
       (map-atom
           (goalCandidatesTake
               (goalCandidatesCeil (* (size-atom (goalCandidatesSortEdgeWeight $hebbianLinks))
                                      (goalCandidatesHebbianTopPercentile)))
               (goalCandidatesSortEdgeWeight $hebbianLinks))
           $edge
           (goalCandidatesFilterStrongHebb $edge))))

(= (goalCandidatesComputeOutside $staticEdges $strongHebbian $afAtoms)
   (let* (
       ($staticNodes (goalCandidatesNodesFromEdges $staticEdges))
       ($hebbianNodes (goalCandidatesNodesFromEdges $strongHebbian))
       ($merged (goalCandidatesLocalConcatTuple $staticNodes $hebbianNodes))
       ($allNodes (goalCandidatesLocalRemoveDuplicates $merged))
   )
   (subtraction-atom $allNodes $afAtoms)))

(= (goalCandidatesComputeExpandStrDyn $size $outside $staticEdges $strongHebbian $af)
   (goalCandidatesFormatExpandDyn
       (goalCandidatesTake $size
           (goalCandidatesSortExpandDyn
               (goalCandidatesFilterEntries (map-atom $outside $node (goalCandidatesDynamicExpandEntry $node $staticEdges $strongHebbian $af)))))))

(= (goalCandidatesComputeBreakStrDyn $size $outside $staticEdges $strongHebbian $af)
   (let* (
       ($top (goalCandidatesTake $size
               (goalCandidatesSortBreak
                   (goalCandidatesFilterEntries (map-atom $outside $node (goalCandidatesDynamicBreakEntry $node $staticEdges $strongHebbian $af))))))
   )
   (if (== $top ())
       (let* (
           ($fallbackTop (goalCandidatesTake $size
                   (goalCandidatesSortBreakFallback
                       (goalCandidatesFilterEntries (map-atom $outside $node (goalCandidatesDynamicFallbackEntry $node $staticEdges $strongHebbian $af))))))
       )
       (goalCandidatesFormatBreakFallback $fallbackTop))
       (goalCandidatesFormatBreak $top))))

(= (goalCandidatesDynamic $afAtoms $hebbianLinks $graph $groupSize)
   (let* (
       ($size (if (== $groupSize ()) (goalCandidatesGroupSize) $groupSize))
       ($staticEdges (goalCandidatesEdges $graph))
       ($strongHebbian (goalCandidatesComputeStrongHebbian $hebbianLinks))
       ($outside (goalCandidatesComputeOutside $staticEdges $strongHebbian $afAtoms))
   )
   (goalCandidatesJoinDynamic
       (goalCandidatesComputeExpandStrDyn $size $outside $staticEdges $strongHebbian $afAtoms)
       (goalCandidatesComputeBreakStrDyn $size $outside $staticEdges $strongHebbian $afAtoms))))

(= (goalCandidates $afAtoms $hebbianLinks $graph $groupSize $useDynamic)
   (if (goalCandidatesToggle $useDynamic)
       (goalCandidatesDynamic $afAtoms $hebbianLinks $graph $groupSize)
       (goalCandidatesStatic $afAtoms $graph $groupSize)))
