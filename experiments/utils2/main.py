from pathlib import Path
import os
import json
import csv
import time
import threading
from datetime import datetime

# Global state for logger
logger_state = {
    'start_logger': False,
    'logging_directory': None,
    'setting_path': None,
    'csv_path': None,
    'csv_cleared': False
}

# Background CSV processor
class MettalogCSVProcessor:
    def __init__(self):
        self.running = False
        self.command_file = Path("experiments/Metta/experiment2/output/csv_commands.txt")
        self.csv_file = Path("experiments/Metta/experiment2/output/output.csv")
        self.settings_file = Path("experiments/Metta/experiment2/output/settings.json")
        self.processed_count = 0

    def start_background_processor(self):
        """Start background CSV processor"""
        if self.running:
            return

        self.running = True
        self.processor_thread = threading.Thread(target=self._process_commands, daemon=True)
        self.processor_thread.start()
        print("Background CSV processor started")

    def stop_background_processor(self):
        """Stop background CSV processor"""
        self.running = False
        if hasattr(self, 'processor_thread'):
            self.processor_thread.join(timeout=1)

    def _process_commands(self):
        """Process CSV commands from command file"""
        while self.running:
            try:
                if self.command_file.exists():
                    with open(self.command_file, 'r') as f:
                        lines = f.readlines()

                    # Process new commands
                    new_lines = lines[self.processed_count:]

                    for line in new_lines:
                        line = line.strip()
                        if not line:
                            continue

                        parts = line.split('|')
                        if len(parts) < 1:
                            continue

                        command = parts[0]

                        if command == 'CLEAR':
                            self._clear_and_init_files()
                        elif command == 'WRITE' and len(parts) >= 4:
                            pattern = parts[1]
                            sti = parts[2]
                            lti = parts[3]
                            self._write_csv_entry(pattern, sti, lti)

                        self.processed_count += 1

                time.sleep(0.1)  # Check every 100ms

            except Exception as e:
                print(f"CSV processor error: {e}")
                time.sleep(1)

    def _clear_and_init_files(self):
        """Clear and initialize CSV and settings files"""
        # Ensure directory exists
        self.csv_file.parent.mkdir(parents=True, exist_ok=True)

        # Clear and initialize CSV file
        with open(self.csv_file, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(['timestamp', 'pattern', 'sti', 'lti'])

        # Clear and initialize settings file with original format
        data = {
            "AF_SIZE": "0.2",
            "MIN_AF_SIZE": "500",
            "AFB_DECAY": "0.05",
            "AFB_BOTTOM": "50.0",
            "MAX_AF_SIZE": "12",
            "AFRentFrequency": "2.0",
            "FORGET_THRESHOLD": "0.05",
            "MAX_SIZE": "2",
            "ACC_DIV_SIZE": "1",
            "HEBBIAN_MAX_ALLOCATION_PERCENTAGE": "0.05",
            "LOCAL_FAR_LINK_RATIO": "10.0",
            "MAX_LINK_NUM": "300.0",
            "MAX_SPREAD_PERCENTAGE": "0.4",
            "DIFFUSION_TOURNAMENT_SIZE": "5.0",
            "SPREAD_HEBBIAN_ONLY": "0.0",
            "StartingAtomStiRent": "1.0",
            "StartingAtomLtiRent": "1.0",
            "TARGET_LTI_FUNDS_BUFFER": "10000.0",
            "RENT_TOURNAMENT_SIZE": "5.0",
            "TC_DECAY_RATE": "0.1",
            "DEFAULT_K": "800",
            "SPREADING_FILTER": "(MemberLink (Type \"MemberLink\"))",
            "STARTING_FUNDS_STI": "100000",
            "FUNDS_STI": "100000",
            "STARTING_FUNDS_LTI": "100000",
            "FUNDS_LTI": "100000",
            "STI_FUNDS_BUFFER": "99900",
            "LTI_FUNDS_BUFFER": "99900",
            "TARGET_STI": "99900",
            "TARGET_LTI": "99900",
            "STI_ATOM_WAGE": "10",
            "LTI_ATOM_WAGE": "10",
            "experiment_run_time": datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f'),
            "experiment_date": datetime.now().strftime('%Y-%m-%d'),
            "experiment_status": "running"
        }

        with open(self.settings_file, 'w') as f:
            json.dump(data, f, indent=4)

        print(f"CSV and settings files cleared and initialized")

    def _write_csv_entry(self, pattern, sti, lti):
        """Write a single CSV entry"""
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')

        with open(self.csv_file, 'a', newline='') as f:
            writer = csv.writer(f)
            writer.writerow([timestamp, pattern, sti, lti])

# Global processor instance
csv_processor = MettalogCSVProcessor()

def start_mettalog_logger():
    """Start the mettalog logger system"""
    csv_processor.start_background_processor()

    # Write clear command
    command_file = Path("experiments/Metta/experiment2/output/csv_commands.txt")
    command_file.parent.mkdir(parents=True, exist_ok=True)

    with open(command_file, 'w') as f:
        f.write("CLEAR\n")

    return "logger_started"

def write_mettalog_csv_entry(pattern, sti, lti):
    """Write a CSV entry command for mettalog"""
    command_file = Path("experiments/Metta/experiment2/output/csv_commands.txt")

    with open(command_file, 'a') as f:
        f.write(f"WRITE|{pattern}|{sti}|{lti}\n")

    return "entry_queued"

def stop_mettalog_logger():
    """Stop the mettalog logger system"""
    csv_processor.stop_background_processor()
    return "logger_stopped"

def clear_csv_files_now():
    """Clear CSV and settings files immediately"""
    import subprocess

    try:
        # Call the Python script to clear files
        result = subprocess.run(['python3', 'clear_csv_files.py'],
                              capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            print("Files cleared successfully")
        else:
            print(f"Error clearing files: {result.stderr}")
    except Exception as e:
        print(f"Failed to clear files: {e}")

    return "files_cleared"

def write_csv_entry_now(pattern, sti, lti):
    """Write a CSV entry immediately"""
    import subprocess

    try:
        # Call the Python script to write entry
        result = subprocess.run(['python3', 'write_csv_entry.py', str(pattern), str(sti), str(lti)],
                              capture_output=True, text=True, timeout=5)
        if result.returncode != 0:
            print(f"Error writing CSV entry: {result.stderr}")
    except Exception as e:
        print(f"Failed to write CSV entry: {e}")

    return "entry_written"

def parse_path(file_path: str):
    """Parse and validate the file path - target experiments/Metta/experiment2/output directly"""

    file_path = str(file_path)

    if not isinstance(file_path, str):
        raise TypeError(f"parse_path accepts only str instance {type(file_path)}")

    # Get base path and construct target path
    base_path = Path(__file__).parent.parent.parent

    # Target the specific experiment2 output directory
    if file_path == "experiments":
        target_path = base_path / "experiments" / "Metta" / "experiment2"
    else:
        target_path = base_path / file_path

    if not target_path.exists() or not target_path.is_dir() or not os.access(target_path, os.R_OK):
        raise ValueError(f"{target_path} can not be resolved")

    # Store in global state
    logger_state['logging_directory'] = target_path

    return str(target_path)

def create_file_path(file_path: str):
    """Create file paths for settings.json and output.csv"""

    # Parse the path first
    parse_path(file_path)

    logging_directory = logger_state['logging_directory']
    if not isinstance(logging_directory, Path):
        raise TypeError("Invalid type for logging directory")

    # Use existing output directory (don't create new one)
    log_dir = logging_directory / "output"

    if not log_dir.exists():
        log_dir.mkdir(parents=True, exist_ok=True)

    # Store paths in global state
    logger_state['setting_path'] = log_dir / "settings.json"
    logger_state['csv_path'] = log_dir / "output.csv"

    print(f"writing outputs to {log_dir.resolve()} Directory")

    return f"setting_path = {logger_state['setting_path']}, csv_path = {logger_state['csv_path']}"

def start_logger(directory):
    """Start the logger - ALWAYS clear files and set up for new experiment"""

    # ALWAYS set logger as started and clear files (every run)
    logger_state['start_logger'] = True
    logger_state['csv_cleared'] = False  # Reset for new experiment

    # Parse path and create file paths - clean directory path by removing extra quotes
    clean_directory = str(directory).strip("'\"")
    parse_path(clean_directory)
    create_file_path(clean_directory)

    # ALWAYS clear existing files on every run
    clear_csv()
    clear_settings()

    print(f"Logger started - CSV and settings cleared for new experiment run")
    return "()"

def clear_csv():
    """Clear the CSV file and add header"""

    csv_path = logger_state['csv_path']
    if csv_path:
        # Write CSV header
        with open(csv_path, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(["timestamp", "word", "sti", "lti"])
        logger_state['csv_cleared'] = True

def clear_settings():
    """Clear the settings file"""

    setting_path = logger_state['setting_path']
    if setting_path and setting_path.exists():
        setting_path.write_text("")

def save_params(params_data):
    """Save parameters to settings.json with current timestamp"""

    if not logger_state['start_logger']:
        return "()"

    # Create new experiment data with current timestamp
    current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')
    data = {
        'experiment_name': 'experiment2-mettalog',
        'experiment_date': datetime.now().strftime('%Y-%m-%d'),
        'experiment_time': current_time,
        'experiment_run_id': current_time.replace(' ', '_').replace(':', '-'),
        'experiment_params': str(params_data) if params_data else 'default_params'
    }

    setting_path = logger_state['setting_path']
    if setting_path:
        # ALWAYS create fresh settings file (don't merge with existing)
        with open(setting_path, 'w') as f:
            json.dump(data, f, indent=4)

        print(f"Settings updated with new experiment run: {current_time}")

    return "()"

def log_word_to_csv(word, sti_value=700.0, lti_value=700.0):
    """Log a single word to CSV with timestamp"""

    if not logger_state['start_logger']:
        return "()"

    csv_path = logger_state['csv_path']
    if not csv_path:
        return "()"

    # Ensure CSV is initialized with header
    if not logger_state['csv_cleared']:
        clear_csv()

    # Write the word entry
    timestamp = datetime.now().isoformat()

    try:
        with open(csv_path, 'a', newline='') as f:
            writer = csv.writer(f)
            writer.writerow([timestamp, word, sti_value, lti_value])
    except Exception as e:
        print(f"Error writing to CSV: {e}")

    return "()"

def write_to_csv(afatoms_data):
    """Write attention focus data to CSV - simplified for mettalog"""

    # Always write to the fixed CSV path
    csv_path = Path("experiments/Metta/experiment2/output/output.csv")
    settings_path = Path("experiments/Metta/experiment2/output/settings.json")

    # Ensure directory exists
    csv_path.parent.mkdir(parents=True, exist_ok=True)

    # Check if this is the first call (clear files if so)
    global logger_state
    if not logger_state.get('csv_cleared', False):
        # Clear and initialize CSV file
        with open(csv_path, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(['timestamp', 'pattern', 'sti', 'lti'])

        # Clear and initialize settings file with original format
        current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')
        data = {
            "AF_SIZE": "0.2",
            "MIN_AF_SIZE": "500",
            "AFB_DECAY": "0.05",
            "AFB_BOTTOM": "50.0",
            "MAX_AF_SIZE": "12",
            "AFRentFrequency": "2.0",
            "FORGET_THRESHOLD": "0.05",
            "MAX_SIZE": "2",
            "ACC_DIV_SIZE": "1",
            "HEBBIAN_MAX_ALLOCATION_PERCENTAGE": "0.05",
            "LOCAL_FAR_LINK_RATIO": "10.0",
            "MAX_LINK_NUM": "300.0",
            "MAX_SPREAD_PERCENTAGE": "0.4",
            "DIFFUSION_TOURNAMENT_SIZE": "5.0",
            "SPREAD_HEBBIAN_ONLY": "0.0",
            "StartingAtomStiRent": "1.0",
            "StartingAtomLtiRent": "1.0",
            "TARGET_LTI_FUNDS_BUFFER": "10000.0",
            "RENT_TOURNAMENT_SIZE": "5.0",
            "TC_DECAY_RATE": "0.1",
            "DEFAULT_K": "800",
            "SPREADING_FILTER": "(MemberLink (Type \"MemberLink\"))",
            "STARTING_FUNDS_STI": "100000",
            "FUNDS_STI": "100000",
            "STARTING_FUNDS_LTI": "100000",
            "FUNDS_LTI": "100000",
            "STI_FUNDS_BUFFER": "99900",
            "LTI_FUNDS_BUFFER": "99900",
            "TARGET_STI": "99900",
            "TARGET_LTI": "99900",
            "STI_ATOM_WAGE": "10",
            "LTI_ATOM_WAGE": "10",
            "experiment_run_time": current_time,
            "experiment_date": datetime.now().strftime('%Y-%m-%d'),
            "experiment_status": "running"
        }

        with open(settings_path, 'w') as f:
            json.dump(data, f, indent=4)

        logger_state['csv_cleared'] = True
        print("CSV and settings files cleared and initialized")

    # Now write the CSV data
    with open(csv_path, 'a', newline='') as f:
        writer = csv.writer(f)

        # Process the attention focus data
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')

        # Parse the attention focus data from mettalog
        data_str = str(afatoms_data)

        # Try to extract atom information from the string representation
        # Expected format: ((atom1 (AV vlti1 sti lti vlti2)) (atom2 (AV vlti1 sti lti vlti2)) ...)
        if '(' in data_str and 'AV' in data_str:
            # Parse multiple atoms
            import re

            # Find all atom patterns like (atom_name (AV vlti1 sti lti vlti2))
            atom_pattern = r'\(([^()]+)\s+\(AV\s+[^\s]+\s+([^\s]+)\s+([^\s]+)\s+[^\s]+\)\)'
            matches = re.findall(atom_pattern, data_str)

            if matches:
                for match in matches:
                    pattern, sti, lti = match
                    pattern = pattern.strip()
                    try:
                        sti_val = float(sti)
                        lti_val = float(lti)
                        writer.writerow([timestamp, pattern, sti_val, lti_val])
                        # Removed terminal output - only write to CSV file
                    except ValueError:
                        # If parsing fails, write as strings
                        writer.writerow([timestamp, pattern, sti, lti])
                        # Removed terminal output - only write to CSV file
            else:
                # Fallback: write the raw data
                writer.writerow([timestamp, data_str, "0.0", "0.0"])
                # Removed terminal output - only write to CSV file
        else:
            # Simple case: just write the data as pattern
            writer.writerow([timestamp, data_str, "0.0", "0.0"])
            # Removed terminal output - only write to CSV file

    return "wrote"

def clear_csv_file():
    """Clear the CSV file and write header"""

    csv_path = Path("experiments/Metta/experiment2/output/output.csv")
    csv_path.parent.mkdir(parents=True, exist_ok=True)

    with open(csv_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['timestamp', 'pattern', 'sti', 'lti'])

    print(f"CSV file cleared and initialized: {csv_path}")
    return "cleared"

def write_single_entry(pattern, sti, lti):
    """Write a single CSV entry"""

    csv_path = Path("experiments/Metta/experiment2/output/output.csv")
    csv_path.parent.mkdir(parents=True, exist_ok=True)

    # Check if file exists and has header
    file_exists = csv_path.exists() and csv_path.stat().st_size > 0

    with open(csv_path, 'a', newline='') as f:
        writer = csv.writer(f)

        # Write header if file is empty
        if not file_exists:
            writer.writerow(['timestamp', 'pattern', 'sti', 'lti'])

        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')
        writer.writerow([timestamp, str(pattern), str(sti), str(lti)])
        print(f"Single CSV entry written: {timestamp},{pattern},{sti},{lti}")

    return "wrote"

def queue_csv_clear():
    """Queue a CSV clear request"""

    queue_file = Path("experiments/Metta/experiment2/output/csv_queue.json")
    queue_file.parent.mkdir(parents=True, exist_ok=True)

    # Load existing queue
    queue_data = {'requests': []}
    if queue_file.exists():
        try:
            with open(queue_file, 'r') as f:
                queue_data = json.load(f)
        except:
            queue_data = {'requests': []}

    # Add clear request
    queue_data['requests'].append({'action': 'clear'})

    # Save queue
    with open(queue_file, 'w') as f:
        json.dump(queue_data, f)

    print("CSV clear request queued")
    return "queued"

def queue_csv_write(data):
    """Queue a CSV write request"""

    queue_file = Path("experiments/Metta/experiment2/output/csv_queue.json")
    queue_file.parent.mkdir(parents=True, exist_ok=True)

    # Load existing queue
    queue_data = {'requests': []}
    if queue_file.exists():
        try:
            with open(queue_file, 'r') as f:
                queue_data = json.load(f)
        except:
            queue_data = {'requests': []}

    # Add write request
    queue_data['requests'].append({
        'action': 'write_data',
        'data': str(data)
    })

    # Save queue
    with open(queue_file, 'w') as f:
        json.dump(queue_data, f)

    print(f"CSV write request queued: {str(data)[:100]}...")
    return "queued"

def queue_single_entry(pattern, sti, lti):
    """Queue a single CSV entry request"""

    queue_file = Path("experiments/Metta/experiment2/output/csv_queue.json")
    queue_file.parent.mkdir(parents=True, exist_ok=True)

    # Load existing queue
    queue_data = {'requests': []}
    if queue_file.exists():
        try:
            with open(queue_file, 'r') as f:
                queue_data = json.load(f)
        except:
            queue_data = {'requests': []}

    # Add single entry request
    queue_data['requests'].append({
        'action': 'write_single',
        'pattern': str(pattern),
        'sti': str(sti),
        'lti': str(lti)
    })

    # Save queue
    with open(queue_file, 'w') as f:
        json.dump(queue_data, f)

    print(f"Single CSV entry queued: {pattern},{sti},{lti}")
    return "queued"
