# ============================================================================
# METTALOG-COMPATIBLE LOGGER SYSTEM
# ============================================================================
# Converted from Metta-compatible logger.py to work with Mettalog's py-atom system
# Key differences from Metta version:
# 1. No @register_atoms decorator - Mettalog uses py-atom direct calls
# 2. No OperationAtom classes - Simple function definitions
# 3. No ExpressionAtom/S() wrappers - Direct string/value handling
# 4. Simple return values instead of [S('()')] format
# 5. Global state management for cross-call persistence
# 6. Direct function calls instead of class-based operations

from pathlib import Path
import os
import json
import csv
from datetime import datetime

# ============================================================================
# GLOBAL STATE MANAGEMENT FOR METTALOG
# ============================================================================
# Mettalog doesn't maintain object state between py-atom calls,
# so we use global variables to persist logger state across function calls
logger_state = {
    'start_logger': False,        # Whether logging is active
    'logging_directory': None,    # Base directory for logging
    'setting_path': None,         # Path to settings.json file
    'csv_path': None,            # Path to output.csv file
    'csv_cleared': False         # Whether CSV has been cleared this session
}

# ============================================================================
# PATH PARSING AND VALIDATION
# ============================================================================
def parse_path(file_path: str) -> str:
    """
    Parse and validate file path for Mettalog compatibility
    
    Args:
        file_path (str): Directory path relative to project root
        
    Returns:
        str: Absolute path to the validated directory
        
    Raises:
        TypeError: If file_path is not a string
        ValueError: If path cannot be resolved or accessed
        
    Note: This function stores the validated path in global state
    for use by other logger functions
    """
    # Convert to string and validate type
    file_path = str(file_path)
    
    if not isinstance(file_path, str):
        raise TypeError(f"parse_path accepts only str instance, got {type(file_path)}")
    
    # Calculate base path (3 levels up from this file)
    # Assumes structure: project_root/experiments/utils2/main.py
    base_path = Path(__file__).parent.parent.parent
    
    # Construct full path
    path_str = base_path / file_path
    
    # Validate path exists, is directory, and is readable
    if not path_str.exists() or not path_str.is_dir() or not os.access(path_str, os.R_OK):
        raise ValueError(f"{path_str} cannot be resolved or accessed")
    
    # Store in global state for other functions to use
    logger_state['logging_directory'] = path_str
    
    return str(path_str)

# ============================================================================
# FILE PATH CREATION AND SETUP
# ============================================================================
def create_file_path(file_path: str) -> str:
    """
    Create and setup file paths for logging output
    
    Args:
        file_path (str): Directory path to setup for logging
        
    Returns:
        str: Formatted string with created file paths
        
    Note: Creates 'output' subdirectory and sets up paths for
    settings.json and output.csv files
    """
    # First parse and validate the path
    parse_path(file_path)
    
    # Get the validated directory from global state
    logging_directory = logger_state['logging_directory']
    if not isinstance(logging_directory, Path):
        raise TypeError("Invalid type for logging directory")
    
    # Create output subdirectory
    log_dir = logging_directory / "output"
    
    # Create directory if it doesn't exist
    if not log_dir.exists():
        log_dir.mkdir(parents=True, exist_ok=True)
    
    # Store file paths in global state
    logger_state['setting_path'] = log_dir / "settings.json"
    logger_state['csv_path'] = log_dir / "output.csv"
    
    # Print confirmation message
    print(f"Writing outputs to {log_dir.resolve()} Directory")
    
    # Return formatted path information
    return f"setting_path = {logger_state['setting_path']}, csv_path = {logger_state['csv_path']}"

# ============================================================================
# LOGGER INITIALIZATION AND CONTROL
# ============================================================================
def start_logger(directory: str) -> str:
    """
    Initialize the logger system for a new experiment run
    
    Args:
        directory (str): Directory path for logging output
        
    Returns:
        str: Success confirmation message
        
    Note: This function:
    1. Activates logging globally
    2. Sets up file paths
    3. Clears existing CSV and settings files
    4. Prepares for new experiment data
    """
    # Activate logging globally
    logger_state['start_logger'] = True
    logger_state['csv_cleared'] = False  # Reset for new experiment
    
    # Clean directory path (remove any extra quotes)
    clean_directory = str(directory).strip("'\"")
    
    # Setup paths and create directories
    parse_path(clean_directory)
    create_file_path(clean_directory)
    
    # Clear existing files for fresh start
    clear_csv()
    clear_settings()
    
    print(f"Logger started - CSV and settings cleared for new experiment run")
    return "logger_started"

def clear_csv() -> str:
    """
    Clear CSV file and write header row
    
    Returns:
        str: Success confirmation
        
    Note: Creates new CSV file with proper header:
    timestamp, word, sti, lti
    """
    csv_path = logger_state['csv_path']
    if csv_path:
        # Write CSV with header row
        with open(csv_path, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(["timestamp", "word", "sti", "lti"])
        logger_state['csv_cleared'] = True
        print(f"CSV file cleared and initialized: {csv_path}")
    
    return "csv_cleared"

def clear_settings() -> str:
    """
    Clear settings file
    
    Returns:
        str: Success confirmation
        
    Note: Completely empties the settings.json file
    """
    setting_path = logger_state['setting_path']
    if setting_path and setting_path.exists():
        setting_path.write_text("")
        print(f"Settings file cleared: {setting_path}")
    
    return "settings_cleared"

# ============================================================================
# PARAMETER SAVING AND CONFIGURATION
# ============================================================================
def save_params(params_data: str) -> str:
    """
    Save experiment parameters to settings.json file
    
    Args:
        params_data (str): Parameter data to save (can be any format)
        
    Returns:
        str: Success confirmation
        
    Note: Creates a new settings file with experiment metadata
    and parameter information. Each run gets a unique timestamp.
    """
    # Only save if logging is active
    if not logger_state['start_logger']:
        return "logging_not_active"
    
    # Generate current timestamp for this experiment run
    current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')
    
    # Create experiment metadata
    data = {
        'experiment_name': 'experiment2-mettalog',
        'experiment_date': datetime.now().strftime('%Y-%m-%d'),
        'experiment_time': current_time,
        'experiment_run_id': current_time.replace(' ', '_').replace(':', '-'),
        'experiment_params': str(params_data) if params_data else 'default_params',
        'experiment_status': 'running'
    }
    
    # Write to settings file
    setting_path = logger_state['setting_path']
    if setting_path:
        # Always create fresh settings file (don't merge with existing)
        with open(setting_path, 'w') as f:
            json.dump(data, f, indent=4)
        
        print(f"Settings updated with new experiment run: {current_time}")
    
    return "params_saved"

# ============================================================================
# CSV LOGGING FUNCTIONS
# ============================================================================
def log_word_to_csv(word: str, sti_value: float = 700.0, lti_value: float = 700.0) -> str:
    """
    Log a single word to CSV with timestamp and attention values
    
    Args:
        word (str): The word to log
        sti_value (float): Short-term importance value (default: 700.0)
        lti_value (float): Long-term importance value (default: 700.0)
        
    Returns:
        str: Success confirmation
        
    Note: This is the main function called by Mettalog's py-atom system
    to log individual words during experiment execution
    """
    # Only log if logging is active
    if not logger_state['start_logger']:
        return "logging_not_active"
    
    csv_path = logger_state['csv_path']
    if not csv_path:
        return "csv_path_not_set"
    
    # Ensure CSV is initialized with header
    if not logger_state['csv_cleared']:
        clear_csv()
    
    # Generate timestamp for this entry
    timestamp = datetime.now().isoformat()
    
    try:
        # Append word entry to CSV file
        with open(csv_path, 'a', newline='') as f:
            writer = csv.writer(f)
            writer.writerow([timestamp, word, sti_value, lti_value])
        
        # Optional: Print confirmation (can be removed for cleaner output)
        # print(f"Logged word: {word} (STI: {sti_value}, LTI: {lti_value})")
        
    except Exception as e:
        print(f"Error writing to CSV: {e}")
        return f"error: {e}"
    
    return "word_logged"

def write_to_csv(afatoms_data: str) -> str:
    """
    Write complex attention focus data to CSV
    
    Args:
        afatoms_data (str): Attention focus atoms data from Mettalog
        
    Returns:
        str: Success confirmation
        
    Note: This function handles complex attention data structures
    and parses them into individual CSV entries. It's designed to work
    with Mettalog's string-based data passing.
    """
    # Always write to the fixed CSV path for experiment2
    csv_path = Path("experiments/Metta/experiment2/output/output.csv")
    settings_path = Path("experiments/Metta/experiment2/output/settings.json")
    
    # Ensure directory exists
    csv_path.parent.mkdir(parents=True, exist_ok=True)
    
    # Check if this is the first call (clear files if so)
    if not logger_state.get('csv_cleared', False):
        # Initialize CSV file with header
        with open(csv_path, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(['timestamp', 'pattern', 'sti', 'lti'])
        
        # Initialize settings file with experiment metadata
        current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')
        settings_data = {
            "experiment_name": "experiment2-mettalog",
            "experiment_date": datetime.now().strftime('%Y-%m-%d'),
            "experiment_run_time": current_time,
            "experiment_status": "running",
            "data_format": "attention_focus_atoms"
        }
        
        with open(settings_path, 'w') as f:
            json.dump(settings_data, f, indent=4)
        
        logger_state['csv_cleared'] = True
        print("CSV and settings files initialized for attention focus data")
    
    # Process and write the attention focus data
    with open(csv_path, 'a', newline='') as f:
        writer = csv.writer(f)
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')
        
        # Parse attention focus data from Mettalog string format
        data_str = str(afatoms_data)
        
        # Try to extract atom information from string representation
        # Expected format: ((atom1 (AV vlti1 sti lti vlti2)) (atom2 (AV vlti1 sti lti vlti2)) ...)
        if '(' in data_str and 'AV' in data_str:
            import re
            
            # Find all atom patterns like (atom_name (AV vlti1 sti lti vlti2))
            atom_pattern = r'\(([^()]+)\s+\(AV\s+[^\s]+\s+([^\s]+)\s+([^\s]+)\s+[^\s]+\)\)'
            matches = re.findall(atom_pattern, data_str)
            
            if matches:
                # Process each matched atom
                for match in matches:
                    pattern, sti, lti = match
                    pattern = pattern.strip()
                    try:
                        # Convert to float values
                        sti_val = float(sti)
                        lti_val = float(lti)
                        writer.writerow([timestamp, pattern, sti_val, lti_val])
                    except ValueError:
                        # If parsing fails, write as strings
                        writer.writerow([timestamp, pattern, sti, lti])
            else:
                # Fallback: write raw data
                writer.writerow([timestamp, data_str, "0.0", "0.0"])
        else:
            # Simple case: write data as pattern
            writer.writerow([timestamp, data_str, "0.0", "0.0"])
    
    return "attention_data_written"

# ============================================================================
# UTILITY FUNCTIONS FOR METTALOG INTEGRATION
# ============================================================================
def get_logger_status() -> str:
    """
    Get current logger status
    
    Returns:
        str: JSON string with current logger state
    """
    status = {
        'logging_active': logger_state['start_logger'],
        'csv_cleared': logger_state['csv_cleared'],
        'logging_directory': str(logger_state['logging_directory']) if logger_state['logging_directory'] else None,
        'csv_path': str(logger_state['csv_path']) if logger_state['csv_path'] else None,
        'settings_path': str(logger_state['setting_path']) if logger_state['setting_path'] else None
    }
    return json.dumps(status, indent=2)

def reset_logger() -> str:
    """
    Reset logger to initial state
    
    Returns:
        str: Success confirmation
    """
    global logger_state
    logger_state = {
        'start_logger': False,
        'logging_directory': None,
        'setting_path': None,
        'csv_path': None,
        'csv_cleared': False
    }
    return "logger_reset"

# ============================================================================
# METTALOG INTEGRATION CONFIRMATION
# ============================================================================
# Print confirmation that the module is loaded
# This helps with debugging Mettalog imports
print("Mettalog-compatible logger system loaded successfully")
print("Available functions:")
print("  - parse_path(file_path)")
print("  - create_file_path(file_path)")
print("  - start_logger(directory)")
print("  - log_word_to_csv(word, sti_value, lti_value)")
print("  - write_to_csv(afatoms_data)")
print("  - save_params(params_data)")
print("  - clear_csv()")
print("  - clear_settings()")
print("  - get_logger_status()")
print("  - reset_logger()")

# ============================================================================
# DIRECT FUNCTION EXPORTS FOR METTALOG
# ============================================================================
# Export functions directly to module level for easier py-atom access
__all__ = [
    'parse_path', 'create_file_path', 'start_logger', 'log_word_to_csv',
    'write_to_csv', 'save_params', 'clear_csv', 'clear_settings',
    'get_logger_status', 'reset_logger'
]