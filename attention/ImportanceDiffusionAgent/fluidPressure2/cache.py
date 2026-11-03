from __future__ import annotations

import os
import pickle
from typing import Any

from .graph import build_adjacency_matrix, extract_atoms, get_magnetic_coordinates, parse_metta_edges

_CACHE: dict[str, Any] = {}
_CACHE_VERSION = 1


def _fingerprint(path: str) -> tuple[int, int]:
    stat = os.stat(path)
    return stat.st_mtime_ns, stat.st_size


def _cache_path(path: str) -> str:
    stem, _extension = os.path.splitext(os.path.abspath(path))
    return stem + ".fluid_pressure2_cache.pkl"


def load_or_compute_manifold(metta_path: str) -> tuple[list[tuple[str, str, float, float]], list[str], dict[str, tuple[float, float]]]:
    """Load a validated local embedding cache or recompute it from the graph."""
    absolute_path = os.path.abspath(metta_path)
    fingerprint = _fingerprint(absolute_path)
    if _CACHE.get("path") == absolute_path and _CACHE.get("fingerprint") == fingerprint:
        return _CACHE["edges"], _CACHE["nodes"], _CACHE["coords"]
    disk_path = _cache_path(absolute_path)
    try:
        with open(disk_path, "rb") as handle:
            cached = pickle.load(handle)
        if cached.get("version") == _CACHE_VERSION and cached.get("fingerprint") == fingerprint:
            _CACHE.update(cached); _CACHE["path"] = absolute_path
            return cached["edges"], cached["nodes"], cached["coords"]
    except (OSError, EOFError, pickle.PickleError, AttributeError):
        pass
    edges = parse_metta_edges(absolute_path)
    nodes = extract_atoms(edges)
    coords = get_magnetic_coordinates(build_adjacency_matrix(edges, nodes), nodes)
    cached = {"version": _CACHE_VERSION, "fingerprint": fingerprint, "edges": edges, "nodes": nodes, "coords": coords}
    try:
        with open(disk_path, "wb") as handle:
            pickle.dump(cached, handle)
    except OSError:
        pass
    _CACHE.update(cached); _CACHE["path"] = absolute_path
    return edges, nodes, coords
