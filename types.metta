 ; This file contains the type definitions for AttentionValue and TruthValue

 ; AttentionValue is a tuple of three numbers, the first number is the short term importance(STI),
 ; the second number is the long term importance(LTI) and
 ; the third number is the value of very long term importance(VLTI).

 ; TruthValue is a tuple of two numbers, the first number is show the mean of the value and the second number is the confidence of the value.

(: AV (-> Number Number Number Type))
(: STV (-> Number Number Type))
