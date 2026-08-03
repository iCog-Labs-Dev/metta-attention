(updateAttentionParam MAX_AF_SIZE 70.0)
(updateAttentionParam TARGET_STI 10000.0)
(updateAttentionParam TARGET_LTI 10000.0)
(updateAttentionParam STI_FUNDS_BUFFER 10000.0)
(updateAttentionParam LTI_FUNDS_BUFFER 10000.0)
(updateAttentionParam FUNDS_STI 100000.0)
(updateAttentionParam FUNDS_LTI 100000.0)
(updateAttentionParam MAX_SPREAD_PERCENTAGE 0.2)
(updateAttentionParam HEBBIAN_MAX_ALLOCATION_PERCENTAGE 0.5)
(updateAttentionParam AFRentFrequency 5.0)

(= (strategyCandidates)
    (
        (action narrow-focus
            (0.4 0.3 0.8 0.2 0.2 0.3 0.8 0.5)
            0.3
            (0.0 0.0 0.1 0.0 0.0 0.0 0.1 0.0)
        )
        (action expand-focus
            (0.6 0.5 0.3 0.6 0.5 0.7 0.3 0.6)
            0.4
            (0.1 0.0 0.0 0.1 0.0 0.1 0.0 0.1)
        )
        (action explore-novel
            (0.8 0.7 0.1 0.9 0.9 0.5 0.1 0.3)
            0.5
            (0.1 0.2 0.0 0.2 0.2 0.0 0.0 0.0)
        )
    ))
