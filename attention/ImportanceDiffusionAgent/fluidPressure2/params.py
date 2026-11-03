from __future__ import annotations

from dataclasses import dataclass

@dataclass(frozen=True)
class FluidPressure2Params:

    grid_size: int = 100
    steps: int = 100
    dt: float = 0.08
    hjb_steps: int = 35
    hjb_dt: float | None = None        # None → min(dt, 0.05)
    nu: float = 0.12
    cfl: float = 0.4
    force_gain: float = 1.0
    sobolev_mu: float = 0.5
    hjb_refresh_interval: int = 25
    kernel_sigma: float = 0.5
    use_global_potential: bool = True
    goal_radius: float = 20.0          # used when use_global_potential=False
    goal_strength: float = 1.0

    af_cap: float | None = None        # per-cell density cap; None = off
    lti_viscosity_strength: float = 0.65  # γ_lti for habit-modulated viscosity
