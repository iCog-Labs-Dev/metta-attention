from __future__ import annotations

import numpy as np

from .spectral import gradient, laplacian


def burgers_rhs(u: tuple[np.ndarray, np.ndarray], viscosity: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    """- (u·grad)u + div(viscosity grad u), prior to force and pressure.

    Evaluated using analytical expansion div(nu grad u) = nu Δu + grad(nu)·grad(u).
    """
    ux, uy = u
    ux_x, ux_y = gradient(ux)
    uy_x, uy_y = gradient(uy)

    # Non-linear convective acceleration: (u · grad) u
    conv_x = ux * ux_x + uy * ux_y
    conv_y = ux * uy_x + uy * uy_y

    # Analytically expanded variable-viscosity diffusion:
    # div(nu grad u) = nu Δu + (grad nu) · (grad u)
    nu_x, nu_y = gradient(viscosity)
    diff_x = viscosity * laplacian(ux) + (nu_x * ux_x + nu_y * ux_y)
    diff_y = viscosity * laplacian(uy) + (nu_x * uy_x + nu_y * uy_y)

    return diff_x - conv_x, diff_y - conv_y
