from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parents[0]))

from fluidPressure2.kernel import kernel_matrix, pull_sti, push_sti
from fluidPressure2.navier_stokes import advect_conservative
from fluidPressure2.params import FluidPressure2Params
from fluidPressure2.pipeline import run_cycle


def test_round_trip_and_flow_conserve_sti() -> None:
    p = FluidPressure2Params(grid_size=32, steps=8, dt=0.02, hjb_steps=8)
    coords = {"a": (0.0, 0.0), "b": (1.0, 0.2), "c": (0.2, 1.0)}
    names, kernels = kernel_matrix(coords, p)
    rho = push_sti({"a": 9.0, "b": 3.0, "c": 1.0}, names, kernels, p.grid_size)
    lti = push_sti({"a": 4.0, "b": 1.0, "c": 0.0}, names, kernels, p.grid_size)
    rho, _u, _pressure, diagnostics = run_cycle(rho, lti, [(16, 16)], p)
    sti = pull_sti(rho, names, kernels)
    assert abs(sum(sti.values()) - 13.0) < 1e-10
    assert diagnostics["mass_error"] < 1e-10
    assert diagnostics["max_abs_divergence"] < 1e-10


def test_upwind_transport_is_positive_and_conservative() -> None:
    rho = np.zeros((16, 16)); rho[5, 5] = 2.0
    u = (np.full_like(rho, 0.4), np.zeros_like(rho))
    result = advect_conservative(rho, u, 0.2, 0.4)
    assert result.min() >= 0.0
    assert abs(result.sum() - rho.sum()) < 1e-12


def test_sobolev_regularization_and_mass_conservation() -> None:
    p = FluidPressure2Params(
        grid_size=32,
        steps=8,
        dt=0.02,
        hjb_steps=8,
        sobolev_mu=1.0,
        hjb_refresh_interval=4,
        af_cap=0.1,
    )
    coords = {"a": (0.0, 0.0), "b": (1.0, 0.2), "c": (0.2, 1.0)}
    names, kernels = kernel_matrix(coords, p)
    rho = push_sti({"a": 9.0, "b": 3.0, "c": 1.0}, names, kernels, p.grid_size)
    lti = push_sti({"a": 4.0, "b": 1.0, "c": 0.0}, names, kernels, p.grid_size)
    rho, _u, _pressure, diagnostics = run_cycle(rho, lti, [(16, 16)], p)
    sti = pull_sti(rho, names, kernels)

    # AF cap is respected and strictly conserves mass
    assert rho.max() <= 0.1 + 1e-9
    assert abs(sum(sti.values()) - 13.0) < 1e-10
    assert diagnostics["mass_error"] < 1e-10
    assert diagnostics["max_abs_divergence"] < 1e-10
    assert "enstrophy" in diagnostics and diagnostics["enstrophy"] >= 0.0
    assert "pressure_rms" in diagnostics and diagnostics["pressure_rms"] >= 0.0
    assert "pressure_max" in diagnostics and diagnostics["pressure_max"] >= 0.0


def test_coordinate_convention_asymmetry() -> None:
    from fluidPressure2.pipeline import _goal_reward
    p = FluidPressure2Params(grid_size=32, goal_radius=2.0)
    # Goal at x=8 (col 8), y=24 (row 24)
    reward = _goal_reward(32, [(8, 24)], p)
    # Maximum of reward must be located at [row=24, col=8]
    max_row, max_col = np.unravel_index(np.argmax(reward), reward.shape)
    assert (max_col, max_row) == (8, 24), f"Expected (x=8, y=24), got col={max_col}, row={max_row}"


def test_divergence_free_projection() -> None:
    from fluidPressure2.spectral import divergence, leray_project
    n = 32
    np.random.seed(42)
    u = (np.random.randn(n, n), np.random.randn(n, n))
    (u_proj_x, u_proj_y), _p = leray_project(u)
    div = divergence((u_proj_x, u_proj_y))
    assert np.max(np.abs(div)) < 1e-12, f"Expected machine-precision divergence, got {np.max(np.abs(div))}"


def test_hjb_dt_decoupling() -> None:
    from fluidPressure2.hjb import solve_backward_hjb
    from fluidPressure2.pipeline import _goal_reward
    p1 = FluidPressure2Params(grid_size=16, dt=0.2, hjb_steps=8, hjb_dt=0.01)
    p2 = FluidPressure2Params(grid_size=16, dt=0.01, hjb_steps=8, hjb_dt=0.01)
    reward = _goal_reward(16, [(8, 8)], p1)
    w1 = solve_backward_hjb(reward, p1)
    w2 = solve_backward_hjb(reward, p2)
    # Because hjb_dt is decoupled, changing simulation dt does not affect w
    assert np.allclose(w1, w2, atol=1e-12)


if __name__ == "__main__":
    test_round_trip_and_flow_conserve_sti()
    test_upwind_transport_is_positive_and_conservative()
    test_sobolev_regularization_and_mass_conservation()
    test_coordinate_convention_asymmetry()
    test_divergence_free_projection()
    test_hjb_dt_decoupling()
    print("fluidPressure2 checks passed")
