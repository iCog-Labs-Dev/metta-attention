import pandas as pd
import matplotlib.pyplot as plt
from datetime import datetime

# Read the CSV file
df = pd.read_csv('out.csv', parse_dates=['timestamp'])

def create_category():

    file_list = {"insect": "experiments/experiment/data/insect-words.metta", "poison": "experiments/experiment/data/poison-words.metta", "insecticide": "experiments/experiment/data/insecticide-words.metta"}

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
    # if 'similaritylink' in pattern.lower():
    #     patterns = pattern.rstrip(")").split()[1:]
    #     for pt in patterns:
    #         for category, words in word_category.items():
    #             if pt in words:
    #                 return  f"{category}_related"
    
    for category, words in word_category.items():
        if pattern in words:
            return  category

    return 'other'


# Apply categorization
df['category'] = df['pattern'].apply(categorize_pattern)

# Apply time_Window
df['time_window'] = df['timestamp'].dt.floor('10s')

# Sort by timestamp for proper line connections
df = df.sort_values('timestamp')

# Aggregate STI values by timestamp and category (average)
df_agg = df.groupby(['time_window', 'category'])['sti'].sum().unstack()

# Plotting
plt.figure(figsize=(12, 6))


# Plot each category with a different color
categories = df['category'].unique()
colors = ['red', 'blue', 'green', 'purple', 'orange']  # Add more if needed
line_styles = ['-', '--', '-.', ':', '-']

for i, category in enumerate(categories):
    category_df = df[df['category'] == category]
    plt.plot(category_df['timestamp'], category_df['sti'], 
                label=category, 
                color=colors[i],
                linestyle=line_styles[i % len(line_styles)],
                marker='o',  # Optional: add markers to points
                markersize=5,
                alpha=0.7)

plt.xlabel('Timestamp')
plt.ylabel('STI Value')
plt.title('Pattern Categories Over Time')
plt.legend()
plt.grid(True)
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig("group_plot.png")
