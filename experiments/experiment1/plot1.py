import pandas as pd
import matplotlib.pyplot as plt
import json
import sys

# Read the CSV file
if len(sys.argv) >= 2:
    FILE = sys.argv[1]
else:
    FILE = 'output/output.csv'
df = pd.read_csv(FILE, parse_dates=['timestamp'])

def create_category():

    file_list = {"insect": "experiments/experiment1/data/insect-words.metta", "poison": "experiments/experiment1/data/poison-words.metta", "insecticide": "experiments/experiment1/data/insecticide-words.metta"}

    word_category = {key: [] for key in file_list}

    for i in file_list.keys():
        with open(file_list[i], 'r') as f:
            for line in f:
                word_category[i].append(line.split()[1].rstrip(")"))     

    return word_category
    
# Categorize patterns
def categorize_pattern(pattern):
    pattern = str(pattern).lower()
    word_category = create_category()
    
    # Similarity links - check what they link to
    for category, words in word_category.items():
        if pattern in words:
            return  category

    
    return 'Entered through spreading'

def read_params(param:str) -> str:
    """ retrives the string of the passed value from a json file 
        all returns are of type str
    """

    with open('output/settings.json', 'r') as f:
        setting_json = json.load(f)

    return setting_json[param]

# Apply categorization
df['category'] = df['pattern'].apply(categorize_pattern)

# Apply time_Window
df['time_window'] = df['timestamp'].dt.floor('1s')

# Sort by timestamp for proper line connections

# Group by time_window and category, then count occurrences
category_counts = df.groupby(['time_window', 'category']).size().unstack(fill_value=0)

af_size = int(read_params('MAX_AF_SIZE'))
category_counts = category_counts / af_size

plt.figure(figsize=(14, 7))

# Customize colors and markers for each category
colors = ['red', 'blue', 'green', 'purple']
markers = ['o', 's', '^', 'D']  # Circle, square, triangle, diamond

print(category_counts)

for i, category in enumerate(category_counts.columns):
    plt.plot(
        category_counts.index, 
        category_counts[category], 
        label=category,
        color=colors[i % len(colors)],
        marker=markers[i % len(markers)],
        markersize=2,
        linestyle='-',
        linewidth=1,
        alpha=0.8
    )

plt.ylim(-0.02, 1.02)
plt.xlabel('Time Window', fontsize=12)
plt.ylabel(f'Number of Entries for {af_size}', fontsize=12)
plt.title('Category Frequency Over Time', fontsize=14)
plt.legend(title='Category', bbox_to_anchor=(1.05, 1), loc='upper left')
plt.grid(True, linestyle='--', alpha=0.6)
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig("experiments/experiment1/plot1.png")
