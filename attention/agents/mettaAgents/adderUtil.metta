!(bind! &adder (new-space))

(= (adder $x)
    (add-atom &adder (x (+ $x 1)))
)