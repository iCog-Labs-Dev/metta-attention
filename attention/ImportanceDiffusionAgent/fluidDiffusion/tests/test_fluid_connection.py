"""Validation checks for the fluid diffusion transport engine.

Coverage
  - Divergence-free Fourier velocity modes (single and summed)
  - Upwind advection mass conservation and non-negativity
  - Cost field normalization (0 at goal, 1 at farthest cell)
  - Value iteration ordering (goal cheaper than distant)
  - Goal-routed transport reduces expected value cost
  - fluid_from_af STI conservation and out-of-graph passthrough
  - print_diagnostics robustness to partial dicts
"""

from __future__ import annotations

import importlib.util
import io
import os
from pathlib import Path
import random
import sys
from contextlib import redirect_stdout

import numpy as np


os.environ.setdefault("MPLCONFIGDIR", "/tmp/matplotlib")


FLUID_DIR = Path(__file__).resolve().parent.parent
ROOT = FLUID_DIR.parents[2]
CONNECTION_PATH = FLUID_DIR / "connection.py"


def load_connection():
    sys.path.insert(0, str(CONNECTION_PATH.parent))
    spec = importlib.util.spec_from_file_location("connection", CONNECTION_PATH)
    connection = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    sys.modules["connection"] = connection
    spec.loader.exec_module(connection)
    return connection


def assert_close(value: float, threshold: float, label: str) -> None:
    if value >= threshold:
        raise AssertionError(f"{label}={value} exceeds threshold {threshold}")


def test_stream_function_divergence(connection) -> None:
    """Each Fourier velocity mode is divergence-free to machine precision"""
    modes = connection.precompute_fourier_velocity_modes(24, k_max=3)
    for index, (u_x, u_y) in enumerate(modes):
        div_norm = float(np.linalg.norm(connection.compute_divergence(u_x, u_y)))
        assert_close(div_norm, 1e-16, f"mode[{index}] divergence")


def test_mode_sum_divergence(connection) -> None:
    """Any linear combination of Fourier modes remains divergence-free"""
    rng = random.Random(42)
    modes = connection.precompute_fourier_velocity_modes(24, k_max=2)
    u_x = np.zeros((24, 24))
    u_y = np.zeros((24, 24))
    for mode_ux, mode_uy in modes:
        weight = rng.uniform(-1.0, 1.0)
        u_x += weight * mode_ux
        u_y += weight * mode_uy
    div_norm = float(np.linalg.norm(connection.compute_divergence(u_x, u_y)))
    assert_close(div_norm, 1e-10, "mode sum divergence")


def test_advection_mass_and_nonnegative(connection) -> None:
    """Upwind advection conserves total mass and does not produce negative densities"""
    rho = np.zeros((24, 24))
    rho[12, 12] = 1.0
    modes = connection.precompute_fourier_velocity_modes(24, k_max=1)
    u_x, u_y = modes[0]
    rho_next = connection.advect_density_upwind(rho, u_x, u_y, dt=0.1)
    assert_close(abs(float(np.sum(rho_next)) - 1.0), 1e-12, "mass error")
    if np.any(rho_next < 0):
        raise AssertionError("rho_next contains negative density")


def test_cost_field_distance_only(connection) -> None:
    """Cost is 0 at the goal cell and 1 at the farthest cell from the goal"""
    goals = [(12, 12)]
    distance = connection.compute_distance_to_goals(24, goals)
    cost = connection.compute_cost_field(distance)
    assert_close(abs(float(cost[12, 12])), 1e-12, "goal distance cost")
    assert_close(abs(float(np.max(cost)) - 1.0), 1e-12, "max distance cost")


def test_value_field_goal_ordering(connection) -> None:
    """Value iteration makes the goal cell cheaper than a far-away cell"""
    goals = [(12, 12)]
    distance = connection.compute_distance_to_goals(24, goals)
    cost = connection.compute_cost_field(distance)
    goal_mask = connection.compute_goal_mask(24, goals)
    value = connection.solve_value_field(cost, goal_mask=goal_mask, iterations=40)
    if not value[12, 12] < value[0, 0]:
        raise AssertionError(
            "value field does not make the goal cheaper than a far region"
        )


def test_goal_routing_reduces_value_cost(connection) -> None:
    """Transport steered by the value field reduces the expected cost toward the goal"""
    rho = np.zeros((24, 24))
    rho[2:5, 2:5] = 1.0
    rho = rho / np.sum(rho)
    params = connection.FluidParams(
        grid_size=24,
        num_steps=8,
        dt=0.1,
        target_cfl=0.4,
        k_max=3,
        control_mode="value_alignment",
        value_iterations=40,
    )

    goals = connection.parse_goal_cells("12,12", params.grid_size)
    goal_mask = connection.compute_goal_mask(params.grid_size, goals)
    distance = connection.compute_distance_to_goals(params.grid_size, goals)
    initial_cost = connection.compute_cost_field(distance)
    initial_value = connection.solve_value_field(
        initial_cost,
        gamma=params.gamma,
        iterations=params.value_iterations,
        goal_mask=goal_mask,
    )
    initial_expected_cost = float(np.sum(rho * initial_value))

    result_rho, _, diagnostics, history = connection.transport_density(
        rho, params, af_seeds="12,12", track_history=True
    )
    if not history:
        raise AssertionError("missing diagnostics history")
    if diagnostics["expected_value_cost"] > initial_expected_cost + 1e-9:
        raise AssertionError("expected value cost did not decrease")
    assert_close(abs(float(np.sum(result_rho)) - 1.0), 1e-9, "routed mass error")


def test_fluid_from_af_preserves_total_sti(connection) -> None:
    """Total STI is conserved across the full pipeline; out-of-graph atoms pass through unchanged"""
    graph = ROOT / "experiments/data/adagram_sparse_random.metta"
    if not graph.exists():
        graph = ROOT / "experiments/data/adagram.metta"
    pairs = [
        ["abamectin", 100.0],
        ["acetamiprid", 80.0],
        ["alachlor", 60.0],
        ["not_in_graph", 25.0],
    ]
    result = connection.fluid_from_af(
        str(graph),
        pairs,
        grid_size=24,
        num_steps=5,
        dt=0.1,
        af_seeds="12,12",
        target_cfl=0.4,
    )
    total_in = sum(value for _, value in pairs)
    total_out = sum(float(value) for _, value in result)
    assert_close(abs(total_in - total_out), 1e-6, "fluid_from_af STI total error")

    result_by_atom = {atom: float(value) for atom, value in result}
    if result_by_atom.get("not_in_graph") != 25.0:
        raise AssertionError("fluid_from_af did not preserve out-of-graph STI")


def test_print_diagnostics_allows_missing_keys(connection) -> None:
    """print_diagnostics handles a partial diagnostics dict without erroring on missing keys"""
    output = io.StringIO()
    with redirect_stdout(output):
        connection.print_diagnostics({"mass_error": 0.0})

    text = output.getvalue()
    if "mass_error=0" not in text:
        raise AssertionError("diagnostics output did not include present key")
    if "cfl=" in text:
        raise AssertionError("diagnostics output included missing key")


def main() -> None:
    connection = load_connection()
    test_stream_function_divergence(connection)
    test_mode_sum_divergence(connection)
    test_advection_mass_and_nonnegative(connection)
    test_cost_field_distance_only(connection)
    test_value_field_goal_ordering(connection)
    test_goal_routing_reduces_value_cost(connection)
    test_fluid_from_af_preserves_total_sti(connection)
    test_print_diagnostics_allows_missing_keys(connection)
    print("fluid connection checks passed")


if __name__ == "__main__":
    main()
