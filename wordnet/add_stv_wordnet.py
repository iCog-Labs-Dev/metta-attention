import re

IN_FILE = "wordnet.metta"
OUT_FILE = "wordnet_stv_clean.metta"

DEFAULT_MEAN = 0.8
DEFAULT_CONF = 0.9

relation_pattern = re.compile(r'^\(([^()\s]+)\s+(.+)\)$')

# Prolog-safe unquoted atom pattern
SAFE_ATOM = re.compile(r'^[a-z][a-z0-9_]*$')

def clean_atom_text(text):
    text = text.lower()
    text = text.replace('.', '_')
    return text

def maybe_quote(text):
    """
    Quote atom if it is NOT a safe Prolog atom.
    Escape apostrophes inside quoted atoms.
    """
    text = clean_atom_text(text)

    if SAFE_ATOM.match(text):
        return text

    # Escape apostrophes inside quoted atoms
    text = text.replace("'", "\\'")
    return f"'{text}'"

with open(IN_FILE, "r", encoding="utf-8") as fin, \
     open(OUT_FILE, "w", encoding="utf-8") as fout:

    for line in fin:
        line = line.strip()
        if not line:
            continue

        # --- Synset lines ---
        if line.startswith("(Synset"):
            content = line[1:-1].strip()
            parts = content.split()
            parts = [maybe_quote(p) for p in parts]
            fout.write(f"({ ' '.join(parts) })\n")
            continue

        # --- Relation lines ---
        m = relation_pattern.match(line)
        if m:
            rel_name = clean_atom_text(m.group(1))
            args = m.group(2).split()
            args = [maybe_quote(a) for a in args]

            fout.write(
                f"({rel_name} {' '.join(args)} "
                f"('{DEFAULT_MEAN}' '{DEFAULT_CONF}'))\n"
            )
        else:
            fout.write(maybe_quote(line) + "\n")

print("✅ WordNet cleaned: all special-character atoms safely quoted")
