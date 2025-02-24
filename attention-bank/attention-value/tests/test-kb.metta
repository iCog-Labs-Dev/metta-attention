(: A (createSTV a (0.1 0.2)))
(: A (createAV a (10.0 10.0 0.1)))

(: B (createAV b (100.0 1.0 0.2)))
(: B (createSTV b (0.5 0.5)))

(: createLink (-> $source $target $type ($source $target)))
(: link_ab (createAV (createLink A B EvaluationLink) (10.0 10.0 1.0)))

