
;;; This file implements the 
; !(register-module! ../../metta-attention)
; !(register-module! ../../metta-attention)
; !(import! &self metta-attention:attention-bank:utilities:helper-functions)
; !(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
; !(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
; !(import! &self metta-attention:attention-bank:bank:attention-bank)
; !(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
; !(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)

!(bind! &attentionalFocus (new-space))

!(bind! maxLinkNum 0)
!(bind! localToFarLinks 1)
!(bind! newAtomsInAV   Nil )

( = (newAtomsInAV ) (cons Nil))

( = (HebbianCreationAgent-Run)
    ; if the attentional focus is empty no work is done
    (if ( == (findLength newAtomsInAV)  0)  ; this function exist in the attetention-module 
        empty
        ( let* (($source popNewAtomInAV) ; in the order of thier interance 
                ($handleSet getAtomList)
                (removeAtom $source) ; to minimize self connection
                ($existingAsSourceHS (getSourceNeighbors $source ASYMMETRIC_HEBBIAN_LINK))
                ($existingAsTarget (getTargetNeighbors $source ASYMMETRIC_HEBBIAN_LINK))
                ($needToBeSource (getNeedToBeSource &attentionalFocus $existingAsSourceHS))
                ($needToBeTarget getNeedToBeTarget &attentionalFocus $existingAsTarget)
        )
        ( if (==  HEBBIAN_LINK (car-atom $source))
            (empty) ; if already hebbian_link nothing is done
            ; else
            (
                (addHebbianSourceRecursively $source $needToBeSource )
                (addHebbianTargetRecursively $source $needToBeTarget )
                (addFromOutSideAF $source localToFarLinks)
                ( $incomingSet (incomingHebbianLinks $source) )
                (if (> (size $incomingSet) maxLinkNum ) 
                    (removeLinkRecursively (- (size incomingSet) maxLinkNum))
                    ()
                )
            ) 
        )
        )
    )
)




( = (removeAtom $atom)
    (remove-atom &attentionalFocus  $atom)

)

;;;;;;;;;;;;;;helper functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(: List Type)
(: Nil List)
( : cons(-> Number List List )) ;; Number type


( = (findLength Nil ) 0)
(  = (findLength (cons $x $xs))
    (+ 1 (findLength $xs))
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; pop ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

( = (popNewAtomInAV (cons $x Nil)) Nil)
( = (popNewAtomInAV (cons $x (cons $y $ys)))
    (cons $x (popNewAtomInAV (cons $y $ys)))
)







; (= (pushAtomToAv $atom Nil) (cons ($atom Nil))) ; might create deterministic errors

( = (pushAtomToAv $atom) (atom added to av))
; (= (pushAtomToAv $atom (cons $x $xs))
;    (cons $x (pushAtomToAv $atom $xs)))




;Function: getAtomList
;Description: Retrieves a list of all atoms currently in attentional focus space.
;Parameters: None.
;Returns: A list of atoms in attentional focus space.
(: getAtomList(->Symbol))
(= (getAtomList)
   (collapse (get-atoms &attentionalFocus))
)


;Function: addAtomToAF
;Description:
;           if the atom has neither AV nor STV,it returns an error message
;           if an atom is valid,it will add it to the attentional focus space. 
;Parameters:
;          $atom: The atom to add.
;Returns: A message indicating success or failure.

; (: addAtomToAFCustom (-> Atom Symbol))

( = (addAtom $atom)
    (add-atom &attentionalFocus $atom)
)


(= (addAtomToAFCustom $atom)
(

    (addAtom $atom)
    (pushAtomToAv $atom)
)
    

)




(= (getTargetNeighbors $atom $type )
    (if (== $type UNORDERED_LINK)
        ()
        (let*
            (
                (($link $source $target) (let $tmp (getIncomingSet $atom $type) (superpose $tmp)))
                ($answer
                    (if (== $link $type)
                        (if (== $source $atom)
                            $target
                            ()
                        )
                        ()
                    )
                )
            )
            $answer
        )
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(= (getSourceNeighbors $atom $type)
    (if (== $type UNORDERED_LINK)
        ()
        (let*
            (
                (($link $source $target) (let $tmp (getIncomingSet $atom $type) (superpose $tmp)))
                ($answer
                    (if (== $link $type)
                        (if (not (== $source $atom))
                            $source
                            ()
                        )
                        ()
                    )
                )
            )
            $answer
        )
    )
)



( = (getNeedToBeSource $space $list)
    (setDifference $space $list)


)

( = (getNeedToBeTarget $space $list)

    (setDifference $space $list)
)


; return the atoms that are in the attentional focus but not in the list 
( = (setDifference $space $list)
    (if (== $list ())
        ()
        ;else
        (if atomIsInAF (car-atom $list)
            (setDifference (cdr-atom $list))
            (car-atom $list setDifference (cdr-atom $list))
    
        )

    )
)

( = (addHebbianSourceRecursively $source  $needToBeSource)
    (if ( == $needToBeSource ())
        empty
        (addHebbian $source (car-atom $needToBeSource)
        (addHebbianSourceRecursively (cdr-atom $needToBeSource))
        
        )
    
    )

)

( = (addHebbianTargetRecursively $source $needToBeTarget)
    (if (== $needToBeTarget ())
    empty
    (addHebbian $source (car-atom $needToBeTarget)
    (addHebbianTargetRecursively (cdr-atom $needToBeTarget))
    )
    
    )

)


;;; Function: getIncomingSet
;;; Description: Retrieves the set of incoming links of a specific type for a given atom,
;;;              filtering out links not in the active frame (AF).
;;; Parameters:
;;;   $atom: The atom for which to find incoming links.
;;;   $type: The type of link to consider.
;;; Returns: A list of incoming links that are in the AF.

(: getIncomingSet (-> Atom Type List))
(= (getIncomingSet $atom $type)
    (let* (
          ($incoming_set (getIncomingSetByType $atom $type))
          ($filtered_set (filterLinksInAF $incoming_set))
           )
        $filtered_set
    )
)




;;; Function: getIncomingSetByType
;;; Description: Retrieves the set of incoming links of a specific type for a given atom
;;;              without filtering based on the active frame.
;;; Parameters:
;;;   $atom: The atom for which to find incoming links.
;;;   $type: The type of link to consider.
;;; Returns: A list of incoming links of the specified type.

(: getIncomingSetByType (-> Atom Type List))
(= (getIncomingSetByType $atom $type)
    (collapse 
        (superpose   
            (
                (match &attentionalFocus ($type $atom $b) ($type $atom $b))
                (match &attentionalFocus ($type $b $atom) ($type $b $atom))
            )
        )  
    )
)


;;; Function: filterLinksInAF
;;; Description: Filters a list of links, returning only those that are in the active frame (AF).
;;; Parameters:
;;;   $incoming_set: A list of incoming links to filter.
;;; Returns: A new list containing only the links that are in the AF.

(: filterLinksInAF (-> List List))
(= (filterLinksInAF $incoming_set)
    (if (== $incoming_set ())
        ()
        (let* (
              ($head (car-atom $incoming_set))
              ($tail (cdr-atom $incoming_set))
              ($filtered_head 
                    (if (atomIsInAF $head)
                        $head
                        ()
                    ))
               )
               
            (concatTuple ($filtered_head) (filterLinksInAF $tail))
        )
    )
)


;Function: atomIsInAF
;Description: Checks if a given atom is in the attentional focus space.
;Parameters:
;         $atom: The atom to check.
;Returns: True if the atom is in attentional focus space, otherwise False.

(: atomIsInAF (-> Atom Bool))
(= (atomIsInAF $atom)
   (if  (== (collapse (match &attentionalFocus $atom $atom)) ())
        False
        True
    )
)



;Function: getRandomAtomNotInAF
;Description: Retrieves a random atom that is not in attentional focus.
;Parameters: None.
;Returns: A randomly selected atom from outside attentional focus.
(: getRandomAtomNotInAF (-> Atom))
(= (getRandomAtomNotInAF)
   (let*
       (

           ($allAtoms  (getAtomBinList))
           ($filteredAtoms (filter $allAtoms atomIsNotInAF))
       )
       (if (== $filteredAtoms ())
           %Undefined 
           (let*
               (

                   ($res (py-list $filteredAtoms))
                   ($randomAtom ((py-atom random.choice) $res))
               )
               $randomAtom 
           )
       )
   )
)


( = (addFromOutSideAF  $source $localToFarLinks)
    (if ( == $localToFarLinks 0 )
        ()
        (let ($target getRandomAtomNotInAF)
            (if ( == (car-atom $target) ASYMMETRIC_HEBBIAN_LINK)
                (addHebbian $source $target )
                 ()
            )
        )
    )

)


( = (incomingHebbianLinks $source )
    (let $atomList (getAtomList)
        (filterHibbianLinks $atomList)

    )


)


( = (linkMatcher $atom) 
    (if (match &attentionalFocus (ASYMMETRIC_HEBBIAN_LINK $source $target) $source)
    
    )

)

(= (filterHebbianLinks $list)
    (if (== $list ())
        ()  ; Base case: return empty list if input is empty
        (let (($head (car-atom $list))
              ($tail (cdr-atom $list)))
            (if (match &attentionalFocus (ASYMMETRIC_HEBBIAN_LINK $source $target) $source)
                (cons (list $source $target) (filterHebbianLinks $tail)) ; Keep valid links
                (filterHebbianLinks $tail)  ; Skip invalid links
            )
        )
    )
)

(: addHebbian (-> Atom Atom empty ))
( = (addHebbian source target)
    (addLink(ASYMMETRIC_HEBBIAN_LINK source target))
    createTV(link 0.5 0.1)
)

( = (addLink $atom)
    (add-atom &attentionalFocus $atom)
)

( = (createTv $atom $v1 $v2)
    (add-atom ($atom $v1 $v2) )

)
