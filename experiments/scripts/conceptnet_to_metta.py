import csv

def clean(c):
    return c.replace("/c/en/", "").replace("/", "_")

out = open("../data/conceptnet.metta", "w")

with open("../data/conceptnet-assertions-5.7.0.csv", newline='', encoding="utf-8") as f:
    reader = csv.reader(f, delimiter='\t')
    for row in reader:
        rel = row[1]
        start = row[2]
        end = row[3]

        if not start.startswith("/c/en/") or not end.startswith("/c/en/"):
            continue

        relation = clean(rel.replace("/r/", ""))
        s = clean(start)
        e = clean(end)

        out.write(f"({relation} {s} {e})\n")

out.close()
print("/data/conceptnet.metta generated")

# https://s3.amazonaws.com/conceptnet/downloads/2019/edges/conceptnet-assertions-5.7.0.csv.gz
# gunzip conceptnet-assertions-5.7.0.csv.gz

# the csv file should exist inside wordnet folder before running this script
