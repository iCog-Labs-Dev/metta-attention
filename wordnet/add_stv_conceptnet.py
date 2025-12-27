import re

IN_FILE = "conceptnet.metta"
OUT_FILE = "conceptnet_stv_clean.metta"

DEFAULT_MEAN = 0.6
DEFAULT_CONF = 0.6

relation_pattern = re.compile(r'^\(([^()\s]+)\s+(.+)\)$')

# Prolog-safe unquoted atom
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

    text = text.replace("'", "\\'")
    return f"'{text}'"

with open(IN_FILE, "r", encoding="utf-8") as fin, \
     open(OUT_FILE, "w", encoding="utf-8") as fout:

    for line in fin:
        line = line.strip()
        if not line:
            continue

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

print("✅ ConceptNet cleaned: Prolog-safe atoms + quoted STVs")
