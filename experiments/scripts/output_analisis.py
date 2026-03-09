import csv
import re
from collections import defaultdict

def process_csv(file_path):
    word_counts = defaultdict(int)
    link_counts = defaultdict(int)

    # pattern to detect expressions like:
    # (insynset tropical tropical_s_04)
    relation_pattern = re.compile(r"\(\s*([^\s()]+)")

    with open(file_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)

        for row in reader:
            pattern = row["pattern"].strip()

            # Count every pattern (word or expression)
            word_counts[pattern] += 1

            # If it's a relation expression
            if pattern.startswith("("):
                match = relation_pattern.search(pattern)
                if match:
                    relation_type = match.group(1)
                    link_counts[relation_type] += 1

    return word_counts, link_counts


def get_top_n(count_dict, n=15):
    return sorted(count_dict.items(), key=lambda x: x[1], reverse=True)[:n]


if __name__ == "__main__":
    file_path = "../output/output.csv"

    word_counts, link_counts = process_csv(file_path)

    # Sort everything
    sorted_words = sorted(word_counts.items(), key=lambda x: x[1], reverse=True)
    sorted_links = sorted(link_counts.items(), key=lambda x: x[1], reverse=True)

    print("\nTop 15 Words/Patterns:")
    for word, count in sorted_words[:15]:
        print(f"{word}: {count}")

    print("\nTop 15 Relation Types:")
    for link, count in sorted_links[:15]:
        print(f"{link}: {count}")

    print(f"\nTotal unique words/patterns: {len(word_counts)}")
    print(f"Total unique relation types: {len(link_counts)}")