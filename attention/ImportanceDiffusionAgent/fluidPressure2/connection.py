from __future__ import annotations

import os
import sys
from typing import Any
_agent_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
if _agent_dir not in sys.path:
    sys.path.insert(0, _agent_dir)

from fluidPressure2.cache import load_or_compute_manifold
from fluidPressure2.kernel import kernel_matrix, positions_to_grid, pull_sti, push_sti
from fluidPressure2.params import FluidPressure2Params
from fluidPressure2.pipeline import run_cycle


def _pairs_to_dict(values: list[list[Any]] | None) -> dict[str, float]:
    """Convert [[atom, value], ...] to {atom: value}."""
    return {str(atom): float(value) for atom, value in (values or [])}


def _resolve_goal_cells(
    seeds: list[str] | str | None,
    positions: dict[str, tuple[int, int]],
    n: int,
) -> list[tuple[int, int]]:
    """Resolve goal atom names or space-delimited string to grid (x, y) coords.
    Falls back to the grid centre when no seeds resolve.
    """
    if isinstance(seeds, str):
        seeds = seeds.split()
    cells = [positions[name] for name in (seeds or []) if name in positions]
    return [(n // 2, n // 2)] if not cells else cells

# Main public API
def fluid_from_ecan(
    metta_path: str,
    atom_sti_pairs: list[list[Any]],
    atom_lti_pairs: list[list[Any]] | None = None,
    goal_seeds: list[str] | str | None = None,
    grid_size: int = 100,
    steps: int = 100,
    dt: float = 0.08,
    nu: float = 0.12,
    force_gain: float = 1.0,
    sobolev_mu: float = 0.5,
    goal_strength: float = 1.0,
    use_global_potential: bool = True,
    lti_viscosity_strength: float = 0.65,
    af_cap: float | None = None,
    kernel_sigma: float = 1.25,
    diagnostics: bool = False,
) -> list[list[Any]]:
    # Redistribute STI via HJB/NS transport and return pulled-back STI.
    params = FluidPressure2Params(
        grid_size=int(grid_size),
        steps=int(steps),
        dt=float(dt),
        nu=float(nu),
        force_gain=float(force_gain),
        sobolev_mu=float(sobolev_mu),
        goal_strength=float(goal_strength),
        use_global_potential=bool(use_global_potential),
        lti_viscosity_strength=float(lti_viscosity_strength),
        af_cap=float(af_cap) if af_cap is not None else None,
        kernel_sigma=float(kernel_sigma),
    )

    # Load manifold embedding
    _edges, _nodes, coords = load_or_compute_manifold(metta_path)

    # Split atoms: in-graph (transported) vs out-of-graph
    sti_all = _pairs_to_dict(atom_sti_pairs)
    lti_all = _pairs_to_dict(atom_lti_pairs)

    graph_sti = {name: sti_all.get(name, 0.0) for name in coords}
    graph_lti = {name: lti_all.get(name, 0.0) for name in coords}
    passthrough = {name: val for name, val in sti_all.items() if name not in coords}

    if sum(graph_sti.values()) <= 0.0:
        return [[name, value] for name, value in {**graph_sti, **passthrough}.items()]

    # Build kernel matrix 
    names, kernels = kernel_matrix(coords, params)

    #  Stage 1: Push STI/LTI to continuous grid fields 
    rho = push_sti(graph_sti, names, kernels, params.grid_size)
    lti_rho = push_sti(graph_lti, names, kernels, params.grid_size)

    #  Resolve goal cells from atom names 
    positions = positions_to_grid(coords, params.grid_size)
    goal_cells = _resolve_goal_cells(goal_seeds, positions, params.grid_size)

    # Stage 2: Fluid transport 
    rho_new, _u, _pressure, diag = run_cycle(rho, lti_rho, goal_cells, params)

    # Stage 3: Pull density back to atom STI 
    sti_new = pull_sti(rho_new, names, kernels)

    # Merge passthrough atoms 
    sti_new.update(passthrough)

    if diagnostics:
        _print_diagnostics(diag)
    return [[name, value] for name, value in sti_new.items()]


# Diagnostics helper
def _print_diagnostics(diag: dict[str, Any]) -> None:
    print(
        f"[fluidPressure2] "
        f"mass_err={diag['mass_error']:.2e}  "
        f"div={diag['max_abs_divergence']:.2e}  "
        f"p_rms={diag['pressure_rms']:.4g}  "
        f"goal_mass={diag['goal_mass']:.4g}  "
        f"exp_dist={diag['expected_distance']:.4g}  "
        f"enstrophy={diag['enstrophy']:.4g}"
    )
