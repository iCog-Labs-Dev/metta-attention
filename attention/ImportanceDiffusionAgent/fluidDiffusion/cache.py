from __future__ import annotations

import logging
import os
import pickle
from typing import Any

import numpy as np

from graph import (
    parse_metta_edges,
    extract_atoms,
    build_adjacency_matrix,
    get_spectral_coordinates_magnetic,
)
from params import FluidParams
from transport import precompute_fourier_velocity_modes


_logger = logging.getLogger(__name__)
_GRAPH_CACHE: dict[str, Any] = {}


def _pickle_path_for(metta_path: str) -> str:
    """Return pickle cache path adjacent to the source .metta file."""
    base, _ = os.path.splitext(os.path.abspath(metta_path))
    return base + ".fluid_cache.pkl"


def _file_fingerprint(metta_path: str) -> float:
    """Return file modification time, or 0.0 on error."""
    try:
        return os.path.getmtime(metta_path)
    except OSError:
        return 0.0


def _load_or_compute_graph_data(
    metta_path: str, params: FluidParams
) -> tuple[
    list[tuple[str, str, float, float]],
    list[str],
    dict[str, tuple[float, float]],
    list[tuple[np.ndarray, np.ndarray]],
]:
    """Load graph data with dual-cache fallback (RAM -> Disk -> Recompute)."""
    global _GRAPH_CACHE

    fingerprint = _file_fingerprint(metta_path)
    abs_path = os.path.abspath(metta_path)
    pkl_path = _pickle_path_for(metta_path)

    def is_valid(c: dict[str, Any]) -> bool:
        return (
            c.get("fingerprint") == fingerprint
            and c.get("grid_size") == params.grid_size
            and c.get("k_max") == params.k_max
        )

    def extract(c: dict[str, Any]) -> tuple:
        return c["edges"], c["nodes"], c["coords"], c["modes"]

    if _GRAPH_CACHE.get("metta_path") == abs_path and is_valid(_GRAPH_CACHE):
        return extract(_GRAPH_CACHE)

    if os.path.exists(pkl_path):
        try:
            with open(pkl_path, "rb") as f:
                cached = pickle.load(f)
            if is_valid(cached):
                _GRAPH_CACHE.update(cached)
                _GRAPH_CACHE["metta_path"] = abs_path
                return extract(cached)
        except Exception as e:
            _logger.warning("Disk cache read failed (%s), recomputing: %s", pkl_path, e)

    edges = parse_metta_edges(metta_path)
    nodes = extract_atoms(edges)
    matrix, _ = build_adjacency_matrix(edges, nodes)
    coords = get_spectral_coordinates_magnetic(matrix, nodes)
    modes = precompute_fourier_velocity_modes(params.grid_size, params.k_max)

    cache_data = {
        "fingerprint": fingerprint,
        "grid_size": params.grid_size,
        "k_max": params.k_max,
        "edges": edges,
        "nodes": nodes,
        "coords": coords,
        "modes": modes,
    }

    try:
        with open(pkl_path, "wb") as f:
            pickle.dump(cache_data, f)
    except Exception as e:
        _logger.warning("Disk cache write failed (%s): %s", pkl_path, e)

    _GRAPH_CACHE.update(cache_data)
    _GRAPH_CACHE["metta_path"] = abs_path

    return extract(cache_data)
