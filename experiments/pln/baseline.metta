!(import! &self (library lib_pln))

(= (Baseline.Answer $beliefs $term)
   (BestCandidate ConfidenceRank ()
      (collapse
         (let (Sentence ($candidate $tv) $evidence) (superpose $beliefs)
            (case (== $candidate $term)
               ((True ($tv $evidence))))))))

(= (Baseline.Run $kb $steps $tasklimit $belieflimit $questions)
   (let* (($start (trace! (PLN_BASELINE_BEGIN) 0))
          ($started (current-time))
          (($tasks $beliefs) (PLN.Derive $kb $kb $steps $tasklimit $belieflimit))
          ($finished (current-time))
          ($timing (trace! (PLN_BASELINE_TIME (* 1000.0 (- $finished $started))) 0))
          ($state (trace! (PLN_BASELINE_STATE $tasks $beliefs) 0))
          ($answers
             (collapse
                (let ($id $term) (superpose $questions)
                   (let $answer (Baseline.Answer $beliefs $term)
                      (trace! (PLN_BASELINE_ANSWER $id $answer) $answer))))))
      (trace! (PLN_BASELINE_END) $answers)))
