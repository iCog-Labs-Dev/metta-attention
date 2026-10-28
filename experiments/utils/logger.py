from datetime import datetime
import os
import csv
import json
from pathlib import Path


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
    """Auto-convert any metric name to clean snake_case."""
    text = str(name)
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
    """Extract a (name, value) pair from a MeTTa expression or plain tuple."""
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
    """Convert an iterable of metric pairs into an ordered dict of {column: value}.
    Preserves the insertion order from MeTTa so the CSV columns match
    """
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


def append_csv_row(path, header, row):
    """Append a single row to a CSV, writing the header if the file is empty."""
    with open(path, "a", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)
        if os.path.getsize(path) == 0:
            writer.writerow(header)
        writer.writerow(row)


def write_string_to_csv(
    filename, data, header=["timestamp", "pattern", "sti"], mode="a"
):
    """Append rows to a CSV. `data` is an iterable of (pattern, av) pairs."""
    rows = []
    for pat in data:
        if len(pat) == 2:
            pattern, sti = pat
            rows.append([str(datetime.now()), format_pattern(pattern), sti])
    with open(filename, mode, newline="", encoding="utf-8") as file:
        writer = csv.writer(file)
        if os.path.getsize(filename) == 0:
            writer.writerow(header)
        for row in rows:
            writer.writerow(row)


START_LOGGER_FLAG = False
LOGGING_DIRECTORY = None
SETTING_PATH = None
CSV_PATH = None
METRICS_PATH = None
BASELINE_METRICS_CACHE = None
REDUNDANCY_BASELINE_CACHE = None

EFFICIENCY_BASELINE_PATH = None
REDUNDANCY_BASELINE_PATH = None


def start_logger(
    run_name, efficiency_baseline_name=None, redundancy_baseline_name=None
):
    """Set up an `output` folder for the experiment and load baseline metrics if provided.

    `run_name` is the name of the current experiment run.
    `efficiency_baseline_name` (optional) is the baseline run to compare efficiency against.
    `redundancy_baseline_name` (optional) is the baseline run to compare redundancy against.
    Returns a Hyperon-style empty result.
    """
    global START_LOGGER_FLAG, LOGGING_DIRECTORY, SETTING_PATH, CSV_PATH, METRICS_PATH
    global \
        EFFICIENCY_BASELINE_PATH, \
        REDUNDANCY_BASELINE_PATH, \
        BASELINE_METRICS_CACHE, \
        REDUNDANCY_BASELINE_CACHE

    if isinstance(run_name, str):
        r_name = run_name
    else:
        try:
            r_name = str(run_name.get_name())
        except Exception:
            raise TypeError("start_logger accepts a string for run_name")

    b_name = None
    if efficiency_baseline_name is not None:
        if isinstance(efficiency_baseline_name, str):
            b_name = efficiency_baseline_name
        else:
            try:
                b_name = str(efficiency_baseline_name.get_name())
            except Exception:
                pass

    r_b_name = None
    if redundancy_baseline_name is not None:
        if isinstance(redundancy_baseline_name, str):
            r_b_name = redundancy_baseline_name
        else:
            try:
                r_b_name = str(redundancy_baseline_name.get_name())
            except Exception:
                pass

    base_path = Path(__file__).parent.parent.parent / "experiments" / "output"

    log_dir = base_path / r_name
    log_dir.mkdir(parents=True, exist_ok=True)

    LOGGING_DIRECTORY = log_dir

    SETTING_PATH = log_dir / "settings.json"
    CSV_PATH = log_dir / "output.csv"
    METRICS_PATH = log_dir / "metrics.csv"

    SETTING_PATH.write_text("")
    CSV_PATH.write_text("")
    METRICS_PATH.write_text("")

    BASELINE_METRICS_CACHE = None
    REDUNDANCY_BASELINE_CACHE = None

    if b_name:
        EFFICIENCY_BASELINE_PATH = base_path / b_name / "metrics.csv"
    else:
        EFFICIENCY_BASELINE_PATH = None

    if r_b_name:
        REDUNDANCY_BASELINE_PATH = base_path / r_b_name / "metrics.csv"
    else:
        REDUNDANCY_BASELINE_PATH = None

    START_LOGGER_FLAG = True
    return ["started"]


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
        with SETTING_PATH.open("r", encoding="utf-8") as f:
            try:
                existing = json.load(f)
            except json.JSONDecodeError:
                existing = {}
        existing.update(data)
    else:
        existing = data

    with SETTING_PATH.open("w", encoding="utf-8") as f:
        json.dump(existing, f, indent=4)

    return ["saved"]


def write_to_csv(afatoms):
    """Append AF snapshot rows to the configured CSV file."""
    global START_LOGGER_FLAG, CSV_PATH

    if not START_LOGGER_FLAG or CSV_PATH is None or len(afatoms[0]) == 0:
        return ["not written"]

    write_string_to_csv(str(CSV_PATH), afatoms)
    return ["wrote"]


def write_cip_row(index, time, af_atoms, metrices):
    """Append one dynamically-structured metrics row to metrics.csv."""
    global START_LOGGER_FLAG, METRICS_PATH

    if not START_LOGGER_FLAG or METRICS_PATH is None:
        return ["not written"]

    metrics = flatten_metrics(metrices)

    # Sort columns to enforce visual order (unknown metrics go to the end)
    metric_columns = sorted(
        metrics.keys(),
        key=lambda k: (
            METRIC_COLUMNS.index(k) if k in METRIC_COLUMNS else len(METRIC_COLUMNS) + 1
        ),
    )

    header = [
        "cip_index",
        "timestamp",
        *metric_columns,
        "af_atoms",
    ]

    row = [
        str(index),
        str(time),
        *[str(metrics.get(column, "")) for column in metric_columns],
        str(af_atoms),
    ]

    append_csv_row(METRICS_PATH, header, row)
    return ["wrote"]


def _load_baseline_cache():
    global BASELINE_METRICS_CACHE, EFFICIENCY_BASELINE_PATH
    if BASELINE_METRICS_CACHE is None:
        csv_path = (
            EFFICIENCY_BASELINE_PATH
            if EFFICIENCY_BASELINE_PATH
            else LOGGING_DIRECTORY / "output" / "baseline_metrics.csv"
        )
        # Fallback to old folder structure
        old_path = LOGGING_DIRECTORY / "baseline" / "output" / "metrics.csv"

        target_path = csv_path if (csv_path and csv_path.exists()) else old_path

        if target_path and target_path.exists():
            with open(target_path, "r", encoding="utf-8") as f:
                reader = csv.DictReader(f)
                BASELINE_METRICS_CACHE = list(reader)
        else:
            BASELINE_METRICS_CACHE = []


def _load_redundancy_baseline_cache():
    global REDUNDANCY_BASELINE_CACHE, REDUNDANCY_BASELINE_PATH

    if REDUNDANCY_BASELINE_CACHE is None:
        csv_path = (
            REDUNDANCY_BASELINE_PATH
            if REDUNDANCY_BASELINE_PATH
            else LOGGING_DIRECTORY / "output" / "redundancy_baseline_metrics.csv"
        )

        if csv_path and csv_path.exists():
            with open(csv_path, "r", encoding="utf-8") as f:
                reader = csv.DictReader(f)
                REDUNDANCY_BASELINE_CACHE = list(reader)
        else:
            REDUNDANCY_BASELINE_CACHE = []


def get_baseline_effectiveness(index):
    """Load baseline metrics.csv and return the effectiveness at the given step index."""
    _load_baseline_cache()
    idx = int(index)
    if BASELINE_METRICS_CACHE and 0 <= idx < len(BASELINE_METRICS_CACHE):
        return float(BASELINE_METRICS_CACHE[idx].get("effectiveness", 0.0))
    return 0.0


def get_baseline_redundancy_data(index):
    """Returns a tuple: (baseline_perf, baseline_cost)"""
    _load_redundancy_baseline_cache()
    idx = int(index)
    if REDUNDANCY_BASELINE_CACHE and 0 <= idx < len(REDUNDANCY_BASELINE_CACHE):
        row = REDUNDANCY_BASELINE_CACHE[idx]
        af_res = float(row.get("af_resource", 0.0))
        sti_conc = float(row.get("sti_concentration", 0.0))
        link_den = float(row.get("link_density", 0.0))
        effectiveness = float(row.get("effectiveness", 0.0))

        # Reverse engineer cost and performance
        baseline_cost = af_res + sti_conc + link_den
        baseline_perf = effectiveness * baseline_cost

        return [baseline_perf, baseline_cost]
    return [0.0, 0.0]
