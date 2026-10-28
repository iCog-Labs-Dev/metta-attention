"""Make fluidDiffusion importable when PeTTa is run from ECAN/PeTTa.

fluid_integration.metta loads its solver with
`!(import! &self "../attention/ImportanceDiffusionAgent/fluidDiffusion/connection.py")`,
a path that only resolves when the interpreter's working directory is
metta-attention/experiments (how the baseline experiment is run). This experiment
runs PeTTa from ECAN/PeTTa instead, because MeTTaClaw resolves its own memory and
library paths against that directory. PeTTa's `import!` swallows failures, so
without this the missing module only surfaces much later as
`ModuleNotFoundError: connection` on the first fluid step.

Every other Python dependency is loaded through `!(import! ... .py)`, which inserts
the module's directory into sys.path on its own;
"""

import sys
from pathlib import Path

_FLUID_DIR = (
    Path(__file__).resolve().parents[3]
    / "attention"
    / "ImportanceDiffusionAgent"
    / "fluidDiffusion"
)

if not _FLUID_DIR.is_dir():
    raise RuntimeError(f"fluidDiffusion directory not found at {_FLUID_DIR}")

if str(_FLUID_DIR) not in sys.path:
    sys.path.insert(0, str(_FLUID_DIR))

import connection  # imported for its side effect on sys.modules
