!(register-module! ../../metta-attention)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:attention-bank)

! (setAv A (200 200 0))
! (setAv B (400 400 1))
;; Function: tradeSti
;; -------------------
;; The function takes two atoms and an sti value to exchange
;; It takes the value given and deductes it from the source atom and adds it to the target atom
;; The function then updates the Sti values of both atoms using the setSTI function

(: tradeSti (-> Atom Atom Number %Undefined%))

(= (tradeSti $source $target $value)
      (let*
        (
            ($sourceSTI (getSTI $source))
            ($targetSTI (getSTI $target))
            ($newSourceSTI (- $sourceSTI $value))
            ($newTargetSTI (+ $targetSTI $value))
        )
    ((setSTI $target $newTargetSTI) (setSTI $source $newSourceSTI))
   ))
;; Test case to check whether the tradeSti function works.
;; Note that this function utilizes the getSTI function in the getter-and-setter.metta
;; The getSTI function must be added for this to work!

! (tradeSti A B 100)
! (getSTI B)
! (getSTI A)
