from __future__ import annotations

import numpy as np

from .burgers import burgers_rhs
from .spectral import leray_project


def _density_weighted_force(
    policy: tuple[np.ndarray, np.ndarray],
    rho: np.ndarray,
) -> tuple[np.ndarray, np.ndarray]:
    
    rho_mean = float(np.mean(rho))
    if rho_mean < 1e-300:
        return np.zeros_like(policy[0]), np.zeros_like(policy[1])
    scale = rho / rho_mean
    return scale * policy[0], scale * policy[1]

def navier_stokes_step(
    u: tuple[np.ndarray, np.ndarray],
    policy: tuple[np.ndarray, np.ndarray],
    rho: np.ndarray,
    viscosity: np.ndarray,
    dt: float,
    force_gain: float,
    cfl: float = 0.4,
) -> tuple[tuple[np.ndarray, np.ndarray], np.ndarray]:
    
    # Viscous Burgers predictor:  −(u·∇)u + ∇·(ν∇u)
    bx, by = burgers_rhs(u, viscosity)

    # Density-weighted body force from HJB policy 
    fx, fy = _density_weighted_force(policy, rho)

    # Intermediate velocity u* 
    u_star_x = u[0] + dt * (bx + force_gain * fx)
    u_star_y = u[1] + dt * (by + force_gain * fy)

    # Leray / Helmholtz-Hodge projection: enforce ∇·u = 0
    # p is the Lagrange multiplier
    (u_new_x, u_new_y), pressure = leray_project((u_star_x, u_star_y))

    # CFL velocity rescaling
    speed = float(np.max(np.abs(u_new_x) + np.abs(u_new_y)))
    if speed * dt > cfl and speed > 0.0:
        scale = cfl / (speed * dt)
        u_new_x = u_new_x * scale
        u_new_y = u_new_y * scale

    return (u_new_x, u_new_y), pressure

def advect_conservative(
    rho: np.ndarray,
    u: tuple[np.ndarray, np.ndarray],
    dt: float,
    cfl: float,
) -> np.ndarray:
   
    ux, uy = u
    max_speed = float(np.max(np.abs(ux) + np.abs(uy)))
    substeps = max(1, int(np.ceil(dt * max_speed / max(cfl, 1e-12))))
    h = dt / substeps
    out = rho.copy()

    # Face-centred velocity 
    # consistent with the divergence-free projection on the same stencil
    fx_speed = 0.5 * (ux + np.roll(ux, -1, axis=1))
    fy_speed = 0.5 * (uy + np.roll(uy, -1, axis=0))

    for _ in range(substeps):
        fx = np.where(fx_speed >= 0.0, out, np.roll(out, -1, axis=1)) * fx_speed
        fy = np.where(fy_speed >= 0.0, out, np.roll(out, -1, axis=0)) * fy_speed

        # Conservative update
        out = out - h * (
            (fx - np.roll(fx, 1, axis=1)) +
            (fy - np.roll(fy, 1, axis=0))
        )
        out = np.maximum(out, 0.0)
    return out
