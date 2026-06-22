from __future__ import annotations

import argparse
from dataclasses import dataclass
import json
import re
from typing import Any

import numpy as np
import scipy.linalg

DEFAULT_STI = 0.0
EDGE_PATTERN = re.compile(
    r"\(\((?P<link>\w+)\s+(?P<source>\S+)\s+(?P<target>\S+)\)\s+"
    r"\((?P<mean>[-+0-9.eE]+)\s+(?P<confidence>[-+0-9.eE]+)\)\)"
)


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


def parse_metta_edges(filepath: str) -> list[tuple[str, str, float, float]]:
    """Parse weighted MeTTa links into source, target, mean, confidence tuples."""

    with open(filepath) as handle:
        content = handle.read()

    return [
        (
            match.group("source"),
            match.group("target"),
            float(match.group("mean")),
            float(match.group("confidence")),
        )
        for match in EDGE_PATTERN.finditer(content)
    ]


def extract_atoms(edges: list[tuple[str, str, float, float]]) -> list[str]:
    return sorted(set([edge[0] for edge in edges] + [edge[1] for edge in edges]))


def read_sti_pairs(
    atom_sti_pairs: list[list[Any]] | tuple[Any, ...] | None,
) -> dict[str, float]:
    """Convert MeTTa py-call pairs into a plain STI mapping."""

    if not atom_sti_pairs:
        return {}
    return {str(name): float(value) for name, value in atom_sti_pairs}


def build_adjacency_matrix(
    edges: list[tuple[str, str, float, float]],
    nodes: list[str],
    make_symmetric: bool = False,
) -> tuple[np.ndarray, dict[str, int]]:
    node_to_idx = {node: i for i, node in enumerate(nodes)}
    matrix = np.zeros((len(nodes), len(nodes)), dtype=np.float64)

    for source, target, mean, confidence in edges:
        i, j = node_to_idx[source], node_to_idx[target]
        matrix[i, j] = mean * confidence
        if make_symmetric:
            matrix[j, i] = mean * confidence

    return matrix, node_to_idx


def get_spectral_coordinates_magnetic(
    matrix: np.ndarray, nodes: list[str], q: float = 0.25
) -> dict[str, tuple[float, float]]:
    """
    Embed atoms using a magnetic Laplacian.

    This gives the fluid layer manifold coordinates; it does not mutate ECAN
    state or decide atom importance.
    """

    if not nodes:
        return {}
    if len(nodes) == 1:
        return {nodes[0]: (0.0, 0.0)}

    matrix = np.array(matrix, dtype=np.float64)
    weights = 0.5 * (matrix + matrix.T)
    theta = 2 * np.pi * q * (matrix - matrix.T)
    hermitian = weights * np.exp(1j * theta)
    degree = np.diag(np.sum(weights, axis=1))
    laplacian = degree - hermitian

    try:
        _, eigenvectors = scipy.linalg.eigh(laplacian)
        vector = eigenvectors[:, 1]
        return {
            node: (float(np.real(vector[i])), float(np.imag(vector[i])))
            for i, node in enumerate(nodes)
        }
    except Exception as exc:
        print(f"Eigendecomposition failed: {exc}")
        n = len(nodes)
        return {
            node: (
                float(np.cos(2 * np.pi * i / n)),
                float(np.sin(2 * np.pi * i / n)),
            )
            for i, node in enumerate(nodes)
        }


def spectral_to_grid_coords(
    spectral_coords: dict[str, tuple[float, float]], grid_size: int
) -> dict[str, tuple[int, int]]:
    if not spectral_coords:
        return {}

    coords = np.array(list(spectral_coords.values()), dtype=np.float64)
    x_min, x_span = float(np.min(coords[:, 0])), float(np.ptp(coords[:, 0]))
    y_min, y_span = float(np.min(coords[:, 1])), float(np.ptp(coords[:, 1]))
    x_span = x_span if x_span > 1e-10 else 1.0
    y_span = y_span if y_span > 1e-10 else 1.0

    positions: dict[str, tuple[int, int]] = {}
    for node, (x_coord, y_coord) in spectral_coords.items():
        grid_x = int(((x_coord - x_min) / x_span) * (grid_size - 1)) % grid_size
        grid_y = int(((y_coord - y_min) / y_span) * (grid_size - 1)) % grid_size
        positions[node] = (grid_x, grid_y)
    return positions


def push_sti_to_density(
    edges: list[tuple[str, str, float, float]],
    nodes: list[str],
    params: FluidParams,
    sti_values: dict[str, float] | None = None,
    spectral_coords: dict[str, tuple[float, float]] | None = None,
) -> tuple[np.ndarray, dict[str, tuple[float, float]]]:
    """Push current MeTTa STI values into a normalized density rho."""

    matrix, node_to_idx = build_adjacency_matrix(edges, nodes)
    if spectral_coords is None:
        spectral_coords = get_spectral_coordinates_magnetic(matrix, nodes)

    if sti_values:
        node_sti = sti_values
    else:
        node_sti = {
            node: float(np.mean(matrix[node_to_idx[node], :])) for node in nodes
        }

    rho = np.zeros((params.grid_size, params.grid_size), dtype=np.float64)
    positions = spectral_to_grid_coords(spectral_coords, params.grid_size)

    for node, (grid_x, grid_y) in positions.items():
        weight = float(node_sti.get(node, DEFAULT_STI))
        if weight <= 0:
            continue
        for dy in range(-3, 4):
            for dx in range(-3, 4):
                dist_sq = dx * dx + dy * dy
                if dist_sq <= params.spread_sigma * params.spread_sigma * 9:
                    gaussian = np.exp(-dist_sq / (2 * params.spread_sigma**2))
                    px = (grid_x + dx) % params.grid_size
                    py = (grid_y + dy) % params.grid_size
                    rho[py, px] += weight * gaussian

    total = float(np.sum(rho))
    if total > 0:
        rho /= total
    return rho, spectral_coords


def map_density_to_atoms(
    rho: np.ndarray,
    spectral_coords: dict[str, tuple[float, float]],
    grid_size: int,
    radius: int = 1,
) -> dict[str, float]:
    """Aggregate local density around each atom coordinate."""

    positions = spectral_to_grid_coords(spectral_coords, grid_size)
    densities: dict[str, float] = {}

    for node, (grid_x, grid_y) in positions.items():
        density = 0.0
        for dy in range(-radius, radius + 1):
            for dx in range(-radius, radius + 1):
                px = (grid_x + dx) % grid_size
                py = (grid_y + dy) % grid_size
                density += float(rho[py, px])
        densities[node] = density
    return densities


def pull_density_to_sti(
    rho: np.ndarray,
    spectral_coords: dict[str, tuple[float, float]],
    params: FluidParams,
    total_sti: float,
) -> dict[str, float]:
    """Pull rho back into atom STI values, preserving the total input STI."""

    densities = map_density_to_atoms(
        rho, spectral_coords, params.grid_size, params.density_radius
    )
    total_density = sum(densities.values()) or 1.0
    return {
        atom: total_sti * density / total_density
        for atom, density in densities.items()
        if density > 0
    }


def get_center_seed(grid_size: int, n_seeds: int = 4) -> list[tuple[int, int]]:
    center = grid_size // 2
    if n_seeds == 1:
        return [(center, center)]
    offsets = [(0, 0), (-4, 0), (4, 0), (0, -4), (0, 4)][:n_seeds]
    return [(center + dy, center + dx) for dy, dx in offsets]


def parse_goal_cells(
    af_seeds: str | list[tuple[int, int]] | None,
    grid_size: int,
) -> list[tuple[int, int]]:
    if af_seeds is None:
        seeds = get_center_seed(grid_size, n_seeds=4)
    elif isinstance(af_seeds, str):
        if af_seeds.lower() == "center":
            seeds = get_center_seed(grid_size, n_seeds=1)
        else:
            seeds = [tuple(map(int, seed.split(","))) for seed in af_seeds.split()]
    else:
        seeds = af_seeds
    return [(seed_y % grid_size, seed_x % grid_size) for seed_y, seed_x in seeds]


def compute_distance_to_goals(
    grid_size: int, goal_cells: list[tuple[int, int]]
) -> np.ndarray:
    y_coords, x_coords = np.mgrid[0:grid_size, 0:grid_size]
    distance = np.full((grid_size, grid_size), np.inf, dtype=np.float64)
    for seed_y, seed_x in goal_cells:
        dy = np.abs(seed_y - y_coords)
        dy = np.minimum(dy, grid_size - dy)
        dx = np.abs(seed_x - x_coords)
        dx = np.minimum(dx, grid_size - dx)
        distance = np.minimum(distance, np.sqrt(dy**2 + dx**2))
    return distance


def compute_goal_mask(
    grid_size: int, goal_cells: list[tuple[int, int]], radius: int = 1
) -> np.ndarray:
    mask = np.zeros((grid_size, grid_size), dtype=bool)
    for seed_y, seed_x in goal_cells:
        for dy in range(-radius, radius + 1):
            for dx in range(-radius, radius + 1):
                mask[(seed_y + dy) % grid_size, (seed_x + dx) % grid_size] = True
    return mask


def compute_cost_field(distance: np.ndarray) -> np.ndarray:
    """Minimal Bellman/HJB cost: normalized toroidal distance to goal."""

    # distance = compute_distance_to_goals(rho.shape[0], goal_cells)
    max_distance = float(np.max(distance)) or 1.0
    return distance / max_distance


def solve_value_field(
    cost: np.ndarray,
    gamma: float = 0.95,
    iterations: int = 100,
    goal_mask: np.ndarray | None = None,
) -> np.ndarray:
    """Discrete Bellman-style value field W used to guide fluid control."""

    value = cost.copy()
    if goal_mask is not None:
        value[goal_mask] = 0.0

    for _ in range(iterations):
        neighbor_min = np.minimum.reduce(
            [
                np.roll(value, 1, axis=0),
                np.roll(value, -1, axis=0),
                np.roll(value, 1, axis=1),
                np.roll(value, -1, axis=1),
            ]
        )
        value = cost + gamma * neighbor_min
        if goal_mask is not None:
            value[goal_mask] = 0.0
    return value


def compute_control_from_value(value: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    grad_y = (np.roll(value, -1, axis=0) - np.roll(value, 1, axis=0)) / 2.0
    grad_x = (np.roll(value, -1, axis=1) - np.roll(value, 1, axis=1)) / 2.0
    return -grad_x, -grad_y


def precompute_fourier_velocity_modes(
    grid_size: int,
    k_max: int = 4,
) -> list[tuple[np.ndarray, np.ndarray]]:
    """
    Build divergence-free modes via a discrete stream-function curl.

    The same centered differences are used by compute_divergence, so generated
    modes are divergence-free under the numerical diagnostic.
    """

    modes: list[tuple[np.ndarray, np.ndarray]] = []
    y_coords, x_coords = np.mgrid[0:grid_size, 0:grid_size]

    for kx in range(-k_max, k_max + 1):
        for ky in range(-k_max, k_max + 1):
            if kx == 0 and ky == 0:
                continue

            theta = 2 * np.pi * (kx * x_coords + ky * y_coords) / grid_size
            for psi in (np.sin(theta), np.cos(theta)):
                u_x = (np.roll(psi, -1, axis=0) - np.roll(psi, 1, axis=0)) / 2.0
                u_y = -(np.roll(psi, -1, axis=1) - np.roll(psi, 1, axis=1)) / 2.0
                norm = np.sqrt(np.sum(u_x**2 + u_y**2) + 1e-8)
                modes.append((u_x / norm, u_y / norm))
    return modes


def compute_divergence(u_x: np.ndarray, u_y: np.ndarray) -> np.ndarray:
    div_x = (np.roll(u_x, -1, axis=1) - np.roll(u_x, 1, axis=1)) / 2.0
    div_y = (np.roll(u_y, -1, axis=0) - np.roll(u_y, 1, axis=0)) / 2.0
    return div_x + div_y


def combine_modes_alignment(
    modes: list[tuple[np.ndarray, np.ndarray]],
    rho: np.ndarray,
    control_x: np.ndarray,
    control_y: np.ndarray,
    lambda_penalty: float,
) -> tuple[np.ndarray, np.ndarray]:
    u_x = np.zeros_like(rho)
    u_y = np.zeros_like(rho)

    for mode_ux, mode_uy in modes:
        alignment = mode_ux * control_x + mode_uy * control_y
        score = float(np.sum(alignment * rho)) / (1.0 + lambda_penalty)
        u_x += score * mode_ux
        u_y += score * mode_uy
    return u_x, u_y


def advect_density_upwind(
    rho: np.ndarray,
    u_x: np.ndarray,
    u_y: np.ndarray,
    dt: float,
    preserve_mass: bool = True,
) -> np.ndarray:
    initial_mass = float(np.sum(rho))

    flux_x_right = np.where(u_x > 0, rho * u_x, np.roll(rho, -1, axis=1) * u_x)
    flux_x_left = np.roll(flux_x_right, 1, axis=1)
    flux_y_down = np.where(u_y > 0, rho * u_y, np.roll(rho, -1, axis=0) * u_y)
    flux_y_up = np.roll(flux_y_down, 1, axis=0)

    rho_next = rho - dt * ((flux_x_right - flux_x_left) + (flux_y_down - flux_y_up))
    rho_next = np.maximum(rho_next, 0.0)

    if preserve_mass:
        next_mass = float(np.sum(rho_next))
        if initial_mass > 0 and next_mass > 0:
            rho_next *= initial_mass / next_mass
    return rho_next


def apply_cfl_scaling(
    u_x: np.ndarray,
    u_y: np.ndarray,
    dt: float,
    target_cfl: float,
) -> tuple[np.ndarray, np.ndarray, float]:
    max_speed = float(np.max(np.sqrt(u_x**2 + u_y**2)))
    if max_speed <= 1e-12:
        return np.zeros_like(u_x), np.zeros_like(u_y), 0.0

    current_cfl = dt * max_speed
    scale = target_cfl / current_cfl
    return u_x * scale, u_y * scale, target_cfl


def transport_density(
    rho_initial: np.ndarray,
    params: FluidParams,
    af_seeds: str | list[tuple[int, int]] | None = None,
    track_history: bool = False,
) -> tuple[
    np.ndarray, tuple[np.ndarray, np.ndarray], dict[str, Any], list[np.ndarray] | None
]:
    goal_cells = parse_goal_cells(af_seeds, params.grid_size)
    goal_mask = compute_goal_mask(params.grid_size, goal_cells)
    distance = compute_distance_to_goals(params.grid_size, goal_cells)
    modes = precompute_fourier_velocity_modes(params.grid_size, params.k_max)

    rho = rho_initial.copy()
    u_x = np.zeros_like(rho)
    u_y = np.zeros_like(rho)
    value = distance
    history = [] if track_history else None

    for _ in range(params.num_steps):
        if params.control_mode == "distance":
            value = distance
        elif params.control_mode == "value_alignment":
            cost = compute_cost_field(distance)
            value = solve_value_field(
                cost, params.gamma, params.value_iterations, goal_mask
            )
        else:
            raise ValueError(f"Unsupported control mode: {params.control_mode}")

        control_x, control_y = compute_control_from_value(value)
        u_x, u_y = combine_modes_alignment(
            modes, rho, control_x, control_y, params.lambda_penalty
        )
        u_x, u_y, _ = apply_cfl_scaling(u_x, u_y, params.dt, params.target_cfl)

        if track_history:
            history.append(rho.copy())
        rho = advect_density_upwind(rho, u_x, u_y, params.dt)

    diagnostics = compute_diagnostics(
        rho_initial, rho, u_x, u_y, distance, value, goal_mask, params.dt
    )
    diagnostics["goal_cells"] = goal_cells
    return rho, (u_x, u_y), diagnostics, history


def compute_diagnostics(
    rho_initial: np.ndarray,
    rho_final: np.ndarray,
    u_x: np.ndarray,
    u_y: np.ndarray,
    distance: np.ndarray,
    value: np.ndarray,
    goal_mask: np.ndarray,
    dt: float,
) -> dict[str, float]:
    divergence = compute_divergence(u_x, u_y)
    max_speed = float(np.max(np.sqrt(u_x**2 + u_y**2)))
    return {
        "mass_error": abs(float(np.sum(rho_final)) - float(np.sum(rho_initial))),
        "max_abs_divergence": float(np.max(np.abs(divergence))),
        "l2_divergence": float(np.linalg.norm(divergence)),
        "cfl": dt * max_speed,
        "goal_mass": float(np.sum(rho_final[goal_mask])),
        "expected_distance": float(np.sum(rho_final * distance)),
        "expected_value_cost": float(np.sum(rho_final * value)),
    }


def print_diagnostics(diagnostics: dict[str, Any]) -> None:
    keys = [
        "mass_error",
        "max_abs_divergence",
        "l2_divergence",
        "cfl",
        "goal_mass",
        "expected_value_cost",
    ]
    summary = ", ".join(f"{key}={diagnostics[key]:.6g}" for key in keys)
    print(f"fluid diagnostics: {summary}")


def fluid_from_af(
    metta_path: str,
    atom_sti_pairs: list[list[Any]],
    grid_size: int = 36,
    num_steps: int = 100,
    dt: float = 0.1,
    af_seeds: str | list[tuple[int, int]] | None = None,
    spread_sigma: float = 1.0,
    target_cfl: float = 0.8,
    control_mode: str = "value_alignment",
) -> list[list[Any]]:
    """Redistribute PeTTa-provided STI through fluid transport and return pairs."""

    sti_values = read_sti_pairs(atom_sti_pairs)
    edges = parse_metta_edges(metta_path)
    nodes = extract_atoms(edges)
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

    params = FluidParams(
        grid_size=int(grid_size),
        num_steps=int(num_steps),
        dt=float(dt),
        target_cfl=float(target_cfl),
        spread_sigma=float(spread_sigma),
        control_mode=control_mode,
    )

    rho_initial, coords = push_sti_to_density(edges, nodes, params, transport_sti)
    rho_final, _, diagnostics, _ = transport_density(rho_initial, params, af_seeds)
    new_sti = pull_density_to_sti(rho_final, coords, params, transport_total)
    new_sti.update(passthrough_sti)

    if params.diagnostics:
        print_diagnostics(diagnostics)

    return [[atom, value] for atom, value in new_sti.items() if value > 0]


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
    return parser


def _load_sti_json(path: str | None) -> dict[str, float] | None:
    if not path:
        return None
    with open(path) as handle:
        return {str(name): float(value) for name, value in json.load(handle).items()}


def main() -> None:
    args = _build_arg_parser().parse_args()
    sti_values = _load_sti_json(args.sti_json)
    params = FluidParams(
        grid_size=args.grid,
        num_steps=args.steps,
        dt=args.dt,
        target_cfl=args.cfl,
        spread_sigma=args.sigma,
        control_mode=args.control_mode,
    )

    edges = parse_metta_edges(args.input)
    nodes = extract_atoms(edges)
    rho_initial, coords = push_sti_to_density(edges, nodes, params, sti_values)
    rho_final, (u_x, u_y), diagnostics, _ = transport_density(
        rho_initial, params, args.seeds
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
