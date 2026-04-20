from pathlib import Path
from typing import Union
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import plotly.express as px
import json
import sys


def resolve_output_root(path_like: Union[str, Path]) -> Path:
    path = Path(path_like).resolve()
    if path.is_file():
        if path.name in {"output.csv", "metrics.csv"} and path.parent.name == "output":
            return path.parent.parent
        return path.parent
    return path

class Plotter:

    def __init__(self, output_path: Union[str, Path]):
        self.output_path = resolve_output_root(output_path)
        self.data_path = self.get_data_path()
        self.params = self.read_params()
        self.categories = self.create_category()
        self.word_to_category = self.create_word_lookup()
        self.data_frame = self.read_csv()
        self.plot()
    
    def get_data_path(self) -> Path:
        data_path = self.output_path / 'data'
        if not data_path.exists() or not data_path.is_dir():
            raise FileNotFoundError(f"No {data_path} directory found")
        file_paths = list(data_path.glob("words.json"))
        if len(file_paths) == 0:
            raise FileNotFoundError(f"No words.json file found at {data_path}")
        elif len(file_paths) > 1:
            raise ValueError(f"Multiple words.json files found at {data_path}")
        return file_paths[0]

    def read_params(self) -> dict:
        settings_path = self.output_path / 'output' / 'settings.json'
        if not settings_path.exists():
            raise FileNotFoundError(f"No {settings_path} found in output directory")
        with open(settings_path, 'r') as f:
            setting_json = json.load(f)
        return setting_json

    def create_category(self) -> dict:
        with open(self.data_path, 'r') as f:
            return json.load(f)

    def create_word_lookup(self) -> dict:
        """Build O(1) lookup map from word to category for fast categorization."""
        lookup = {}
        for category, words in self.categories.items():
            for word in words:
                # Keep first category assignment if duplicates exist.
                if word not in lookup:
                    lookup[word] = category
        return lookup

    def categorize_pattern(self, pattern) -> str:
        word = str(pattern).split()[0].lstrip("(")
        return self.word_to_category.get(word, 'Entered through spreading')

    def read_csv(self) -> pd.DataFrame:
        csv = self.output_path / 'output' / 'output.csv'
        df = pd.read_csv(csv, parse_dates=['timestamp'])
        words = df['pattern'].astype(str).str.extract(r'^\(?([^\s()]+)', expand=False)
        df['category'] = words.map(self.word_to_category).fillna('Entered through spreading')
        df['time_windows'] = df['timestamp'].dt.floor('0.0001s')
        category_counts = df.groupby(['time_windows', 'category']).size().unstack(fill_value=0)
        af_size = int(float(self.params['MAX_AF_SIZE']))
        return category_counts / af_size

    def plot(self) -> None:
        category_counts = self.data_frame

        # === 1. Smoothing ===
        smoothed_counts = category_counts.rolling(window=3, min_periods=1).mean()

        # === 2. Plot all categories (sorted by cumulative frequency) ===
        all_categories = smoothed_counts.sum().sort_values(ascending=False).index
        smoothed_counts = smoothed_counts[all_categories]

        # === 3. Distinct color palette ===
        colors = sns.color_palette("husl", n_colors=len(all_categories))

        # === 4. Faceted Subplots ===
        n_cols = 3
        n_rows = (len(all_categories) + n_cols - 1) // n_cols
        fig_height = max(8, n_rows * 2.2)
        fig, axs = plt.subplots(n_rows, n_cols, figsize=(18, fig_height), sharex=True)
        axs = axs.flatten()

        for i, (category, color) in enumerate(zip(all_categories, colors)):
            axs[i].plot(
                smoothed_counts.index,
                smoothed_counts[category],
                label=category,
                color=color,
                linewidth=1.0,
                alpha=0.9
            )
            axs[i].set_title(category, fontsize=11)
            axs[i].grid(True, linestyle='--', alpha=0.4)
            axs[i].set_ylim(-0.02, 1.02)

        for j in range(len(all_categories), len(axs)):
            fig.delaxes(axs[j])  # Remove unused axes

        fig.suptitle('All Category Frequencies Over Time', fontsize=14)
        fig.supxlabel('Time Window', fontsize=12)
        fig.supylabel(f'Attentional focus size {self.params["MAX_AF_SIZE"]}', fontsize=12)
        plt.xticks(rotation=45)
        plt.tight_layout(rect=[0, 0.03, 1, 0.95])
        plot_file = self.output_path / 'output' / 'plot_faceted.png'
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
                title='Interactive All Category Frequency Over Time'
            )
            html_file = self.output_path / 'output' / 'plot_interactive.html'
            fig.write_html(str(html_file))
            print("Interactive plot saved to", html_file)
        except Exception as e:
            print("Plotly interactive plot failed:", e)


class MetricsPlotter:

    METRIC_COLUMNS = [
        "af_resource",
        "sti_concentration",
        "link_density",
        "connection_ratio",
        "normalized_sti_entropy",
        "retention",
        "p_correlation",
        "modulation",
    ]
    RESAMPLE_RULE = "15s"

    def __init__(self, output_path: Union[str, Path]):
        self.output_path = resolve_output_root(output_path)
        self.metrics_path = self.get_metrics_path()
        self.data_frame = self.read_metrics_csv()
        self.plot()

    def get_metrics_path(self) -> Path:
        metrics_path = self.output_path / "output" / "metrics.csv"
        if not metrics_path.exists():
            raise FileNotFoundError(f"No {metrics_path} found")
        return metrics_path

    def read_metrics_csv(self) -> pd.DataFrame:
        df = pd.read_csv(self.metrics_path, parse_dates=["timestamp"])
        for column in self.METRIC_COLUMNS + ["counter"]:
            if column in df.columns:
                df[column] = pd.to_numeric(df[column], errors="coerce")

        available = [column for column in self.METRIC_COLUMNS if column in df.columns]
        if not available:
            raise ValueError("No expected metric columns found in metrics.csv")

        df = df[["timestamp", "counter", *available]].copy()
        return df

    def plot(self) -> None:
        df = self.data_frame
        metric_columns = [column for column in self.METRIC_COLUMNS if column in df.columns]

        if "timestamp" in df.columns:
            grouped = (
                df.set_index("timestamp")[metric_columns]
                .resample(self.RESAMPLE_RULE)
                .mean()
                .dropna(how="all")
                .reset_index()
            )
            x_axis = "timestamp"
        else:
            grouped = df[["counter", *metric_columns]].copy()
            x_axis = "counter"

        n_cols = 2
        n_rows = (len(metric_columns) + n_cols - 1) // n_cols
        fig, axs = plt.subplots(n_rows, n_cols, figsize=(16, max(6, n_rows * 2.8)), sharex=True)
        axs = axs.flatten()

        colors = sns.color_palette("tab10", n_colors=len(metric_columns))

        for idx, (metric, color) in enumerate(zip(metric_columns, colors)):
            series = grouped[[x_axis, metric]].dropna(subset=[metric]).copy()
            if series.empty:
                axs[idx].set_title(metric, fontsize=11)
                axs[idx].grid(True, linestyle="--", alpha=0.35)
                continue

            series[metric] = series[metric].rolling(window=3, min_periods=1).mean()
            axs[idx].plot(
                series[x_axis],
                series[metric],
                color=color,
                linewidth=1.2,
                alpha=0.95,
            )
            axs[idx].set_title(metric, fontsize=11)
            axs[idx].grid(True, linestyle="--", alpha=0.35)

        for idx in range(len(metric_columns), len(axs)):
            fig.delaxes(axs[idx])

        fig.suptitle("Evaluation Metrics Over Iterations", fontsize=14)
        fig.supxlabel(
            "Iteration Counter" if x_axis == "counter" else f"Timestamp ({self.RESAMPLE_RULE} bins)",
            fontsize=12,
        )
        fig.supylabel("Metric Value", fontsize=12)
        plt.tight_layout(rect=[0, 0.03, 1, 0.95])

        png_path = self.output_path / "output" / "metrics_plot_faceted.png"
        plt.savefig(png_path)
        print("Metrics faceted plot saved to", png_path)

        try:
            long_frames = []
            for metric in metric_columns:
                series = grouped[[x_axis, metric]].dropna(subset=[metric]).copy()
                if series.empty:
                    continue
                series[metric] = series[metric].rolling(window=3, min_periods=1).mean()
                series = series.rename(columns={metric: "Value"})
                series["Metric"] = metric
                long_frames.append(series[[x_axis, "Metric", "Value"]])

            if not long_frames:
                raise ValueError("No metric data available for interactive plotting")

            melted = pd.concat(long_frames, ignore_index=True)
            fig = px.line(
                melted,
                x=x_axis,
                y="Value",
                color="Metric",
                title="Interactive Evaluation Metrics Over Iterations",
            )
            html_path = self.output_path / "output" / "metrics_plot_interactive.html"
            fig.write_html(str(html_path))
            print("Metrics interactive plot saved to", html_path)
        except Exception as error:
            print("Plotly metrics plot failed:", error)

if __name__ == "__main__":
    base_dir = Path(__file__).parent.resolve() 
    if len(sys.argv) >= 2:
        targets = sys.argv[1:]
    else:
        targets = sorted({str(path.parent.parent) for path in base_dir.glob("**/output/output.csv")})

    for target in targets:
        root = resolve_output_root(target)
        try:
            Plotter(root)
        except Exception as error:
            print(f"category plot skipped for {root}: {error}")

        try:
            MetricsPlotter(root)
        except Exception as error:
            print(f"metrics plot skipped for {root}: {error}")
