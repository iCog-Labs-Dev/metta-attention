from __future__ import annotations

import numpy as np

from .params import FluidPressure2Params
from .spectral import heat_step, sobolev_gradient

_PHI_FLOOR = 1e-300


def solve_backward_hjb(
    reward: np.ndarray,
    params: FluidPressure2Params,
) -> np.ndarray:
    nu = max(float(params.nu), 1e-6)

    # Decouple HJB dt from NS dt for numerical stability 
    dt_hjb = float(params.hjb_dt) if params.hjb_dt is not None else min(float(params.dt), 0.05)

    # Source term in the Cole-Hopf heat equation: V / (2ν)
    # Clipped to prevent exp overflow in the half-step multiplier
    source = np.clip(reward / (2.0 * nu), -50.0, 50.0)

    # Terminal condition: W(T)=0  ⟹  Φ(τ=0) = exp(0) = 1
    phi = np.ones_like(reward, dtype=np.float64)

    # Accumulated log-scale to track the normalisation drift exactly
    log_scale = 0.0

    for _ in range(params.hjb_steps):
        # 1. Half source step: Φ ← Φ · exp(dt/2 · V/(2ν))
        phi = phi * np.exp(0.5 * dt_hjb * source)

        # 2. Exact heat step:  Φ ← exp(ν Δ dt) Φ 
        phi = heat_step(phi, nu, dt_hjb)

        # 3. Half source step again
        phi = phi * np.exp(0.5 * dt_hjb * source)

        # Normalise to prevent floating-point overflow; track removed scale
        max_phi = float(np.max(phi))
        if max_phi > 0.0:
            phi /= max_phi
            log_scale += np.log(max_phi)

        # Enforce strict positivity
        phi = np.maximum(phi, _PHI_FLOOR)

    # Recover W 
    w = -2.0 * nu * (np.log(np.maximum(phi, _PHI_FLOOR)) + log_scale)
    return w


def sg_policy_proxy(
    value: np.ndarray,
    mu: float = 0.0,
) -> tuple[np.ndarray, np.ndarray]:
    gx, gy = sobolev_gradient(value, mu)
    return -gx, -gy
