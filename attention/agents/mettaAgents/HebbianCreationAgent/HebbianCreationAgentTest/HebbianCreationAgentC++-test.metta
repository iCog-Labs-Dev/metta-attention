!(register-module! ../../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &self metta-attention:attention-bank:utilities:recentVal)
!(import! &self metta-attention:attention:agents:mettaAgents:Neighbors)
!(import! &self metta-attention:attention:agents:mettaAgents:HebbianCreationAgent:HebbianCreationAgent)

!(bind! conf90 900)
; Populate the AtomSpace with the example atoms

!(setStv Kermit (0.001 conf90))

!(setStv Frog (0.01 conf90))

!(setStv Animal (0.1 conf90))

!(setStv alive (0.01 conf90))

!(setStv slimy (0.01 conf90))

; Create the links

!(setStv (INHERITANCE_LINK Kermit Frog) (0.9 conf90))

!(setStv (INHERITANCE_LINK Frog Animal) (0.9 conf90))

!(setStv (EVALUATION_LINK Frog alive) (0.9 conf90))

!(setStv (EVALUATION_LINK Frog slimy) (0.9 conf90))

!(setStv (EVALUATION_LINK animal slimy) (0.9 conf90))

; Populate the AtomSpace with additional dummy atoms

!(setStv Dummy1 (0.001 conf90))

!(setStv Dummy2 (0.001 conf90))

!(setStv Dummy3 (0.001 conf90))

; Create the links for dummy atoms

!(setStv (INHERITANCE_LINK Dummy1 Dummy2) (0.9 conf90))

!(setStv (INHERITANCE_LINK Dummy2 Dummy3) (0.9 conf90))

; Stimulate the atoms in the AttentionalFocus with a stimulus of 200

!(stimulate Kermit 200)
!(stimulate Frog 200)
!(stimulate Animal 200)
!(stimulate alive 200)
!(stimulate slimy 200)


!(HebbianCreationAgent-Run (TypeSpace) (attentionalFocus))

!(assertEqual (attentionalFocusSize) 16)