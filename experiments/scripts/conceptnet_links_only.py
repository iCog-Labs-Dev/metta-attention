import re

IN_FILE = "conceptnet_stv_clean.metta"
OUT_FILE = "conceptnet_links_only.metta"

# Match: ((relation arg1 arg2 ...) ('stv1' 'stv2'))
LINK_WITH_STV = re.compile(
    r'^\(\(\s*([^\s()]+)\s+([^)]+)\)\s+\(\'.*?\'\s+\'.*?\'\s*\)\)$'
)

with open(IN_FILE, "r", encoding="utf-8") as fin, \
     open(OUT_FILE, "w", encoding="utf-8") as fout:

    for line in fin:
        line = line.strip()
        if not line:
            continue

        m = LINK_WITH_STV.match(line)
        if m:
            rel = m.group(1)
            args = m.group(2).strip()

            # write only the link
            fout.write(f"({rel} {args})\n")

print("✅ Links extracted: nodes and STVs removed")
