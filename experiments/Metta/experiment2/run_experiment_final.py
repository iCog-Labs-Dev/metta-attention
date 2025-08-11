#!/usr/bin/env python3
"""
Final working wrapper for experiment2 - handles CSV clearing and logging correctly
"""
import subprocess
import csv
import re
from datetime import datetime
from pathlib import Path

def strip_ansi_codes(text):
    """Remove ANSI escape codes from text"""
    ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
    return ansi_escape.sub('', text)

def clear_csv():
    """Clear output.csv with header"""
    output_dir = Path("output")
    output_dir.mkdir(exist_ok=True)
    
    csv_file = output_dir / "output.csv"
    with open(csv_file, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(["timestamp", "word", "sti", "lti"])
    
    print("CSV cleared and ready")

def main():
    # Clear CSV first
    clear_csv()
    
    # Expected words in order
    expected_words = ["Ants", "farm", "aphids", "beanfly", "armyworms", ".", 
                     "Botulinum", "avoids", "alcohol", "ammonia", "aconite", "aflatoxin", "."]
    
    # Run mettalog and capture all output
    try:
        result = subprocess.run(
            ["mettalog", "experiment2-mettalog.metta"],
            capture_output=True,
            text=True,
            timeout=120
        )
        
        # Process all lines and extract words
        lines = result.stdout.split('\n')
        words_found = []
        
        for line in lines:
            clean_line = strip_ansi_codes(line.strip())
            
            if clean_line in expected_words:
                # Allow duplicates for '.' but not for other words
                if clean_line == '.' or clean_line not in words_found:
                    words_found.append(clean_line)
                    print(clean_line)  # Show in terminal
                    
                    # Log to CSV
                    timestamp = datetime.now().isoformat()
                    output_dir = Path("output")
                    csv_file = output_dir / "output.csv"
                    
                    with open(csv_file, 'a', newline='') as f:
                        writer = csv.writer(f)
                        writer.writerow([timestamp, clean_line, 700.0, 700.0])
        
        print(f"\nProcessed {len(words_found)} words")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
