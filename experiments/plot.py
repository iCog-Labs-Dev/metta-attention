from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt
import json
import sys

class Plotter:

    def __init__(self, output_path):
        self.output_path = Path(output_path).parent.resolve()
        self.data_path = self.get_data_path()
        self.params = self.read_params()
        self.categories = self.create_category()
        self.data_frame = self.read_csv()
        self.plot()
    
    def get_data_path(self):
        
        data_path = self.output_path.parent / 'data'
        if not data_path.exists() or not data_path.is_dir():
            raise FileNotFoundError(f"No {data_path} directory found")

        file_paths = list(data_path.glob("words.json"))

        if len(file_paths) == 0:
            raise FileNotFoundError(f"No words.json file found at {data_path}")
        elif len(file_paths) > 1:
            raise ValueError(f"Multiple words.json files found at {data_path}")

        return file_paths[0]

    def read_params(self):

        settings_path = self.output_path / 'settings.json' 

        if not settings_path.exists():
            raise FileNotFoundError(f"No {settings_path} found in output directory")

        with open(settings_path, 'r') as f:
            setting_json = json.load(f)

        return setting_json

    def create_category(self):
        word_category = {}

        with open(self.data_path, 'r') as f:
            word_category = json.load(f)

        return word_category

    def categorize_pattern(self, pattern):
        pattern = str(pattern)
        word_category = self.categories
        word = ""

        pattern_list = pattern.split()
        if len(pattern_list) == 1:
            word = pattern_list[0]
        elif len(pattern_list) > 1 :
            word = pattern_list[0].lstrip("(")

        for category, words in word_category.items():
            if word in words:
                return category
            
        return 'Entered through spreading'

    def read_csv(self):

        csv = self.output_path / 'output.csv'
        df = pd.read_csv(csv, parse_dates=['timestamp'])
        df['category'] = df['pattern'].apply(self.categorize_pattern)
        df['time_windows'] = df['timestamp'].dt.floor('1s')
        category_counts = df.groupby(['time_windows', 'category']).size().unstack(fill_value=0)
        af_size = int(float(self.params['MAX_AF_SIZE']))
        category_counts = category_counts / af_size
        return category_counts

    def plot(self):
        
        markers = ['o', 's', '^', 'D']  # Circle, square, triangle, diamond
        category_counts = self.data_frame

        plt.figure(figsize=(14, 7))
        for i, category in enumerate(category_counts.columns):
            plt.plot(
                category_counts.index, 
                category_counts[category], 
                label=category,
                marker=markers[i % len(markers)],
                markersize=2,
                linestyle='-',
                linewidth=1,
                alpha=0.8
            )
            
        plt.ylim(-0.02, 1.02)
        plt.xlabel('Time Window', fontsize=12)
        plt.ylabel(f"Attentional focus size {self.params['MAX_AF_SIZE']}", fontsize=12)
        plt.title('Category Frequency Over Time', fontsize=14)
        plt.legend(title='Category', bbox_to_anchor=(1.05, 1), loc='upper left')
        plt.grid(True, linestyle='--', alpha=0.6)
        plt.xticks(rotation=45)
        plt.tight_layout()
        plot_file = self.output_path / 'plot.png'
        print("plot saved to", plot_file)
        plt.savefig(plot_file)

if __name__ == "__main__":

    base_dir = Path(__file__).parent.resolve() 
    
    if len(sys.argv) >= 2:
        output_csv = sys.argv[1:]
    else:
        output_csv = list(base_dir.glob("**/output.csv"))
    
    for output in output_csv:
        try:
            Plotter(output)
        except Exception as e:
            print(f"caught error: {e} while processing {output}")
            continue

