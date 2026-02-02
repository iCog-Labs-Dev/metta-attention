; Function:  getAfAtoms
; description: 
;             - get maximum af size from params & all atoms in typespace that have bin 
;             - if atoms in typespace are less than in af, it returns all atoms
;             - else finds N numner of max sti atoms. where n = MAX_AF_SIZE
;             - finally write the atoms on csv
; Parameter: None
; Return: expression of atoms that has high importance

; (: getAfAtoms (-> Expression))
(= (getAfAtoms)
    (let*
        (
            ($afSize (getAttentionParam MAX_AF_SIZE))
            ($size (match-count (TypeSpace) ($patt ($val $bin))))
            ; ($helll (println! (inside get af atom $afSize $size)))


        ) 
        (if (>= $afSize $size)
                ;  $allAtoms
                (let $allAtoms (getAllAtomsWithBins) (trace! (write_csv_wrapper $allAtoms) $allAtoms))
                (getAfAtomsHelper $afSize)
        )
    )
)

; Function: const
; Description: 
;             - Returns a constant scaling factor used for the attentional focus buffer calculation.
;             - This value adjusts the sensitivity of the buffer that decides whether to perform 
;               sorting on the last STI bin.
; Parameter: None
; Return: A numeric value (0.7)
(= (const) 0.7)

; Function: getAfAtomsHelper
; Description: 
;             - this helper function finds top $size number of atoms  by iterating through bin numbers list from highest to lowest
;             - get bin numbers list, sort in decending and iterate on them until it gets #max-af-size atoms
;             - iterate over the last bin until it gets the required number of atoms
;             - finally write the atoms it gets on csv file
; Parameters: 
;            - $size: the number of atom we want to get
; Return:   expression of atoms that should be in attentional focus

; (: getAfAtomsHelper (-> Number Expression))
(= (getAfAtomsHelper $size)
    (let* 
        (   
            ($space (TypeSpace))
            ; ($s (println! (our size $size)))
            
            ($bins (getBinList $space))
            ; ($totalbin (println! (bins we have $bins)))

            ($binList (sortDecend $bins))
            ; ($sortdece (println! (sorted Decend $binList)))

            (($min $atomsList) (minBin  $binList $size ())) ; getting the last bin and atoms in above the min bin
            ; ($minimu (println! (return of min bin ($min $atomsList) )))

            ($remainSize (- $size (size-atom $atomsList))) ; calculate remaining number of atoms

            ($buffer  (* (const) (py-call (math.sqrt $size))))
            ; ($remainSi (println! (size of the diff/remaining size $remainSize )))
        )   (if (<= $remainSize $buffer)
                $atomsList
                (let*
                    (($minAtomsSti (getAtomsByBin $min))
                    ; ($minatom (println! (return of get atom by bin fn $minAtomsSti )))
                    ($flag (> (- (size-atom $minAtomsSti) $remainSize) $buffer))
                    ; ($m (println! (return of sorted atoms desc $sortedMinList )))

                    ($lastAtoms (if $flag 
                                    (let $sortedMinList (sortAtomsDescending $minAtomsSti getSti) (getNatoms $sortedMinList $remainSize)); getting the first $size number of atoms
                                    $minAtomsSti))
                    ($afAtoms (union-atom $atomsList $lastAtoms))
                    ; ($help (println! (inside get af atom helper $atomsList $lastAtoms $afAtoms)))
                    ($wrote (write_csv_wrapper $afAtoms)) ; log to csv if logger is configured via start_log
                ) 
                $afAtoms)
    )
))

; Function: minBin
; Description: 
;             - is a function that iterates over bin list which is sorted in decending
;             - for each bin it finds atoms and append 
;             - if the bin list is empty, it returns -1 as the last bin it gets and the accumulater
;             - if the number of atoms >= $size returns the bin number last time it iterated and atoms that has been accumulated
; Return:   
;            - The bin number it has stopped iterating and the accumulated list of atoms

;  Parameters: 
;             -   $binList: list of bin numbers
;             -   $size: the number of atoms we want to find
;             -   $acc: accumulator which stores atom while iterating (usually ())

; (: minBin (-> Expression Number Expression Expression))
(= (minBin $binList $size $acc)
        (if (== $binList ())
            (-1 $acc)
        (let* (
                (($bin $tail) (decons-atom $binList))
                ; ($deco (println! (result of decons atom ($bin $tail))))

                ($atoms (getAtomsByBin $bin))

                ($atomsList (concatTuple $atoms $acc))
                ; ($dec (println! (atom lists $atomsList $acc)))

                )
            (if (< $size (size-atom $atomsList))
                ($bin $acc)
                (minBin $tail $size $atomsList)
            )
    )   )
)

; Function: getRandomAtomNotInAF
; Description: 
;             -  finds atoms in af and then atoms in typespac
;             - subtract them to get atoms that only found in typespace
;             - then choose random atom from them
; Parameter: None
; Returns: 
;         - atom that found in typespace but not in af

; (: getRandomAtomNotInAF (-> Symbol))
(= (getRandomAtomNotInAF)
    (let* 
        ( 
            ($afAtoms (getAfAtoms))
            ($atoms (getAllAtomsWithBins))
            ($outsideAf (subtraction-atom $atoms $afAtoms))
            ($size (size-atom $outsideAf))
            ; ($innotaf (println! (this is inside not in af fn $afAtoms $atoms $outsideAf $size)))
        )   
        (if (== $size 0)
            ()
              (if (== $size 1) 
                (index-atom $outsideAf 0) 
                  (let*
                  (
                    ($rand (random-int 0 $size) )
                    ($singatom (index-atom $outsideAf $rand) )
                    ; ($in (println! (the result if inde atomm $singatom $outsideAf $rand)))
                   )
                  $singatom
                   )
              )
        )
    )
)

(= (getRandomAtomNotInAF $afAtoms)
    (let* 
        ( 
            ($atoms (getAllAtomsWithBins))
            ($outsideAf (subtraction-atom $atoms $afAtoms))
            ($size (size-atom $outsideAf))
        )   
        (if (== $size 0)
            ()
            (if (== $size 1) 
                (index-atom $outsideAf 0) 
                (let*
                    (
                        ($rand (random-int 0 $size) )
                        ($singatom (index-atom $outsideAf $rand))
                    )
                    $singatom
                )
            )
        )
    )
)


; Function: getRandomAtomInAF
; Description: 
;             -  Retrives at atom at random from the attentionalFocus
; Parameters: None
; Returns: A unit Atom in Af is empty or a random atom 
(= (getRandomAtomInAF)
    (let $atoms 
            (getAfAtoms)
            (if (== (size-atom $atoms) 0)
                ()
            (let $rand (random-int 0 (size-atom $atoms))
            (index-atom $atoms $rand)))
    
    )
)

(= (getRandomAtomInAF $atoms)
    (if (== (size-atom $atoms) 0)
        ()
        (let $rand 
            (random-int 0 (size-atom $atoms))
            (index-atom $atoms $rand)
        )
    )
)
; Function: isAtomInAf
; Description: 
;             -  Checks if a given atom is in the attentional focus atoms list
; Parameters:
;             $atom: The atom to check.
;Returns: True if the atom is in attentional focus list, otherwise False.

; (: isAtomInAf (-> Symbol Bool))
(= (isAtomInAf $atom)
    (let $x (getAllMinSTI (getAfAtoms)) (< $x (getSti $atom)))
)
; Function: getIncomingSetByType
; Description: Retrieves the set of incoming links of a specific type for a given atom
;              without filtering based on the attentional focus.
; Parameters:
;   $atom: The atom for which to find incoming links.
;   $type: The type of link to consider.
; Returns: A list of incoming links of the specified type.
; (: getIncomingSetByType (-> Atom Type Expression))
(= (getIncomingSetByType $atom $type $list)
    (collapse 
        (let*
            (
                ($x (superpose $list))
                ($y (unify ($type $elem $atom) $x ($type $elem $atom) ()))
                ($l (unify ($type $atom $z) $x ($type $atom $z) ()))
            ) 
            (if (and (== $y ()) (== $l ())) (empty) (union-atom $y $l))
        )
    )
)

