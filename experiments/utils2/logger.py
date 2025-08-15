# Simple logger functions for Mettalog
from pathlib import Path
import os
import json
import csv
from datetime import datetime

# Global state
logger_state = {
    'active': False,
    'csv_path': None,
    'settings_path': None
}

def start_logger(directory):
    """Initialize logger"""
    try:
        # Setup paths
        base_path = Path(__file__).parent.parent.parent
        log_dir = base_path / str(directory).strip("'\"") / "output"
        log_dir.mkdir(parents=True, exist_ok=True)
        
        # Set paths
        logger_state['csv_path'] = log_dir / "output.csv"
        logger_state['settings_path'] = log_dir / "settings.json"
        logger_state['active'] = True
        
        # Clear CSV and write header
        with open(logger_state['csv_path'], 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(['timestamp', 'word', 'sti', 'lti'])
        
        # Clear settings
        with open(logger_state['settings_path'], 'w') as f:
            json.dump({
                "experiment_name": "experiment2-mettalog",
                "experiment_date": datetime.now().strftime('%Y-%m-%d'),
                "experiment_time": datetime.now().isoformat(),
                "status": "running"
            }, f, indent=4)
        
        print(f"Logger initialized: {log_dir}")
        return "logger_started"
    except Exception as e:
        print(f"Logger error: {e}")
        return f"error: {e}"

def log_word_to_csv(word, sti=700.0, lti=700.0):
    """Log a word to CSV"""
    if not logger_state['active'] or not logger_state['csv_path']:
        return "logger_not_active"
    
    try:
        with open(logger_state['csv_path'], 'a', newline='') as f:
            writer = csv.writer(f)
            timestamp = datetime.now().isoformat()
            writer.writerow([timestamp, str(word), float(sti), float(lti)])
        return "word_logged"
    except Exception as e:
        print(f"Log error: {e}")
        return f"error: {e}"

def write_to_csv(data):
    """Write complex data to CSV"""
    if not logger_state['active']:
        return "logger_not_active"
    
    try:
        # Simple data logging
        timestamp = datetime.now().isoformat()
        with open(logger_state['csv_path'], 'a', newline='') as f:
            writer = csv.writer(f)
            writer.writerow([timestamp, str(data), "0.0", "0.0"])
        return "data_written"
    except Exception as e:
        print(f"Write error: {e}")
        return f"error: {e}"

def save_params(params):
    """Save parameters"""
    if not logger_state['active']:
        return "logger_not_active"
    
    try:
        # Update settings with params
        if logger_state['settings_path'] and logger_state['settings_path'].exists():
            with open(logger_state['settings_path'], 'r') as f:
                settings = json.load(f)
            settings['params'] = str(params)
            with open(logger_state['settings_path'], 'w') as f:
                json.dump(settings, f, indent=4)
        return "params_saved"
    except Exception as e:
        print(f"Params error: {e}")
        return f"error: {e}"

print("Simple logger loaded")
