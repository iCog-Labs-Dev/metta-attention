!(register-module! ../../metta-attention)
!(import! &kb metta-attention:experiments:kb)
!(import! &self metta-attention:experiments:depTypes)
!(import! &self metta-attention:experiments:use_cases)

!(filterLinksByType &kb Hebbian)
!(filterNodesByType &kb Concept)
