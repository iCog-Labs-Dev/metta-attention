#!/usr/bin/env python3
"""
Simple CSV logger that works with Mettalog
Implements Metta-compatible CSV clearing and writing behavior
"""
import os
import csv
import json
from datetime import datetime
from pathlib import Path

def clear_and_init_csv():
    """Clear CSV and initialize with header - Metta behavior"""
    try:
        # Create output directory
        output_dir = Path("experiments/Metta/experiment2/output")
        output_dir.mkdir(parents=True, exist_ok=True)
        
        # Clear and initialize CSV
        csv_path = output_dir / "output.csv"
        with open(csv_path, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(['timestamp', 'word', 'sti', 'lti'])
        
        # Initialize settings
        settings_path = output_dir / "settings.json"
        with open(settings_path, 'w') as f:
            json.dump({
                "experiment": "experiment2-mettalog",
                "date": datetime.now().strftime('%Y-%m-%d'),
                "time": datetime.now().isoformat(),
                "status": "running"
            }, f, indent=2)
        
        return "initialized"
    except Exception as e:
        return f"error: {e}"

def log_word_to_csv(word, sti=700.0, lti=700.0):
    """Log word to CSV file"""
    try:
        csv_path = Path("experiments/Metta/experiment2/output/output.csv")
        if csv_path.exists():
            with open(csv_path, 'a', newline='') as f:
                writer = csv.writer(f)
                timestamp = datetime.now().isoformat()
                writer.writerow([timestamp, str(word), float(sti), float(lti)])
        return "logged"
    except Exception as e:
        return f"error: {e}"

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        if sys.argv[1] == "clear":
            print(clear_and_init_csv())
        elif sys.argv[1] == "log" and len(sys.argv) >= 3:
            word = sys.argv[2]
            sti = float(sys.argv[3]) if len(sys.argv) > 3 else 700.0
            lti = float(sys.argv[4]) if len(sys.argv) > 4 else 700.0
            print(log_word_to_csv(word, sti, lti))
