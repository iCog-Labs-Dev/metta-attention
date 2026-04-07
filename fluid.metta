; =========================
; 1. Graph Definition
; =========================
(Edge A B)
(Edge A C)
(Edge B D)
(Edge B E)
(Edge C F)
(Edge D G)
(Edge E G)
(Edge F G)

; =========================
; 2. Reward (fixed)
; =========================
(= (reward G) 10)
(= (reward $x)
   (if (== $x G) (empty) 0))

; =========================
; 3. Neighbor (nondeterministic)
; =========================
(= (neighbor $x)
   (match &self (Edge $x $y) $y))

; =========================
; 4. Terminal
; =========================
(= (terminal G) True)
(= (terminal $x)
   (if (== $x G) (empty) False))

; =========================
; 5. Value Function
; =========================
(= (value G) 10)

(= (value $x)
   (if (== $x G)
       (empty)
       (if (terminal $x)
           (reward $x)
           (+ (reward $x)
              (* 0.9 (best-next-value $x))))))

; =========================
; 6. BEST NEXT VALUE (FIXED)
; =========================

; Check if there exists a better neighbor
(= (better-exists $x $y)
   (if (match &self
         (Edge $x $z)
         (> (value $z) (value $y)))
       True
       False))

; True only if NO better neighbor exists
(= (no-better-neighbor $x $y)
   (if (better-exists $x $y)
       False
       True))

; Keep only best neighbors
(= (best-candidate $x $y)
   (if (no-better-neighbor $x $y)
       (value $y)
       (empty)))

; Final best-next-value
; (= (best-next-value $x)
;    (match &self
;      (Edge $x $y)
;      (best-candidate $x $y)))

; =========================
; 7. Better Neighbor
; =========================
(= (better-neighbor $x $y)
   (if (> (value $y) (value $x))
       True
       False))

(= (best-next-value $x)
   (value (choose-best $x)))


(= (choose-best $x)
   (match &self
     (Edge $x $y)
     (if (no-better-neighbor $x $y)
         $y
         (empty))))
; =========================
; 8. Step (filtered move)
; =========================

(= (step $x)
   (match &self
     (Edge $x $y)
     (if (better-neighbor $x $y)
         $y
         (empty))))

; =========================
; 9. Flow (path generation)
; =========================
(= (flow $x 0) ($x))

(= (flow $x $n)
   (if (> $n 0)
       (:: $x (flow (step $x) (- $n 1)))
       ()))

; =========================
; 10. TESTS
; =========================

!(reward G)        ; → [10]
!(reward A)        ; → [0]

!(neighbor A)      ; → [B, C]

!(terminal G)      ; → [True]
!(terminal A)      ; → [False]

!(value G)         ; → [10]
!(value D)         ; → [9.0]
!(value B)         ; → [8.1]
!(value A)         ; → [7.29]

; !(best-next-value D) ; → [10]
; !(best-next-value B) ; → [9.0]



; Possible:
; (:: A (:: B (:: D (:: G ()))))
; (:: A (:: C (:: F (:: G ()))))
!(flow A 4)
!(hello)