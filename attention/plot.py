import matplotlib.pyplot as plt
import pandas as pd
import glob
import os

def get_csv_name():
    # Define the directory
    directory = 'csv'  # or './csv'
    latest_file = ''

    # Get list of all CSV files in the directory
    csv_files = glob.glob(os.path.join(directory, '*.csv'))

    if not csv_files:
        print("No CSV files found.")
    else:
        # Find the most recently modified CSV file
        latest_file = max(csv_files, key=os.path.getmtime)

        print(f"Reading latest file: {latest_file}")

    return latest_file

def read_csv():

    file_name = get_csv_name()
    df = pd.read_csv(file_name, parse_dates=["timestamp"])

    # Pivot the data so each pattern is a column and timestamps are the index
    pivot_df = df.pivot(index="timestamp", columns="pattern", values="sti")

    # Plot each pattern over time
    pivot_df.plot(marker='o', figsize=(12, 6))
    plt.xlabel("Timestamp")
    plt.ylabel("STI")
    plt.title("STI Over Time by Pattern")
    plt.legend(title="Pattern", bbox_to_anchor=(1.05, 1), loc='upper left')
    plt.tight_layout()
    plt.grid(True)
    plt.savefig("sti_plot.png")

if __name__ == "__main__":
    print(get_csv_name())
    read_csv()
