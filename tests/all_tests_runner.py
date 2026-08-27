from __future__ import annotations

import os
import re
import shlex
import shutil
import subprocess
import tempfile
from pathlib import Path
from typing import List, Union


ROOT = Path(__file__).resolve().parents[1]
KNOWN_EXCLUDED = {
    ROOT / "attention" / "ForgettingAgent" / "tests" / "ForgettingAgent-test.metta",
}


def _test_files() -> List[Path]:
    roots = [
        ROOT / "attention-bank",
        ROOT / "attention",
        ROOT / "synapse",
    ]
    files = [ROOT / "tests" / "library-import-smoke-test.metta"]
    for test_root in roots:
        files.extend(sorted(test_root.rglob("*-test.metta")))
    if os.environ.get("METTA_INCLUDE_KNOWN_EXCLUDED") != "1":
        files = [path for path in files if path not in KNOWN_EXCLUDED]
    return files


def _runner_command() -> List[str]:
    configured = os.environ.get("PETTA_RUNNER")
    if configured:
        return shlex.split(configured)

    petta = shutil.which("petta")
    if petta:
        return [petta]

    sibling_run_sh = ROOT.parent / "PeTTa" / "run.sh"
    if sibling_run_sh.exists():
        return ["sh", str(sibling_run_sh)]

    raise RuntimeError(
        "Could not find a PeTTa runner. Set PETTA_RUNNER, install `petta` on PATH, "
        "or keep PeTTa as a sibling checkout."
    )


def _clean_env() -> dict:
    env = os.environ.copy()
    env.pop("PYTHONHOME", None)
    env.pop("PYTHONPATH", None)
    env.setdefault("MPLCONFIGDIR", str(Path(tempfile.gettempdir()) / "metta-attention-mpl"))
    return env


def _has_assertion_failure(output: str) -> bool:
    if "❌" in output or "â\x9d\x8c" in output:
        return True

    for match in re.finditer(r"is\s+(.+?),\s+should\s+(.+?)\.(\s|$)", output):
        actual = match.group(1).strip()
        expected = match.group(2).strip()
        if actual != expected:
            return True
    return False


def _short_failure(output: str) -> str:
    lines = [line.strip() for line in output.splitlines() if line.strip()]
    for line in lines:
        if "❌" in line or "ERROR:" in line:
            return line[:500]
    return (lines[-1] if lines else "unknown failure")[:500]


def _run_one(path: Path) -> List[str]:
    command = [*_runner_command(), str(path), "-s"]
    process = subprocess.run(
        command,
        cwd=str(ROOT),
        env=_clean_env(),
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=int(os.environ.get("METTA_TEST_TIMEOUT", "180")),
    )
    output = f"{process.stdout}\n{process.stderr}"
    failed = process.returncode != 0 or _has_assertion_failure(output)
    relative_path = path.relative_to(ROOT).as_posix()
    if failed:
        return ["failed", relative_path, _short_failure(output)]
    return ["passed", relative_path]


def run_all_metta_tests_detailed() -> List[List[str]]:
    return [_run_one(path) for path in _test_files()]


def run_all_metta_tests() -> List[Union[int, str]]:
    results = run_all_metta_tests_detailed()
    failures = [result for result in results if result[0] == "failed"]
    if failures:
        details = "; ".join(f"{failure[1]}: {failure[2]}" for failure in failures[:5])
        remaining = len(failures) - 5
        if remaining > 0:
            details = f"{details}; ... {remaining} more"
        raise AssertionError(f"{len(failures)} MeTTa test file(s) failed: {details}")

    total = len(results)
    return ["AllTestsSummary", total, total, 0]
