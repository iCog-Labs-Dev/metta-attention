
from datetime import datetime
import os
import csv
import json
import sys
from pathlib import Path
def format_pattern(pat):
    if isinstance(pat, (list, tuple)):
        return f"({' '.join(format_pattern(p) for p in pat)})"
    return str(pat)

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


def start_logger(directory):
    """Set up an `output` folder and clear `settings.json` and `output.csv`.

    `directory` may be a string path or an object exposing `get_name()`.
    Returns a Hyperon-style empty result.
    """
    global START_LOGGER_FLAG, LOGGING_DIRECTORY, SETTING_PATH, CSV_PATH, METRICS_PATH

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


def write_metrics_row(counter, time, af_atoms,af_resource, sti_concentration, link_density, coherance,
                      connection_ratio, normalized_sti_entropy, retention, p_correlation, modulation,
                      global_coordination, effectiveness):
    
    # Append one metrics row per iteration to metrics.csv.

    global START_LOGGER_FLAG, METRICS_PATH

    if not START_LOGGER_FLAG or METRICS_PATH is None:
        return ['not written']

    header = [
        "counter",
        "timestamp",
        "af_resource",
        "sti_concentration",
        "link_density",
        "connection_ratio",
        "preallocation",
        "cognitive_synergy",
        "modulation",
        "coordination",
        "context_retention",
        "cognitive_maintenance",
        "effectiveness",
        "af_atoms",
    ]

    row = [
        str(counter),
        str(time),
        str(af_resource[1]),
        str(sti_concentration[1]),
        str(link_density[1]),
        str(coherance[1]),
        str(connection_ratio[1]),
        str(normalized_sti_entropy[1]),
        str(retention[1]),
        str(p_correlation[1]),
        str(modulation[1]),
        str(global_coordination[1]),
        str(effectiveness[1]),
        str(af_atoms),
    ]

    with open(METRICS_PATH, 'a', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        if os.path.getsize(METRICS_PATH) == 0:
            writer.writerow(header)
        writer.writerow(row)

    return ['wrote']


def metric_value(metrics, name, default=""):
    try:
        metric_items = iter(metrics)
    except TypeError:
        return default

    for metric in metric_items:
        if isinstance(metric, (list, tuple)) and len(metric) >= 2 and str(metric[0]) == name:
            return metric[1]

        try:
            key, value = metric.get_children()
        except Exception:
            continue

        if str(key) == name:
            return value

    return default


def topology_metric_values(hebbian_links):
    if hebbian_links is None:
        return None

    topology_dir = Path(__file__).resolve().parent.parent.parent / "attention-bank" / "synapse"
    topology_dir_str = str(topology_dir)
    if topology_dir_str not in sys.path:
        sys.path.insert(0, topology_dir_str)

    from topology_metrics import topology_metrics

    metrics = topology_metrics(hebbian_links)
    return metrics["triangles"], metrics["betti0"], metrics["betti1"]


def metrics_with_topology_values(metrics, triangle_count, betti0, betti1):
    replacements = {
        "trianglecount": triangle_count,
        "betti0": betti0,
        "betti1": betti1,
    }

    try:
        metric_items = list(metrics)
    except TypeError:
        return metrics

    normalized = []
    for metric in metric_items:
        if isinstance(metric, (list, tuple)) and len(metric) >= 2:
            name = str(metric[0])
            if name in replacements:
                normalized.append([metric[0], replacements[name]])
                continue

        normalized.append(metric)

    return normalized


def write_cip_row(index, time, af_atoms, metrices, hebbian_links=None):
    
    # Append one metrics row per iteration to metrics.csv.

    global START_LOGGER_FLAG, METRICS_PATH

    if not START_LOGGER_FLAG or METRICS_PATH is None:
        return ['not written']

    topology_values = topology_metric_values(hebbian_links)
    if topology_values is None:
        triangle_count = metric_value(metrices, "trianglecount")
        betti0 = metric_value(metrices, "betti0")
        betti1 = metric_value(metrices, "betti1")
    else:
        triangle_count, betti0, betti1 = topology_values

    normalized_metrics = metrics_with_topology_values(
        metrices,
        triangle_count,
        betti0,
        betti1,
    )

    header = [
        "cip_index",
        "timestamp",
        "af_atoms",
        "triangle_count",
        "betti_0",
        "betti_1",
        "metrics",
    ]

    row = [
        str(index),
        str(time),
        str(af_atoms),
        str(triangle_count),
        str(betti0),
        str(betti1),
        str(normalized_metrics),
    ]

    with open(METRICS_PATH, 'a', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        if os.path.getsize(METRICS_PATH) == 0:
            writer.writerow(header)
        writer.writerow(row)

    return ['wrote']
