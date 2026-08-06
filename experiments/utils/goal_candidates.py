"""Goal candidates for Mettaclaw, ranked by degree in the fluid transport graph.

The fluid simulation resolves goal names against `adagram_sparse_random.metta` and
silently falls back to grid-centre seeds for anything it cannot find, so candidates
are drawn from that file and no other. See `mettaclaw_goal_rules_minimal.md`.
"""

from __future__ import annotations

import re
from pathlib import Path

EDGE_PATTERN = re.compile(
    r"\(\((?P<link>\w+)\s+(?P<source>\S+)\s+(?P<target>\S+)\)\s+"
    r"\((?P<mean>[-+0-9.eE]+)\s+(?P<confidence>[-+0-9.eE]+)\)\)"
)

DEFAULT_GRAPH = Path(__file__).parent.parent / "data" / "adagram_sparse_random.metta"

MID_DEGREE_RANGE = (4, 8)
GROUP_SIZE = 5

_DEGREE_CACHE: dict[str, dict[str, int]] = {}
_CALL_COUNT = 0


def _degrees(graph_path: str | Path) -> dict[str, int]:
    """Undirected degree per node. Cached — the graph file is static."""
    key = str(graph_path)
    cached = _DEGREE_CACHE.get(key)
    if cached is not None:
        return cached

    degrees: dict[str, int] = {}
    with open(key) as handle:
        for match in EDGE_PATTERN.finditer(handle.read()):
            for node in (match.group("source"), match.group("target")):
                degrees[node] = degrees.get(node, 0) + 1

    _DEGREE_CACHE[key] = degrees
    return degrees


def _names(atoms) -> set[str]:
    """Flatten whatever MeTTa hands over into a set of plain atom names."""
    if atoms is None:
        return set()

    if isinstance(atoms, (str, bytes)):
        return {str(atoms)}

    collected: set[str] = set()
    try:
        children = list(atoms)
    except TypeError:
        children = []

    if children:
        for child in children:
            collected |= _names(child)
        return collected

    get_name = getattr(atoms, "get_name", None)
    if callable(get_name):
        try:
            return {str(get_name())}
        except Exception:
            pass

    return {str(atoms)}


def _format(label: str, entries: list[tuple[str, int]]) -> str:
    return f"{label} " + " ".join(f"{name}:{degree}" for name, degree in entries)


def goal_candidates(af_atoms=None, graph_path=None, group_size=GROUP_SIZE):
    """Return HUBS / MID / LEAVES candidate groups as a single prompt-ready string.

    Atoms currently in the AF are excluded: a goal that already worked will have
    pulled its concept into the AF, so this doubles as recency filtering. The MID
    window rotates between calls so exploration does not stall on the same names.
    """
    global _CALL_COUNT

    size = int(group_size)
    degrees = _degrees(graph_path or DEFAULT_GRAPH)
    in_af = _names(af_atoms)

    outside = sorted(
        ((name, deg) for name, deg in degrees.items() if name not in in_af),
        key=lambda item: (-item[1], item[0]),
    )
    if not outside:
        return "GOAL_CANDIDATES none available - every graph node is in the AF"

    low, high = MID_DEGREE_RANGE
    mid_pool = [entry for entry in outside if low <= entry[1] <= high]

    if mid_pool:
        offset = (_CALL_COUNT * size) % len(mid_pool)
        rotated = mid_pool[offset:] + mid_pool[:offset]
        mid = rotated[:size]
    else:
        mid = outside[len(outside) // 2 :][:size]

    _CALL_COUNT += 1

    return " | ".join(
        [
            _format("HUBS", outside[:size]),
            _format("MID", mid),
            _format("LEAVES", list(reversed(outside[-size:]))),
        ]
    )
