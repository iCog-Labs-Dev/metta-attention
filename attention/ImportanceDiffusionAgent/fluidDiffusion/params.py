from __future__ import annotations

from dataclasses import dataclass


DEFAULT_STI = 0.0


@dataclass
class FluidParams:
    """Transport-only parameters; ECAN state stays on the MeTTa side."""

    grid_size: int = 36
    num_steps: int = 100
    dt: float = 0.1
    target_cfl: float = 0.4
    k_max: int = 4
    spread_sigma: float = 1.0
    control_mode: str = "value_alignment"
    value_iterations: int = 100
    gamma: float = 0.95
    lambda_penalty: float = 0.01
    density_radius: int = 1
    diagnostics: bool = True
