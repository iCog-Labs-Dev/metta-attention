from __future__ import annotations

import numpy as np

from graph import spectral_to_grid_coords


def get_center_seed(grid_size: int, n_seeds: int = 4) -> list[tuple[int, int]]:
    center = grid_size // 2
    if n_seeds == 1:
        return [(center, center)]
    offsets = [(0, 0), (-4, 0), (4, 0), (0, -4), (0, 4)][:n_seeds]
    return [(center + dy, center + dx) for dy, dx in offsets]


def parse_goal_cells(
    af_seeds: str | list[str] | list[tuple[int, int]] | None,
    grid_size: int,
    spectral_coords: dict[str, tuple[float, float]] | None = None,
) -> list[tuple[int, int]]:
    """Resolve drain targets to grid pixel coordinates.

    af_seeds may be:
      - None                  -> center of grid (default fallback)
      - "center"              -> single center pixel
      - "y,x y,x ..."        -> explicit pixel coordinates (legacy)
      - list of atom names    -> resolved via spectral_coords
      - list of (int, int)    -> raw pixel coordinates
    """
    if af_seeds is None:
        seeds = get_center_seed(grid_size, n_seeds=4)
    elif isinstance(af_seeds, str):
        if af_seeds.lower() == "center":
            seeds = get_center_seed(grid_size, n_seeds=1)
        else:
            seeds = [tuple(map(int, seed.split(","))) for seed in af_seeds.split()]
    elif af_seeds and isinstance(af_seeds[0], str):
        seeds = []
        if spectral_coords is not None:
            positions = spectral_to_grid_coords(spectral_coords, grid_size)
            # seeds = [positions[atom] for atom in af_seeds if atom in positions]
            seeds = [(positions[atom][1], positions[atom][0]) for atom in af_seeds if atom in positions]
    else:
        seeds = af_seeds

    if not seeds:
        seeds = get_center_seed(grid_size, n_seeds=4)

    return [(seed_y % grid_size, seed_x % grid_size) for seed_y, seed_x in seeds]


def compute_distance_to_goals(
    grid_size: int, goal_cells: list[tuple[int, int]]
) -> np.ndarray:
    y_coords, x_coords = np.mgrid[0:grid_size, 0:grid_size]
    distance = np.full((grid_size, grid_size), np.inf, dtype=np.float64)
    for seed_y, seed_x in goal_cells:
        dy = np.abs(seed_y - y_coords)
        dy = np.minimum(dy, grid_size - dy)
        dx = np.abs(seed_x - x_coords)
        dx = np.minimum(dx, grid_size - dx)
        distance = np.minimum(distance, np.sqrt(dy**2 + dx**2))
    return distance


def compute_goal_mask(
    grid_size: int, goal_cells: list[tuple[int, int]], radius: int = 1
) -> np.ndarray:
    mask = np.zeros((grid_size, grid_size), dtype=bool)
    for seed_y, seed_x in goal_cells:
        for dy in range(-radius, radius + 1):
            for dx in range(-radius, radius + 1):
                mask[(seed_y + dy) % grid_size, (seed_x + dx) % grid_size] = True
    return mask


def compute_cost_field(distance: np.ndarray) -> np.ndarray:
    """Bellman/HJB cost from normalized toroidal distance to goal."""

    max_distance = float(np.max(distance)) or 1.0
    return distance / max_distance


def solve_value_field(
    cost: np.ndarray,
    gamma: float = 0.95,
    iterations: int = 100,
    goal_mask: np.ndarray | None = None,
) -> np.ndarray:
    """Discrete Bellman-style value field W used to guide fluid control."""

    value = cost.copy()
    if goal_mask is not None:
        value[goal_mask] = 0.0

    for _ in range(iterations):
        neighbor_min = np.minimum.reduce(
            [
                np.roll(value, 1, axis=0),
                np.roll(value, -1, axis=0),
                np.roll(value, 1, axis=1),
                np.roll(value, -1, axis=1),
            ]
        )
        value = cost + gamma * neighbor_min
        if goal_mask is not None:
            value[goal_mask] = 0.0
    return value


def compute_control_from_value(value: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    grad_y = (np.roll(value, -1, axis=0) - np.roll(value, 1, axis=0)) / 2.0
    grad_x = (np.roll(value, -1, axis=1) - np.roll(value, 1, axis=1)) / 2.0
    return -grad_x, -grad_y
