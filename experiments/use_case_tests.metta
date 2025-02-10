!(register-module! ../../metta-attention)
!(import! &depTypes metta-attention:experiments:kb)
!(import! &self metta-attention:experiments:depTypes)
!(import! &self metta-attention:experiments:use_cases)

(= (dT) &depTypes)

!(filterLinksByType Hebbian)
!(filterNodesByType Concept)
