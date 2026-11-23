from __future__ import annotations

import numpy as np

from .params import FluidPressure2Params

def positions_to_grid(coords: dict[str, tuple[float, float]], n: int) -> dict[str, tuple[int, int]]:
    if not coords:
        return {}
    points = np.asarray(list(coords.values()), dtype=float)
    lo, hi = points.min(axis=0), points.max(axis=0)
    span = np.maximum(hi - lo, 1e-12)
    return {name: tuple((np.rint((point - lo) / span * (n - 1)).astype(int) % n).tolist()) for name, point in coords.items()}


def kernel_matrix(coords: dict[str, tuple[float, float]], params: FluidPressure2Params) -> tuple[list[str], np.ndarray]:
    """Columns are normalised kernels, so scatter preserves total STI exactly."""
    names, n = list(coords), params.grid_size
    if not names:
        return names, np.zeros((n * n, 0))
    positions, yy, xx = positions_to_grid(coords, n), *np.mgrid[0:n, 0:n]
    columns = []
    for name in names:
        x, y = positions[name]
        dx = np.minimum(np.abs(xx - x), n - np.abs(xx - x))
        dy = np.minimum(np.abs(yy - y), n - np.abs(yy - y))
        col = np.exp(-(dx * dx + dy * dy) / (2.0 * params.kernel_sigma**2))
        columns.append((col / col.sum()).ravel())
    return names, np.column_stack(columns)


def push_sti(sti: dict[str, float], names: list[str], kernels: np.ndarray, n: int) -> np.ndarray:
    weights = np.asarray([max(0.0, float(sti.get(name, 0.0))) for name in names])
    return (kernels @ weights).reshape(n, n)


def pull_sti(rho: np.ndarray, names: list[str], kernels: np.ndarray) -> dict[str, float]:
    """Grid-cell mass is assigned with a partition of unity: total STI is exact."""
    denominator = kernels.sum(axis=1, keepdims=True)
    responsibility = np.divide(kernels, denominator, out=np.zeros_like(kernels), where=denominator > 0)
    return {name: float(value) for name, value in zip(names, rho.ravel() @ responsibility)}
