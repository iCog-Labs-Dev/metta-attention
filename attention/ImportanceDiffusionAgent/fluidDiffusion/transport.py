from __future__ import annotations

from typing import Any

import numpy as np

from goals import (
    parse_goal_cells,
    compute_goal_mask,
    compute_distance_to_goals,
    compute_cost_field,
    solve_value_field,
    compute_control_from_value,
)
from params import FluidParams


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
    af_seeds: str | list[str] | list[tuple[int, int]] | None = None,
    track_history: bool = False,
    modes: list[tuple[np.ndarray, np.ndarray]] | None = None,
    spectral_coords: dict[str, tuple[float, float]] | None = None,
) -> tuple[
    np.ndarray, tuple[np.ndarray, np.ndarray], dict[str, Any], list[np.ndarray] | None
]:
    goal_cells = parse_goal_cells(af_seeds, params.grid_size, spectral_coords)
    goal_mask = compute_goal_mask(params.grid_size, goal_cells)
    distance = compute_distance_to_goals(params.grid_size, goal_cells)
    if modes is None:
        modes = precompute_fourier_velocity_modes(params.grid_size, params.k_max)

    rho = rho_initial.copy()
    u_x = np.zeros_like(rho)
    u_y = np.zeros_like(rho)
    value = distance
    history = [] if track_history else None

    cost = compute_cost_field(distance)
    if params.control_mode == "value_alignment":
        value = solve_value_field(
            cost, params.gamma, params.value_iterations, goal_mask
        )

    for _ in range(params.num_steps):
        if params.control_mode not in ("distance", "value_alignment"):
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
    summary = ", ".join(
        f"{key}={diagnostics[key]:.6g}" for key in keys if key in diagnostics
    )
    print(f"fluid diagnostics: {summary}")
