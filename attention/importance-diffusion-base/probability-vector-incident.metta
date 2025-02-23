;;takes incident atoms and propagates some weight(number) equally to each incident atom
;;structure of bin: (index (incident-atoms $_))

! (bind! &space (new-space))

;; Helper functions
;;----------------------------------------
;; getIncidentAtoms: extracts the incidnet atoms from the bin
;; len: Calculates the length of atoms in a list 
;; countIncidentAtoms: Calculates the length of the incident atoms utilizing the len function
(= (getIncidentAtoms $a)
   (match &space ($a (incident-atoms $incidentAtoms)) $incidentAtoms))

(= (len $lst)
   (if (== $lst ())
       0
       (+ 1 (len (cdr-atom $lst)))
   )
)
(= (countIncidentAtoms $a)
   (len (getIncidentAtoms $a)))
;; Function: probabilityVectorIncident
;; -------------------
;; The function takes the list of incident atoms(atoms related to the given atom)
;; It calculates how many the incident atoms are and divides 1 by that number
;; If ther is no incidnet atom it returns an empty list
;; If there are incident atoms it returns the atoms with their equallyy distributed probability number
(= (probabilityVectorIncident $a)
   (let $incidentAtoms (getIncidentAtoms $a)
       (let $count (len $incidentAtoms)
           (if (== $count 0)
               ()
               (let $weight (/ 1.0 $count)
                   ((superpose $incidentAtoms) $weight))))))
