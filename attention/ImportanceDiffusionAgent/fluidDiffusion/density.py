from __future__ import annotations

import numpy as np
import scipy.sparse

from graph import (
    build_adjacency_matrix,
    get_spectral_coordinates_magnetic,
    spectral_to_grid_coords,
)
from params import DEFAULT_STI, FluidParams


def push_sti_to_density(
    edges: list[tuple[str, str, float, float]],
    nodes: list[str],
    params: FluidParams,
    sti_values: dict[str, float] | None = None,
    spectral_coords: dict[str, tuple[float, float]] | None = None,
) -> tuple[np.ndarray, dict[str, tuple[float, float]]]:
    """Push current MeTTa STI values into a normalized density rho."""

    matrix: scipy.sparse.csr_matrix | None = None
    if spectral_coords is None:
        matrix, node_to_idx = build_adjacency_matrix(edges, nodes)
        spectral_coords = get_spectral_coordinates_magnetic(matrix, nodes)
    else:
        node_to_idx = {node: i for i, node in enumerate(nodes)}

    if sti_values:
        node_sti = sti_values
    else:
        if matrix is None:
            matrix, _ = build_adjacency_matrix(edges, nodes)
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
