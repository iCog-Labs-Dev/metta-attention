import re
from collections import defaultdict

def count_relation_types(file_path):
    """
    Count relation types in a .metta file.
    Example line:
    ((antonym against someone) ('0.6' '0.6'))
    """

    relation_counts = defaultdict(int)

    # Capture first word after "(("
    pattern = re.compile(r"\(\(\s*([^\s()]+)")

    with open(file_path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()

            # Skip empty lines
            if not line:
                continue

            match = pattern.search(line)
            if match:
                relation_type = match.group(1)
                relation_counts[relation_type] += 1

    return dict(relation_counts)


if __name__ == "__main__":
    file_path = "../data/wordnet_stv_clean.metta"

    results = count_relation_types(file_path)

    print("Relation Type Counts:\n")
    for relation, count in sorted(results.items()):
        print(f"{relation}: {count}")

    print(f"\nTotal unique relation types: {len(results)}")



# Relation Type Counts:

# antonym: 19066
# atlocation: 27797
# capableof: 22677
# causes: 16801
# causesdesire: 4688
# createdby: 263
# dbpedia_capital: 459
# dbpedia_field: 643
# dbpedia_genre: 3824
# dbpedia_genus: 2937
# dbpedia_influencedby: 1273
# dbpedia_knownfor: 607
# dbpedia_language: 916
# dbpedia_leader: 84
# dbpedia_occupation: 1043
# dbpedia_product: 519
# definedas: 2173
# derivedfrom: 325374
# desires: 3170
# distinctfrom: 3315
# entails: 405
# etymologicallyderivedfrom: 71
# etymologicallyrelatedto: 32075
# formof: 378859
# hasa: 5545
# hascontext: 232935
# hasfirstsubevent: 3347
# haslastsubevent: 2874
# hasprerequisite: 22710
# hasproperty: 8433
# hassubevent: 25238
# instanceof: 1480
# isa: 230137
# locatednear: 49
# madeof: 545
# mannerof: 12715
# motivatedbygoal: 9489
# notcapableof: 329
# notdesires: 2886
# nothasproperty: 327
# partof: 13077
# receivesaction: 6037
# relatedto: 1703582
# similarto: 30280
# symbolof: 4
# synonym: 222156
# usedfor: 39790

# Total unique relation types: 47


# Relation Type Counts:

# insynset: 206978
# isa: 89089

# Total unique relation types: 2


