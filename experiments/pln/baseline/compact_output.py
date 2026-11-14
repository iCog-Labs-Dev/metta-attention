import csv
import hashlib
import io
import json
import os
from pathlib import Path
import shutil

from run_baseline import QUERY_FIELDS, RUN_FIELDS, STEP_FIELDS, TRACE_FIELDS


TABLES = {
    "runs.csv": RUN_FIELDS,
    "query_results.csv": QUERY_FIELDS,
    "task_trace.csv": TRACE_FIELDS,
    "step_metrics.csv": STEP_FIELDS,
}
SHARED_FIELDS = (
    "schema_version", "condition", "petta_path", "python", "platform", "questions",
    "source_sha256", "benchmark_sha256", "swipl",
)


def read_rows(path, fields=None):
    with Path(path).open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        if fields is not None and reader.fieldnames != fields:
            raise ValueError(f"Unexpected columns in {Path(path).name}")
        return list(reader)


def fingerprint(value):
    encoded = json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    return hashlib.sha256(encoded.encode("utf-8")).hexdigest()


class CompactOutput:
    @classmethod
    def open_existing(cls, directory):
        result = cls.__new__(cls)
        result.directory = Path(directory)
        settings = json.loads((result.directory / "settings.json").read_text())
        if settings.get("format_version") != 2:
            raise ValueError("Expected CSV output format 2")
        result.shared = settings["shared"]
        result.trials = settings["trials"]
        result.measurements = settings["measurements"]
        result.failure_logs = settings.get("failure_logs", {})
        return result

    def __init__(self, directory):
        self.directory = Path(directory)
        self.directory.mkdir(parents=True, exist_ok=True)
        reserved = [*TABLES, "settings.json", "errors.jsonl", "details.zip", "artifact_manifest.json"]
        if any((self.directory / name).exists() for name in reserved):
            raise FileExistsError("Output already exists")
        self.shared = None
        self.trials = []
        self.measurements = {}
        self.failure_logs = {}
        for name, fields in TABLES.items():
            with (self.directory / name).open("x", newline="", encoding="utf-8") as handle:
                csv.DictWriter(handle, fieldnames=fields).writeheader()
        self._write_settings(self._settings())

    def _settings(self, shared=None, trials=None, measurements=None, failure_logs=None):
        return {
            "format_version": 2,
            "shared": self.shared if shared is None else shared,
            "trials": self.trials if trials is None else trials,
            "measurements": self.measurements if measurements is None else measurements,
            "failure_logs": self.failure_logs if failure_logs is None else failure_logs,
        }

    def _write_settings(self, payload):
        target = self.directory / "settings.json"
        temporary = target.with_suffix(".json.tmp")
        with temporary.open("w", encoding="utf-8") as handle:
            json.dump(payload, handle, indent=2)
            handle.write("\n")
            handle.flush()
            os.fsync(handle.fileno())
        if json.loads(temporary.read_text()) != payload:
            raise ValueError("Settings verification failed")
        temporary.replace(target)

    def _verify_append(self, name, offset, expected):
        with (self.directory / name).open("rb") as handle:
            handle.seek(offset)
            text = handle.read().decode("utf-8")
        actual = list(csv.DictReader(io.StringIO(text), fieldnames=TABLES[name]))
        if actual != expected:
            raise ValueError(f"Saved rows differ from original {name}")

    def add_run(self, source, remove_source=False):
        source = Path(source)
        settings = json.loads((source / "settings.json").read_text())
        run_id = settings["run_id"]
        if source.name != run_id or any(t["run_id"] == run_id for t in self.trials):
            raise ValueError("Invalid or duplicate run ID")
        shared = {k: settings[k] for k in SHARED_FIELDS}
        if self.shared is not None and shared != self.shared:
            raise ValueError("Source versions or environment changed within the batch")
        tables = {name: read_rows(source / name, fields) for name, fields in TABLES.items()}
        if len(tables["runs.csv"]) != 1:
            raise ValueError("Expected one run-level record")
        if any(row["run_id"] != run_id for values in tables.values() for row in values):
            raise ValueError("Artifact rows refer to another run")
        status = tables["runs.csv"][0]["status"]
        if status not in ("completed", "error", "timeout"):
            raise ValueError("Unknown run status")
        failure = None
        if status != "completed":
            failure = {"run_id": run_id}
            for stream in ("stdout", "stderr"):
                path = source / (stream + ".txt")
                failure[stream] = path.read_text() if path.exists() else None
        offsets = {name: (self.directory / name).stat().st_size for name in TABLES}
        errors = self.directory / "errors.jsonl"
        error_offset = errors.stat().st_size if errors.exists() else None
        measurements = {**self.measurements, run_id: {
            name: {"rows": len(values), "sha256": fingerprint(values)}
            for name, values in tables.items()
        }}
        failures = dict(self.failure_logs)
        trials = self.trials + [{k: v for k, v in settings.items() if k not in SHARED_FIELDS}]
        try:
            for name, fields in TABLES.items():
                with (self.directory / name).open("a", newline="", encoding="utf-8") as handle:
                    csv.DictWriter(handle, fieldnames=fields).writerows(tables[name])
                    handle.flush()
                    os.fsync(handle.fileno())
                self._verify_append(name, offsets[name], tables[name])
            if failure is not None:
                with errors.open("a", encoding="utf-8") as handle:
                    handle.write(json.dumps(failure, ensure_ascii=False) + "\n")
                    handle.flush()
                    os.fsync(handle.fileno())
                with errors.open("rb") as handle:
                    handle.seek(error_offset or 0)
                    if json.loads(handle.read().decode("utf-8")) != failure:
                        raise ValueError("Failure log verification failed")
                failures[run_id] = fingerprint(failure)
            payload = self._settings(shared, trials, measurements, failures)
            if {**payload["shared"], **payload["trials"][-1]} != settings:
                raise ValueError("Trial settings lost information")
            self._write_settings(payload)
        except (OSError, ValueError, TypeError):
            for name, offset in offsets.items():
                with (self.directory / name).open("r+b") as handle:
                    handle.truncate(offset)
            if error_offset is None:
                errors.unlink(missing_ok=True)
            elif errors.exists():
                with errors.open("r+b") as handle:
                    handle.truncate(error_offset)
            raise
        self.shared = shared
        self.trials = trials
        self.measurements = measurements
        self.failure_logs = failures
        if remove_source:
            shutil.rmtree(source)
        return tables

    def verify(self):
        saved = self.open_existing(self.directory)
        ids = [trial["run_id"] for trial in saved.trials]
        if len(set(ids)) != len(ids) or set(ids) != set(saved.measurements):
            raise ValueError("Trial settings and measurements disagree")
        totals = {}
        for name, fields in TABLES.items():
            rows = read_rows(self.directory / name, fields)
            offset = 0
            for run_id in ids:
                expected = saved.measurements[run_id][name]
                count = expected["rows"]
                if type(count) is not int or count < 0:
                    raise ValueError("Invalid row count")
                block = rows[offset:offset + count]
                if len(block) != count or any(r["run_id"] != run_id for r in block):
                    raise ValueError(f"Missing or misassigned rows in {name}")
                if fingerprint(block) != expected["sha256"]:
                    raise ValueError(f"Measurement checksum mismatch in {name}")
                offset += count
            if offset != len(rows):
                raise ValueError(f"Unexpected extra rows in {name}")
            totals[name] = len(rows)
        errors = self.directory / "errors.jsonl"
        records = {}
        if errors.exists():
            with errors.open(encoding="utf-8") as handle:
                for line in handle:
                    record = json.loads(line)
                    run_id = record["run_id"]
                    if run_id in records:
                        raise ValueError("Duplicate failure log")
                    records[run_id] = fingerprint(record)
        if records != saved.failure_logs or not set(records).issubset(ids):
            raise ValueError("Missing or altered failure logs")
        return totals


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Verify collected PLN measurements")
    parser.add_argument("directory", type=Path)
    parser.add_argument("--verify", action="store_true")
    args = parser.parse_args()
    totals = CompactOutput.open_existing(args.directory).verify()
    print(json.dumps(totals, indent=2))
