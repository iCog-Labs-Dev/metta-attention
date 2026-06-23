#!/usr/bin/env python3
"""Lightweight validation checks for fluidDiffusion/connection.py."""

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


ROOT = Path(__file__).resolve().parents[2]
CONNECTION_PATH = ROOT / "attention/ImportanceDiffusionAgent/fluidDiffusion/connection.py"


def load_connection():
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
    modes = connection.precompute_fourier_velocity_modes(24, k_max=3)
    for index, (u_x, u_y) in enumerate(modes):
        div_norm = float(np.linalg.norm(connection.compute_divergence(u_x, u_y)))
        assert_close(div_norm, 1e-10, f"mode[{index}] divergence")


def test_mode_sum_divergence(connection) -> None:
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
    rho = np.zeros((24, 24))
    rho[12, 12] = 1.0
    modes = connection.precompute_fourier_velocity_modes(24, k_max=1)
    u_x, u_y = modes[0]
    rho_next = connection.advect_density_upwind(rho, u_x, u_y, dt=0.1)
    assert_close(abs(float(np.sum(rho_next)) - 1.0), 1e-12, "mass error")
    if np.any(rho_next < 0):
        raise AssertionError("rho_next contains negative density")


def test_cost_field_distance_only(connection) -> None:
    goals = [(12, 12)]
    distance = connection.compute_distance_to_goals(24, goals)
    cost = connection.compute_cost_field(distance)
    assert_close(abs(float(cost[12, 12])), 1e-12, "goal distance cost")
    assert_close(abs(float(np.max(cost)) - 1.0), 1e-12, "max distance cost")


def test_cost_field_congestion(connection) -> None:
    distance = np.zeros((8, 8))
    rho = np.zeros((8, 8))
    rho[1, 1] = 2.0
    rho[2, 2] = 1.0
    cost = connection.compute_cost_field(distance, rho, congestion_weight=0.25)

    assert_close(abs(float(cost[1, 1]) - 0.25), 1e-12, "peak congestion cost")
    assert_close(abs(float(cost[2, 2]) - 0.125), 1e-12, "scaled congestion cost")
    assert_close(abs(float(cost[0, 0])), 1e-12, "empty congestion cost")


def test_value_field_goal_ordering(connection) -> None:
    goals = [(12, 12)]
    distance = connection.compute_distance_to_goals(24, goals)
    cost = connection.compute_cost_field(distance)
    goal_mask = connection.compute_goal_mask(24, goals)
    value = connection.solve_value_field(cost, goal_mask=goal_mask, iterations=40)
    if not value[12, 12] < value[0, 0]:
        raise AssertionError("value field does not make the goal cheaper than a far region")


def test_goal_routing_reduces_value_cost(connection) -> None:
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
    initial_cost = connection.compute_cost_field(
        distance, rho, params.congestion_weight
    )
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
    test_cost_field_congestion(connection)
    test_value_field_goal_ordering(connection)
    test_goal_routing_reduces_value_cost(connection)
    test_fluid_from_af_preserves_total_sti(connection)
    test_print_diagnostics_allows_missing_keys(connection)
    print("fluid connection checks passed")


if __name__ == "__main__":
    main()
