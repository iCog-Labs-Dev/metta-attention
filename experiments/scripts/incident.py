import re

INPUT_FILE = "../data/incident_final.metta"
OUTPUT_FILE = "../data/output_prolog_ready.metta"

SAFE_ATOM = re.compile(r'^[a-z][a-z0-9_]*$')
NUMBER = re.compile(r'^\d+(\.\d+)?$')


def clean_atom_text(text):
    text = text.lower()
    text = text.replace('.', '_')
    return text


def maybe_quote(text):
    """
    Convert token into a Prolog-safe atom.
    """
    text = clean_atom_text(text)

    if SAFE_ATOM.match(text):
        return text

    text = text.replace("'", "\\'")
    return f"'{text}'"


def process_token(tok):

    if tok in ["(", ")"]:
        return tok

    if NUMBER.match(tok):
        return tok

    return maybe_quote(tok)


def process_line(line):

    tokens = re.split(r'(\s+|\(|\))', line)

    out = []

    for tok in tokens:

        if tok == "" or tok.isspace():
            out.append(tok)
            continue

        out.append(process_token(tok))

    return "".join(out)


with open(INPUT_FILE, "r", encoding="utf-8") as fin, \
     open(OUTPUT_FILE, "w", encoding="utf-8") as fout:

    for line in fin:
        fout.write(process_line(line))

print("✅ File converted to Prolog-safe atoms.")

