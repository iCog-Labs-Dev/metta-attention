from __future__ import annotations

import sys
import numpy as np
from pathlib import Path

# Resolve fluidDiffusion as a sibling directory regardless of cwd
_FD = str(Path(__file__).resolve().parent.parent / "fluidDiffusion")
if _FD not in sys.path:
    sys.path.insert(0, _FD)

from graph import (
    get_spectral_coordinates_magnetic as _fd_embed,   # unnormalized Laplacian
    spectral_to_grid_coords           as _fd_rank_grid,  # rank-based mapping
)
from .params import FluidPressure2Params

#  1. Embedding: FD's unnormalized magnetic Laplacian 

def fd_get_magnetic_coordinates(matrix, nodes, q=0.25):
    
    return _fd_embed(matrix, nodes, q=q)

#  2. Grid mapping: FD's rank-based normalization 

def fd_positions_to_grid(coords, n):
   
    return _fd_rank_grid(coords, n)

#  3. Kernel matrix: FD's 7×7 truncated Gaussian loop 

def fd_kernel_matrix(
    coords: dict,
    params: FluidPressure2Params,
) -> tuple[list, np.ndarray]:
   
    names = list(coords.keys())
    n = params.grid_size
    sigma = params.kernel_sigma   # use FP2's kernel_sigma as the spread param

    # Use FD's rank-based grid positions
    grid_positions = fd_positions_to_grid(coords, n)

    yy, xx = np.mgrid[0:n, 0:n]
    columns = []

    for name in names:
        grid_x, grid_y = grid_positions[name]
        col = np.zeros(n * n, dtype=np.float64)

        for dy in range(-3, 4):
            for dx in range(-3, 4):
                dist_sq = dx * dx + dy * dy
                if dist_sq <= sigma * sigma * 9:   # circular cutoff: radius=3σ
                    gaussian = np.exp(-dist_sq / (2 * sigma ** 2))
                    px = (grid_x + dx) % n
                    py = (grid_y + dy) % n
                    col[py * n + px] += gaussian

        columns.append(col)

    K_raw = np.column_stack(columns)   # shape: (n*n, N_atoms)


    return names, K_raw

#  4. Push: FD-style (uses K_raw, applies global normalize) 

def fd_push_sti(
    sti: dict,
    names: list,
    K_raw: np.ndarray,
    n: int,
) -> np.ndarray:
   
    weights = np.array([max(0.0, float(sti.get(name, 0.0))) for name in names])
    rho = (K_raw @ weights).reshape(n, n)
    total = float(rho.sum())
    if total > 0:
        rho /= total
    return rho

#  5. Pull: FD-style (3×3 box sum + global renormalize) 

def fd_pull_sti(
    rho: np.ndarray,
    names: list,
    coords: dict,
    params: FluidPressure2Params,
    total_sti: float,
) -> dict:
    
    n = params.grid_size
    radius = 1   # mirrors FD's density_radius=1

    grid_positions = fd_positions_to_grid(coords, n)
    densities = {}

    for name in names:
        grid_x, grid_y = grid_positions[name]
        d = 0.0
        for dy in range(-radius, radius + 1):
            for dx in range(-radius, radius + 1):
                px = (grid_x + dx) % n
                py = (grid_y + dy) % n
                d += float(rho[py, px])
        densities[name] = d

    total_density = sum(densities.values()) or 1.0
    return {
        atom: total_sti * d / total_density
        for atom, d in densities.items()
        if d > 0
    }
 