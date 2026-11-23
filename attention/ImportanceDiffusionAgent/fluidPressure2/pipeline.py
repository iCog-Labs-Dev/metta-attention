from __future__ import annotations

from typing import Any

import numpy as np

from .hjb import sg_policy_proxy, solve_backward_hjb
from .navier_stokes import advect_conservative, navier_stokes_step
from .params import FluidPressure2Params
from .spectral import divergence, vorticity


def build_goal_potential(
    n: int,
    goals: list[tuple[int, int]],
    params: FluidPressure2Params,
) -> np.ndarray:
    yy, xx = np.mgrid[0:n, 0:n]
    if not goals:
        return np.zeros((n, n), dtype=float)

    if params.use_global_potential:
        dist = np.full((n, n), 1e9, dtype=float)
        for gx, gy in goals:
            dx = np.minimum(np.abs(xx - gx), n - np.abs(xx - gx))
            dy = np.minimum(np.abs(yy - gy), n - np.abs(yy - gy))
            dist = np.minimum(dist, np.sqrt(dx * dx + dy * dy))
        max_dist = float(np.max(dist))
        cost = dist / max_dist if max_dist > 0.0 else np.zeros_like(dist)
        return params.goal_strength * (1.0 - cost)
    else:
        v = np.zeros((n, n), dtype=float)
        r2 = params.goal_radius ** 2
        for gx, gy in goals:
            dx = np.minimum(np.abs(xx - gx), n - np.abs(xx - gx))
            dy = np.minimum(np.abs(yy - gy), n - np.abs(yy - gy))
            v = np.maximum(v, np.exp(-(dx * dx + dy * dy) / (2.0 * r2)))
        return params.goal_strength * v


def viscosity_from_lti(
    lti_rho: np.ndarray,
    params: FluidPressure2Params,
) -> np.ndarray:
    #Compute spatially varying ν(x) from LTI density field.

    lti_max = float(np.max(lti_rho))
    if lti_max <= 0.0:
        return np.full_like(lti_rho, params.nu)
    habit = lti_rho / lti_max
    return params.nu * np.maximum(0.05, 1.0 - params.lti_viscosity_strength * habit)


def conservative_cap(rho: np.ndarray, cap: float) -> np.ndarray:
    #Cap per-cell density at `cap` while strictly conserving total mass.

    if cap <= 0.0:
        return rho
    total = float(rho.sum())
    if total <= 0.0:
        return rho

    # Rescale cap so that capacity == budget when budget > raw capacity.
    effective_cap = max(cap, total / rho.size)

    out = np.minimum(rho, effective_cap)
    for _ in range(200):
        excess = total - float(out.sum())
        if abs(excess) <= 1e-12:
            break
        headroom = effective_cap - out
        available = headroom > 1e-12
        if not np.any(available):
            break
        total_headroom = float(headroom[available].sum())
        if total_headroom <= 0.0:
            break
        add = np.where(available, excess * headroom / total_headroom, 0.0)
        out = np.minimum(out + add, effective_cap)
    return out


def run_cycle(
    rho: np.ndarray,
    lti_rho: np.ndarray,
    goals: list[tuple[int, int]],
    params: FluidPressure2Params,
) -> tuple[np.ndarray, tuple[np.ndarray, np.ndarray], np.ndarray, dict[str, Any]]:
    
    n = params.grid_size
    initial_mass = float(rho.sum())

    # Stage 1: Goal potential V
    reward = build_goal_potential(n, goals, params)

    # Stage 2: Backward HJB → value W → policy U*
    value = solve_backward_hjb(reward, params)
    policy = sg_policy_proxy(value, params.sobolev_mu)

    # Stage 3: LTI → spatially varying ν(x)
    viscosity = viscosity_from_lti(lti_rho, params)

    # Stage 4: NS + advection time-stepping loop
    u: tuple[np.ndarray, np.ndarray] = (np.zeros_like(rho), np.zeros_like(rho))
    pressure = np.zeros_like(rho)

    for step in range(params.steps):
        # Optional periodic HJB refresh 
        if (
            params.hjb_refresh_interval > 0
            and step > 0
            and step % params.hjb_refresh_interval == 0
        ):
            value = solve_backward_hjb(reward, params)
            policy = sg_policy_proxy(value, params.sobolev_mu)

        # Navier-Stokes step  
        u, pressure = navier_stokes_step(
            u, policy, rho, viscosity,
            params.dt, params.force_gain, params.cfl,
        )

        # Advect ρ with u^{n+1}  
        rho = advect_conservative(rho, u, params.dt, params.cfl)

        # AF cap / MaxSpread  
        if params.af_cap is not None and params.af_cap > 0.0:
            rho = conservative_cap(rho, params.af_cap)

    # Diagnostics
    omega = vorticity(u)
    div_u = divergence(u)

    yy, xx = np.mgrid[0:n, 0:n]
    goal_r = max(2, n // 16)
    goal_mask = np.zeros((n, n), dtype=bool)
    for gx, gy in goals:
        dx = np.minimum(np.abs(xx - gx), n - np.abs(xx - gx))
        dy = np.minimum(np.abs(yy - gy), n - np.abs(yy - gy))
        goal_mask |= (dx * dx + dy * dy) <= goal_r * goal_r

    if goals:
        dist = np.full((n, n), 1e9)
        for gx, gy in goals:
            dx = np.minimum(np.abs(xx - gx), n - np.abs(xx - gx))
            dy = np.minimum(np.abs(yy - gy), n - np.abs(yy - gy))
            dist = np.minimum(dist, np.sqrt(dx * dx + dy * dy))
        rho_sum = float(rho.sum())
        expected_distance = float(np.sum(rho * dist)) / rho_sum if rho_sum > 0 else 0.0
    else:
        expected_distance = 0.0

    diagnostics: dict[str, Any] = {
        "initial_sti_total": initial_mass,
        "final_sti_total": float(rho.sum()),
        "mass_error": abs(float(rho.sum()) - initial_mass),
        "max_abs_divergence": float(np.abs(div_u).max()),
        "l2_divergence": float(np.linalg.norm(div_u)),
        "pressure_rms": float(np.sqrt(np.mean(pressure * pressure))),
        "pressure_max": float(np.max(np.abs(pressure))),
        "enstrophy": 0.5 * float(np.mean(omega * omega)),
        "goal_mass": float(rho[goal_mask].sum()) if goal_mask.any() else 0.0,
        "expected_distance": expected_distance,
        "goal_cells": goals,
    }
    return rho, u, pressure, diagnostics
