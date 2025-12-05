from pathlib import Path
from typing import Union
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import plotly.express as px
import json
import sys

class Plotter:

    def __init__(self, output_path: Union[str, Path]):
        self.output_path = Path(output_path).parent.resolve()
        self.data_path = self.get_data_path()
        self.params = self.read_params()
        self.categories = self.create_category()
        self.data_frame = self.read_csv()
        self.plot()
    
    def get_data_path(self) -> Path:
        data_path = self.output_path.parent / 'data'
        if not data_path.exists() or not data_path.is_dir():
            raise FileNotFoundError(f"No {data_path} directory found")
        file_paths = list(data_path.glob("words.json"))
        if len(file_paths) == 0:
            raise FileNotFoundError(f"No words.json file found at {data_path}")
        elif len(file_paths) > 1:
            raise ValueError(f"Multiple words.json files found at {data_path}")
        return file_paths[0]

    def read_params(self) -> dict:
        settings_path = self.output_path / 'settings.json'
        if not settings_path.exists():
            raise FileNotFoundError(f"No {settings_path} found in output directory")
        with open(settings_path, 'r') as f:
            setting_json = json.load(f)
        return setting_json

    def create_category(self) -> dict:
        with open(self.data_path, 'r') as f:
            return json.load(f)

    def categorize_pattern(self, pattern) -> str:
        pattern = str(pattern)
        word_category = self.categories
        word = pattern.split()[0].lstrip("(")
        for category, words in word_category.items():
            if word in words:
                return category
        return 'Entered through spreading'

    def read_csv(self) -> pd.DataFrame:
        csv = self.output_path / 'output.csv'
        df = pd.read_csv(csv, parse_dates=['timestamp'])
        df['category'] = df['pattern'].apply(self.categorize_pattern)
        df['time_windows'] = df['timestamp'].dt.floor('0.005s')
        category_counts = df.groupby(['time_windows', 'category']).size().unstack(fill_value=0)
        af_size = int(float(self.params['MAX_AF_SIZE']))
        return category_counts / af_size

    def plot(self) -> None:
        category_counts = self.data_frame

        # === 1. Smoothing ===
        smoothed_counts = category_counts.rolling(window=3, min_periods=1).mean()

        # === 2. Choose top-N categories ===
        N = 6
        top_categories = smoothed_counts.sum().sort_values(ascending=False).head(N).index
        smoothed_counts = smoothed_counts[top_categories]

        # === 3. Distinct color palette ===
        colors = sns.color_palette("tab10", n_colors=len(top_categories))
        markers = ['o', 's', '^', 'D', 'v', 'P']

        # === 4. Faceted Subplots ===
        n_cols = 2
        n_rows = (len(top_categories) + 1) // n_cols
        fig, axs = plt.subplots(n_rows, n_cols, figsize=(14, 7), sharex=True)
        axs = axs.flatten()

        for i, (category, color) in enumerate(zip(top_categories, colors)):
            axs[i].plot(
                smoothed_counts.index,
                smoothed_counts[category],
                label=category,
                color=color,
                marker=markers[i % len(markers)],
                markersize=3,
                linewidth=1.5,
                alpha=0.9
            )
            axs[i].set_title(category, fontsize=11)
            axs[i].grid(True, linestyle='--', alpha=0.4)
            axs[i].set_ylim(-0.02, 1.02)

        for j in range(len(top_categories), len(axs)):
            fig.delaxes(axs[j])  # Remove unused axes

        fig.suptitle('Top Category Frequencies Over Time', fontsize=14)
        fig.supxlabel('Time Window', fontsize=12)
        fig.supylabel(f'Attentional focus size {self.params["MAX_AF_SIZE"]}', fontsize=12)
        plt.xticks(rotation=45)
        plt.tight_layout(rect=[0, 0.03, 1, 0.95])
        plot_file = self.output_path / 'plot_faceted.png'
        plt.savefig(plot_file)
        print("Faceted plot saved to", plot_file)

        # === 5. Optional: Interactive Plotly Plot ===
        try:
            df_reset = smoothed_counts.reset_index().melt(
                id_vars='time_windows', var_name='Category', value_name='Frequency')
            fig = px.line(
                df_reset,
                x='time_windows',
                y='Frequency',
                color='Category',
                title='Interactive Category Frequency Over Time'
            )
            html_file = self.output_path / 'plot_interactive.html'
            fig.write_html(str(html_file))
            print("Interactive plot saved to", html_file)
        except Exception as e:
            print("Plotly interactive plot failed:", e)

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
