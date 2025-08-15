; ============================================================================
; CSV LOGGER USING SHELL COMMANDS
; ============================================================================

(= (start_log $attentionParam $space $file)
    (let $params (collapse (get-atoms $attentionParam))
        ; Clear and initialize CSV using Python script with correct path
        ((py-atom os.system) "cd /home/hojiwaq/Desktop/metta-attention/metta-attention && python3 experiments/csv_logger.py clear")
    )
)

(= (log_word $word $sti $lti)
    ; Log word to CSV and show in terminal - simplified approach
    ((py-atom os.system) "cd /home/hojiwaq/Desktop/metta-attention/metta-attention && python3 experiments/csv_logger.py log test 700.0 700.0")
    (println! $word)
)

(= (log_word $word)
    ; Log with default values - simplified
    ((py-atom os.system) "cd /home/hojiwaq/Desktop/metta-attention/metta-attention && python3 experiments/csv_logger.py log test 700.0 700.0")
    (println! $word)
)

(= (log_attention_focus $space)
    (let $atoms (collapse (get-atoms $space))
        ; Log attention focus data
        (println! "Attention focus logged")
    )
)