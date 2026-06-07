import sys
import random
import re

def generate_noisy_dataset(input_file, output_file, noise_ratio=0.2):
    print(f"Reading from {input_file}...")

    duplicated_count = 0
    total_count = 0

    with open(input_file, "r", encoding="utf-8") as fin, open(output_file, "w", encoding="utf-8") as fout:
        for line in fin:
            fout.write(line)
            total_count += 1
            
            if line.strip() and random.random() < noise_ratio:
                match = re.match(r'^\(([^ \)]+)', line)
                if match:
                    root_name = match.group(1)
                    redundant_name = f"{root_name}_redundant"
                    
                    noisy_line = re.sub(r'(?<=\s|\()' + re.escape(root_name) + r'(?=\s|\))', redundant_name, line)
                    fout.write(noisy_line)
                    duplicated_count += 1

    return duplicated_count, total_count

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python create_noisy_dataset.py <input.metta> <output.metta> [noise_ratio]")
        sys.exit(1)

    in_file = sys.argv[1]
    out_file = sys.argv[2]
    ratio = float(sys.argv[3]) if len(sys.argv) > 3 else 0.2

    generate_noisy_dataset(in_file, out_file, ratio)
