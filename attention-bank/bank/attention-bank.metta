; Type for the min function
(: min (-> Number Number Number))

; Type for the max function
(: max (-> Number Number Number))

; Type for the calculateSTIWage function
(: calculateSTIWage (-> Number))
 
; Type for the calculateLTIWage function
(: calculateLTIWage (-> Number))

; Type for the stimulate function
(: stimulate (-> Symbol Number AttentionValue))


; Define initial variables
(= (startingFundsSTI) 100000)
(= (fundsSTI) 100000)
(= (startingFundsLTI) 100000)
(= (fundsLTI) 100000)
(= (stiFundsBuffer) 10000)
(= (ltiFundsBuffer) 10000)
(= (targetSTI) 10000)
(= (targetLTI) 10000)
(= (STIAtomWage) 10)
(= (LTIAtomWage) 10)

; Function to compute the minimum of two values
(= (min $a $b)
    (if (< $a $b) $a $b)
)

; Function to compute the maximum of two values
(= (max $a $b)
    (if (> $a $b) $a $b)
)

; Function to calculate STI wage
; Purpose:
;    This function calculates the wage (adjustment factor) for the STI (Short-Term Importance)
;    of an atom based on the current funds available and the target STI funds.
;
; Logic:
;    1. Compute the difference between current STI funds and the target STI funds.
;    2. Normalize this difference using the buffer size (stiFundsBuffer) to determine the
;       magnitude of adjustment required.
;    3. Constrain the adjustment factor (ndiff) to lie between -1.0 and 1.0 to avoid extreme changes.
;    4. Return the adjusted STI wage by applying ndiff to the base wage (STIAtomWage).

(= (calculateSTIWage)
    (let* (
        ($funds (fundsSTI))
        ($diff (- $funds (targetSTI)))
        ($ndiff-raw (/ $diff (stiFundsBuffer)))
        ($ndiff-clamped-min (min $ndiff-raw 1.0))
        ($ndiff (max $ndiff-clamped-min -1.0))
        ($atom-wage (STIAtomWage))
    )
    (+ $atom-wage (* $atom-wage $ndiff)))
)

; Function to calculate LTI wage
; Purpose:
;    This function calculates the wage (adjustment factor) for the LTI (Long-Term Importance)
;    of an atom based on the current funds available and the target LTI funds.
;
; Logic:
;    1. Compute the difference between current LTI funds and the target LTI funds.
;    2. Normalize this difference using the buffer size (ltiFundsBuffer) to determine the
;       magnitude of adjustment required.
;    3. Constrain the adjustment factor (ndiff) to lie between -1.0 and 1.0 to avoid extreme changes.
;    4. Return the adjusted LTI wage by applying ndiff to the base wage (LTIAtomWage).

(= (calculateLTIWage)
    (let* (
        ($funds (fundsLTI))
        ($diff (- $funds (targetLTI)))
        ($ndiff-raw (/ $diff (ltiFundsBuffer)))
        ($ndiff-clamped-min (min $ndiff-raw 1.0))
        ($ndiff (max $ndiff-clamped-min -1.0))
        ($atom-wage (LTIAtomWage))
    )
    (+ $atom-wage (* $atom-wage $ndiff)))
)

; Function to stimulate an atom with a given stimulus
; Purpose
;    This function adjusts the AttentionValue (STI, LTI, VLTI) of a given atom
;    based on the calculated STI and LTI wages and a provided stimulus.
;
; Logic:
;    1. Retrieve the current STI, LTI, and VLTI values for the atom.
;    2. Compute adjusted wages for STI and LTI using calculate_STI_wage  and calculate_LTI_wage
;    3. Apply the stimulus to scale the wages and update the STI and LTI values.
;    4. Create a new AttentionValue combining the adjusted STI, LTI, and unchanged VLTI.
;    5. Set the updated AttentionValue for the atom.

(= (stimulate $pattern $stimulus)
    (let* (
        ($sti (getSTI $pattern))
        ($lti (getLTI $pattern))
        ($vlti (getVLTI $pattern))
        ($sti-wage (* (calculateSTIWage) $stimulus))
        ($lti-wage (* (calculateLTIWage) $stimulus))
        ($new-sti (+ $sti $sti-wage))
        ($new-lti (+ $lti $lti-wage))
        ($new-av ($new-sti $new-lti $vlti))
    )
    (set_av $pattern $new-av)
    )
)
