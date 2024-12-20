; Define initial variables
(= (starting-funds-STI) 100000)
(= (funds-STI) 100000)
(= (starting-funds-LTI) 100000)
(= (funds-LTI) 100000)
(= (sti-funds-buffer) 10000)
(= (lti-funds-buffer) 10000)
(= (target-STI) 10000)
(= (target-LTI) 10000)
(= (STI-atom-wage) 10)
(= (LTI-atom-wage) 10)

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

(= (calculate_STI_wage)
    (let* (
        ($funds (funds-STI))
        ($diff (- $funds (target-STI)))
        ($ndiff-raw (/ $diff (sti-funds-buffer)))
        ($ndiff-clamped-min (min $ndiff-raw 1.0))
        ($ndiff (max $ndiff-clamped-min -1.0))
        ($atom-wage (STI-atom-wage))
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

(= (calculate_LTI_wage)
    (let* (
        ($funds (funds-LTI))
        ($diff (- $funds (target-LTI)))
        ($ndiff-raw (/ $diff (lti-funds-buffer)))
        ($ndiff-clamped-min (min $ndiff-raw 1.0))
        ($ndiff (max $ndiff-clamped-min -1.0))
        ($atom-wage (LTI-atom-wage))
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
        ($sti (get-sti $pattern))
        ($lti (get-lti $pattern))
        ($vlti (get-vlti $pattern))
        ($sti-wage (* (calculate_STI_wage) $stimulus))
        ($lti-wage (* (calculate_LTI_wage) $stimulus))
        ($new-sti (+ $sti $sti-wage))
        ($new-lti (+ $lti $lti-wage))
        ($new-av ($new-sti $new-lti $vlti))
    )
    (set_av $pattern $new-av)
    )
)
