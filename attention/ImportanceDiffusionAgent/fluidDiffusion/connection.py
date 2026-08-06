from __future__ import annotations

import argparse
import json
from typing import Any

import numpy as np

from params import FluidParams
from params import DEFAULT_STI as DEFAULT_STI
from graph import (
    EDGE_PATTERN as EDGE_PATTERN,
    parse_metta_edges,
    extract_atoms,
    build_adjacency_matrix as build_adjacency_matrix,
    get_spectral_coordinates_magnetic as get_spectral_coordinates_magnetic,
    spectral_to_grid_coords as spectral_to_grid_coords,
)
from density import push_sti_to_density, map_density_to_atoms, pull_density_to_sti
from goals import (
    get_center_seed as get_center_seed,
    parse_goal_cells,
    compute_distance_to_goals as compute_distance_to_goals,
    compute_goal_mask as compute_goal_mask,
    compute_cost_field as compute_cost_field,
    solve_value_field as solve_value_field,
    compute_control_from_value as compute_control_from_value,
)
from transport import (
    precompute_fourier_velocity_modes as precompute_fourier_velocity_modes,
    combine_modes_alignment as combine_modes_alignment,
    advect_density_upwind as advect_density_upwind,
    apply_cfl_scaling as apply_cfl_scaling,
    transport_density,
    compute_divergence as compute_divergence,
    compute_diagnostics as compute_diagnostics,
    print_diagnostics,
)
from cache import _load_or_compute_graph_data
from render import (
    SCRIPT_DIR as SCRIPT_DIR,
    GIF_OUTPUT as GIF_OUTPUT,
    _resolve_output_path as _resolve_output_path,
    render_animation,
)


AtomKey = str | tuple[str, ...]


def _atom_key(name: Any) -> AtomKey:
    if isinstance(name, list):
        return tuple(name)
    return str(name)


def _atom_to_metta(key: AtomKey) -> Any:
    if isinstance(key, tuple):
        return list(key)
    return key


def read_sti_pairs(
    atom_sti_pairs: list[list[Any]] | tuple[Any, ...] | None,
) -> dict[AtomKey, float]:
    """Convert MeTTa py-call pairs into a plain STI mapping."""

    if not atom_sti_pairs:
        return {}
    return {_atom_key(name): float(value) for name, value in atom_sti_pairs}


def fluid_from_af(
    metta_path: str,
    atom_sti_pairs: list[list[Any]],
    grid_size: int = 36,
    num_steps: int = 100,
    dt: float = 0.1,
    af_seeds: str | list[str] | list[tuple[int, int]] | None = None,
    spread_sigma: float = 1.0,
    target_cfl: float = 0.8,
    control_mode: str = "value_alignment",
    visualize: bool = False,
    overwrite: bool = True,
    frame_step: int = 1,
    fps: int = 10,
) -> list[list[Any]]:
    """Redistribute PeTTa-provided STI through fluid transport and return pairs."""

    visualize = str(visualize).lower() in ("true", "1", "yes")
    overwrite = str(overwrite).lower() in ("true", "1", "yes")

    params = FluidParams(
        grid_size=int(grid_size),
        num_steps=int(num_steps),
        dt=float(dt),
        target_cfl=float(target_cfl),
        spread_sigma=float(spread_sigma),
        control_mode=control_mode,
    )

    edges, nodes, coords, modes = _load_or_compute_graph_data(metta_path, params)

    sti_values = read_sti_pairs(atom_sti_pairs)
    node_set = set(nodes)
    transport_sti = {
        atom: value for atom, value in sti_values.items() if atom in node_set
    }
    passthrough_sti = {
        atom: value for atom, value in sti_values.items() if atom not in node_set
    }
    transport_total = sum(transport_sti.values())

    if transport_total <= 0:
        return [[atom, value] for atom, value in passthrough_sti.items() if value > 0]

    if af_seeds is not None:
        flat_seeds = []
        for item in af_seeds:
            if isinstance(item, str):
                flat_seeds.append(item)
            elif isinstance(item, (list, tuple)):
                flat_seeds.extend(item[1:])
        af_seeds = flat_seeds

    af_atom_names = list(transport_sti.keys()) if af_seeds is None else af_seeds

    goal_cells = parse_goal_cells(af_seeds, params.grid_size, coords)

    rho_initial, _ = push_sti_to_density(
        edges, nodes, params, transport_sti, spectral_coords=coords
    )
    rho_final, _, diagnostics, history = transport_density(
        rho_initial,
        params,
        af_atom_names,
        modes=modes,
        spectral_coords=coords,
        track_history=visualize,
    )
    if visualize and history:
        render_animation(
            history,
            params.grid_size,
            coords,
            frame_step=frame_step,
            fps=fps,
            sti_values=transport_sti,
            overwrite=overwrite,
            goal_cells=goal_cells,
            goal_names=af_atom_names,
        )
    new_sti = pull_density_to_sti(rho_final, coords, params, transport_total)
    new_sti.update(passthrough_sti)

    if params.diagnostics:
        print_diagnostics(diagnostics)

    return [
        [_atom_to_metta(atom), value] for atom, value in new_sti.items() if value > 0
    ]


def _build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Fluid transport for PeTTa ECAN STI values"
    )
    parser.add_argument("input", nargs="?", default="experiments/data/adagram.metta")
    parser.add_argument("--steps", type=int, default=100)
    parser.add_argument("--grid", type=int, default=36)
    parser.add_argument("--dt", type=float, default=0.1)
    parser.add_argument("--cfl", type=float, default=0.4)
    parser.add_argument("--sigma", type=float, default=1.0)
    parser.add_argument("--seeds", type=str, default=None)
    parser.add_argument("--top", type=int, default=10)
    parser.add_argument("--sti-json", type=str, default=None)
    parser.add_argument(
        "--control-mode",
        choices=["distance", "value_alignment"],
        default="value_alignment",
    )
    parser.add_argument(
        "--animate", action="store_true", help="Render fluid animation GIF"
    )
    parser.add_argument(
        "--frame-step", type=int, default=1, help="Record every Nth frame"
    )
    parser.add_argument("--fps", type=int, default=10, help="GIF playback speed")
    parser.add_argument(
        "--no-overwrite",
        action="store_true",
        help="Auto-increment filename instead of overwriting",
    )
    return parser


def _load_sti_json(path: str | None) -> dict[str, float] | None:
    if not path:
        return None
    with open(path) as handle:
        return {str(name): float(value) for name, value in json.load(handle).items()}


def main() -> None:
    args = _build_arg_parser().parse_args()
    params = FluidParams(
        grid_size=args.grid,
        num_steps=args.steps,
        dt=args.dt,
        target_cfl=args.cfl,
        spread_sigma=args.sigma,
        control_mode=args.control_mode,
    )

    edges, nodes, coords, modes = _load_or_compute_graph_data(args.input, params)

    sti_values = _load_sti_json(args.sti_json)
    if not sti_values:
        rng = np.random.default_rng()
        sti_values = {node: float(rng.uniform(300, 700)) for node in nodes}

    rho_initial, _ = push_sti_to_density(
        edges, nodes, params, sti_values, spectral_coords=coords
    )

    if args.animate:
        goal_cells = parse_goal_cells(args.seeds, params.grid_size, coords)
        rho_final, (u_x, u_y), diagnostics, history = transport_density(
            rho_initial,
            params,
            args.seeds,
            track_history=True,
            modes=modes,
            spectral_coords=coords,
        )
        render_animation(
            history,
            params.grid_size,
            coords,
            frame_step=args.frame_step,
            fps=args.fps,
            sti_values=sti_values,
            overwrite=not args.no_overwrite,
            goal_cells=goal_cells,
            goal_names=args.seeds,
        )
    else:
        rho_final, (u_x, u_y), diagnostics, _ = transport_density(
            rho_initial, params, args.seeds, modes=modes, spectral_coords=coords
        )

    print_diagnostics(diagnostics)
    print(f"Final rho sum: {np.sum(rho_final):.6f}")
    print(f"Max velocity: {np.max(np.sqrt(u_x**2 + u_y**2)):.4f}")

    node_densities = map_density_to_atoms(
        rho_final, coords, args.grid, params.density_radius
    )
    print(f"\nTop {args.top} atoms by density:")
    for atom, density in sorted(
        node_densities.items(), key=lambda item: item[1], reverse=True
    )[: args.top]:
        print(f"  {atom}: {density:.4f}")


if __name__ == "__main__":
    main()
