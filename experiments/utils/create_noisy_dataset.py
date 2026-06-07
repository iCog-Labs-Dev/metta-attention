import sys
import random
import re

if len(sys.argv) < 3:
    print("Usage: python create_noisy_dataset.py <input.metta> <output.metta> [noise_ratio]")
    sys.exit(1)

input_file = sys.argv[1]
output_file = sys.argv[2]
noise_ratio = float(sys.argv[3]) if len(sys.argv) > 3 else 0.2

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

print(f"Done! Generated {output_file}.")
print(f"Total original atoms: {total_count}")
print(f"Redundant atoms injected: {duplicated_count}")
