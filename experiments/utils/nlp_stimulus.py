"""spaCy NLP preprocessing for the insect-sent read loop.

Used by experiments/experiment.metta through its MeTTa wrapper (same-file
pattern, like timeTime/currentTime elsewhere in the repo):

    !(import! &self "utils/nlp_stimulus.py")
    (= (getStimuli $words) (py-call (nlp_stimulus.stimuli $words)))

Functions
---------
stimuli(word_list)  Raw (insectSent ...) word list -> stimulus atoms:
                    tokens are rejoined into text, re-segmented into
                    sentences, lemmatized (bees -> bee) and filtered to
                    content words (NOUN/PROPN/VERB/ADJ/ADV), dropping
                    stopwords and punctuation. Returns a flat list in
                    reading order, ready for insectPoisonReadExp.

Requirements: spacy + en_core_web_sm (see requirments.txt) and a run
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
