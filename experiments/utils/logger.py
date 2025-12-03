
from datetime import datetime
import os
import csv
import json
from pathlib import Path
def write_string_to_csv(filename, data, header=["timestamp", "pattern", "sti", "lti"], mode='a'):
    """Append rows to a CSV. `data` is an iterable of (pattern, av) pairs."""
    rows = []
    for pat in data:
        pattern, av = pat
        AV, sti, lti, vlti = av
        rows.append([str(datetime.now()), pattern if str(type(pattern)) == "<class 'str'>" else pattern[0], sti, lti])
        print()
    with open(filename, mode, newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        if os.path.getsize(filename) == 0:
            writer.writerow(header)
        for row in rows:
            writer.writerow(row)


# Logger state
START_LOGGER_FLAG = False
LOGGING_DIRECTORY = None
SETTING_PATH = None
CSV_PATH = None


def start_logger(directory):
    """Set up an `output` folder and clear `settings.json` and `output.csv`.

    `directory` may be a string path or an object exposing `get_name()`.
    Returns a Hyperon-style empty result.
    """
    global START_LOGGER_FLAG, LOGGING_DIRECTORY, SETTING_PATH, CSV_PATH

    # Accept either string path or an object with get_name()
    if isinstance(directory, str):
        path = directory
    else:
        # try to extract name (for Hyperon Atom-like objects)
        try:
            path = str(directory.get_name())
        except Exception:
            raise TypeError("start_logger accepts a string path or an object with get_name()")

    base_path = Path(__file__).parent.parent.parent
    path_str = Path(base_path / path)

    if path_str.exists() and path_str.is_dir() and os.access(path_str, os.R_OK):
        LOGGING_DIRECTORY = path_str
    else:
        raise ValueError(f"{path_str} can not be resolved")

    log_dir = LOGGING_DIRECTORY / "output"
    log_dir.mkdir(parents=True, exist_ok=True)

    SETTING_PATH = log_dir / "settings.json"
    CSV_PATH = log_dir / "output.csv"



    SETTING_PATH.write_text("")
    CSV_PATH.write_text("")

    START_LOGGER_FLAG = True
    return ['started']


def save_params(params):
    """Save parameter ExpressionAtom into settings.json (merge with existing)."""
    global START_LOGGER_FLAG, SETTING_PATH

    if not START_LOGGER_FLAG:
        return []

    data = {}
    
    for param in params:
        try:
            key, value = param.get_children()
            key = str(key)
            value = str(value)
        except Exception:
            # Fallback: if param is a (key, value) pair
            if isinstance(param, (list, tuple)) and len(param) >= 2:
                key = str(param[0])
                value = str(param[1])
            else:
                # Skip unrecognized items
                continue

        data[key] = value

    if SETTING_PATH.exists():
        with SETTING_PATH.open('r', encoding='utf-8') as f:
            try:
                existing = json.load(f)
            except json.JSONDecodeError:
                existing = {}
        existing.update(data)
    else:
        existing = data

    with SETTING_PATH.open('w', encoding='utf-8') as f:
        json.dump(existing, f, indent=4)

    return ['saved']


def write_to_csv(afatoms):
    """
    Append AF snapshot rows to the configured CSV file.
    """
    global START_LOGGER_FLAG, CSV_PATH

    if  len(afatoms[0])==0 or not START_LOGGER_FLAG or CSV_PATH is None:
        return ['not written']
    write_string_to_csv(str(CSV_PATH), afatoms)
    return ['wrote']

    
    
