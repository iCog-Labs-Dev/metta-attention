"""spaCy NLP preprocessing for the insect-sent read loop.

Used by experiments/experiment.metta (read entry point, line ~123):

    !(import! &self "utils/nlp_stimulus.py")
    (py-call (nlp_stimulus.stimuli <word-list>))

Functions
---------
stimuli(word_list)  Raw (insectSent ...) word list -> stimulus atoms:
                    tokens are rejoined into text, re-segmented into
                    sentences, lemmatized (bees -> bee) and filtered to
                    content words (NOUN/PROPN/VERB/ADJ/ADV), dropping
                    stopwords and punctuation. Returns a flat list in
                    reading order, ready for insectPoisonReadExp.

triples(word_list)  (subject, verb, object) triples from dependency parses.
                    Intended as the future hook for growing &incident from
                    text; not wired into experiment.metta yet.

Requirements: spacy + en_core_web_sm (see requirements.txt) and a run
started from the activated .ECAN314 environment - its VIRTUAL_ENV variable
is what makes PeTTa's embedded Python interpreter see the venv packages.
"""

import spacy

_nlp = None

CONTENT_POS = {"NOUN", "PROPN", "VERB", "ADJ", "ADV"}


def _get_nlp():
    global _nlp
    if _nlp is None:
        _nlp = spacy.load("en_core_web_sm")
    return _nlp


def _to_doc(word_list):
    text = " ".join(str(w) for w in word_list)
    return _get_nlp()(text)


def stimuli(word_list):
    """Turn the raw sentence word list into filtered stimulus atoms."""
    atoms = []
    for tok in _to_doc(word_list):
        if tok.pos_ in CONTENT_POS and not tok.is_stop and not tok.is_punct:
            atoms.append(tok.lemma_.lower())
    return atoms


def triples(word_list):
    """Extract simple (subject, verb, object) triples for future KG growth."""
    out = []
    for tok in _to_doc(word_list):
        if tok.dep_ == "nsubj" and tok.head.pos_ == "VERB":
            for child in tok.head.children:
                if child.dep_ in ("dobj", "attr", "pobj"):
                    out.append([
                        tok.lemma_.lower(),
                        tok.head.lemma_.lower(),
                        child.lemma_.lower(),
                    ])
    return out
