from datetime import datetime
import os
import csv
import json
from pathlib import Path

METRIC_NAME_MAP = {
    "afResource": "af_resource",
    "stiConcentration": "sti_concentration",
    "fundSti": "fund_sti",
    "linkDensity": "link_density",
    "connectionRatio": "connection_ratio",
    "cognitiveSynergy": "cognitive_synergy",
    "contextRetention": "context_retention",
    "cognitiveMaintenance": "cognitive_maintenance",
    "gainedEfficiency": "gained_efficiency",
    "redundancyDegradation": "redundancy_degradation",
    "triangleCount": "triangle_count",
}

METRIC_COLUMNS = [
    "af_resource",
    "sti_concentration",
    "fund_sti",
    "link_density",
    "connection_ratio",
    "preallocation",
    "cognitive_synergy",
    "modulation",
    "coordination",
    "context_retention",
    "cognitive_maintenance",
    "effectiveness",
    "gained_efficiency",
    "redundancy_degradation",
    "triangle_count",
    "betti0",
    "betti1",
    "betti2",
]


def format_pattern(pat):
    if isinstance(pat, (list, tuple)):
        return f"({' '.join(format_pattern(p) for p in pat)})"
    return str(pat)


def normalize_metric_name(name):
    text = str(name)
    if text in METRIC_NAME_MAP:
        return METRIC_NAME_MAP[text]

    normalized = []
    for index, char in enumerate(text):
        if char.isupper() and index > 0:
            normalized.append("_")
        elif char in {"-", " "}:
            normalized.append("_")
            continue
        normalized.append(char.lower())
    return "".join(normalized)


def metric_pair(metric):
    if isinstance(metric, (list, tuple)) and len(metric) >= 2:
        return metric[0], metric[1]

    try:
        children = metric.get_children()
    except Exception:
        return None

    if len(children) < 2:
        return None

    return children[0], children[1]


def flatten_metrics(metrics):
    values = {}
    try:
        metric_items = iter(metrics)
    except TypeError:
        return values

    for metric in metric_items:
        pair = metric_pair(metric)
        if pair is None:
            continue
        name, value = pair
        column = normalize_metric_name(name)
        values[column] = value

    return values


def metric_arg(default_name, value):
    pair = metric_pair(value)
    if pair is None:
        return normalize_metric_name(default_name), value
    name, metric_value = pair
    return normalize_metric_name(name), metric_value


def append_csv_row(path, header, row):
    with open(path, 'a', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        if os.path.getsize(path) == 0:
            writer.writerow(header)
        writer.writerow(row)


def ordered_metric_columns(values):
    extras = [column for column in values if column not in METRIC_COLUMNS]
    return [
        *[column for column in METRIC_COLUMNS if column in values],
        *extras,
    ]


def write_string_to_csv(filename, data, header=["timestamp", "pattern", "sti"], mode='a'):
    """Append rows to a CSV. `data` is an iterable of (pattern, av) pairs."""
    rows = []
    for pat in data:
        if len(pat)==2:
            pattern, sti = pat
            rows.append([str(datetime.now()), format_pattern(pattern), sti])
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
METRICS_PATH = None
BASELINE_METRICS_CACHE = None


def start_logger(directory):
    """Set up an `output` folder and clear `settings.json` and `output.csv`.

    `directory` may be a string path or an object exposing `get_name()`.
    Returns a Hyperon-style empty result.
    """
    global START_LOGGER_FLAG, LOGGING_DIRECTORY, SETTING_PATH, CSV_PATH, METRICS_PATH
    global BASELINE_METRICS_CACHE, REDUNDANCY_BASELINE_CACHE

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
    METRICS_PATH = log_dir / "metrics.csv"



    SETTING_PATH.write_text("")
    CSV_PATH.write_text("")
    METRICS_PATH.write_text("")

    BASELINE_METRICS_CACHE = None
    REDUNDANCY_BASELINE_CACHE = None
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

    if not START_LOGGER_FLAG or CSV_PATH is None or len(afatoms[0])==0:
        return ['not written']

    write_string_to_csv(str(CSV_PATH), afatoms)
    return ['wrote']


def write_metrics_row(counter, time, af_atoms, af_resource, sti_concentration, link_density, coherance,
                      connection_ratio, normalized_sti_entropy, retention, p_correlation, modulation,
                      global_coordination, effectiveness, gained_efficiency=0.0, redundancy_degradation=0.0):
    
    # Append one metrics row per iteration to metrics.csv.

    global START_LOGGER_FLAG, METRICS_PATH

    if not START_LOGGER_FLAG or METRICS_PATH is None:
        return ['not written']

    metrics = {}
    for name, value in [
        metric_arg("af_resource", af_resource),
        metric_arg("sti_concentration", sti_concentration),
        metric_arg("link_density", link_density),
        metric_arg("coherance", coherance),
        metric_arg("connection_ratio", connection_ratio),
        metric_arg("normalized_sti_entropy", normalized_sti_entropy),
        metric_arg("retention", retention),
        metric_arg("p_correlation", p_correlation),
        metric_arg("modulation", modulation),
        metric_arg("global_coordination", global_coordination),
        metric_arg("effectiveness", effectiveness),
        metric_arg("gained_efficiency", gained_efficiency),
        metric_arg("redundancy_degradation", redundancy_degradation),
    ]:
        metrics[name] = value

    metric_columns = ordered_metric_columns(metrics)
    header = [
        "counter",
        "timestamp",
        "af_atoms",
        *metric_columns,
    ]

    row = [
        str(counter),
        str(time),
        str(af_atoms),
        *[str(metrics.get(column, "")) for column in metric_columns],
    ]

    append_csv_row(METRICS_PATH, header, row)

    return ['wrote']


def write_cip_row(index, time, af_atoms, metrices):
    
    # Append one metrics row per iteration to metrics.csv.

    global START_LOGGER_FLAG, METRICS_PATH

    if not START_LOGGER_FLAG or METRICS_PATH is None:
        return ['not written']

    metrics = flatten_metrics(metrices)
    metric_columns = ordered_metric_columns(metrics)

    header = [
        "cip_index",
        "timestamp",
        "af_atoms",
        *metric_columns,
    ]

    row = [
        str(index),
        str(time),
        str(af_atoms),
        *[str(metrics.get(column, "")) for column in metric_columns],
    ]

    append_csv_row(METRICS_PATH, header, row)

    return ['wrote']

BASELINE_METRICS_CACHE = None
REDUNDANCY_BASELINE_CACHE = None

def _load_baseline_cache():
    global BASELINE_METRICS_CACHE
    if BASELINE_METRICS_CACHE is None:
        csv_path = LOGGING_DIRECTORY / "output" / "baseline_metrics.csv"
        # Fallback to old folder structure
        old_path = LOGGING_DIRECTORY / "baseline" / "output" / "metrics.csv"
        
        target_path = csv_path if csv_path.exists() else old_path

        if target_path.exists():
            with open(target_path, 'r') as f:
                reader = csv.DictReader(f)
                BASELINE_METRICS_CACHE = list(reader)
        else:
            BASELINE_METRICS_CACHE = []

def _load_redundancy_baseline_cache():
    global REDUNDANCY_BASELINE_CACHE

    if REDUNDANCY_BASELINE_CACHE is None:
        csv_path = LOGGING_DIRECTORY / "output" / "redundancy_baseline_metrics.csv"

        if csv_path.exists():
            with open(csv_path, "r") as f:
                reader = csv.DictReader(f)
                REDUNDANCY_BASELINE_CACHE = list(reader)
        else:
            REDUNDANCY_BASELINE_CACHE = []

def get_baseline_effectiveness(index):
    """Load baseline metrics.csv and return the effectiveness at the given step index."""
    _load_baseline_cache()
    idx = int(index)
    if 0 <= idx < len(BASELINE_METRICS_CACHE):
        return float(BASELINE_METRICS_CACHE[idx].get('effectiveness', 0.0))
    return 0.0

def get_baseline_redundancy_data(index):
    """Returns a tuple: (baseline_perf, baseline_cost)"""
    _load_redundancy_baseline_cache()
    idx = int(index)
    if 0 <= idx < len(REDUNDANCY_BASELINE_CACHE):
        row = REDUNDANCY_BASELINE_CACHE[idx]
        af_res = float(row.get('af_resource', 0.0))
        sti_conc = float(row.get('sti_concentration', 0.0))
        link_den = float(row.get('link_density', 0.0))
        effectiveness = float(row.get('effectiveness', 0.0))
        
        # Reverse engineer cost and performance
        baseline_cost = af_res + sti_conc + link_den
        baseline_perf = effectiveness * baseline_cost
        
        return [baseline_perf, baseline_cost]
    return [0.0, 0.0]
