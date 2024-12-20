!(register-module! ../../../metta-attention)
!(import! &self metta-attention:attention-bank:bank:attention-bank)

;example usage to compute STI and LTI wages
!(assertEqual (calculate_STI_wage) 20.0)
!(assertEqual (calculate_LTI_wage) 20.0)