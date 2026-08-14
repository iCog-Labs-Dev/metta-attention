"""Fluid-graph frontier candidates for Mettaclaw.

MettaClaw already sees &af (names + STI) from atomspace in the prompt.
This module only answers what the shared atomspace does not: which
*out-of-AF* graph nodes are adjacent (EXPAND) or distant (BREAK), given
the current AF name set. SHARPEN / SETTLE are AF-side decisions.
"""

from __future__ import annotations

import re
from pathlib import Path

EDGE_PATTERN = re.compile(
    r"\(\((?P<link>\w+)\s+(?P<source>\S+)\s+(?P<target>\S+)\)\s+"
    r"\((?P<mean>[-+0-9.eE]+)\s+(?P<confidence>[-+0-9.eE]+)\)\)"
)

DEFAULT_GRAPH = Path(__file__).parent.parent / "data" / "adagram_sparse_random.metta"
GROUP_SIZE = 5
_GRAPH_CACHE: dict[str, dict[str, set[str]]] = {}


def _adjacency(graph_path: str | Path) -> dict[str, set[str]]:
    key = str(graph_path)
    cached = _GRAPH_CACHE.get(key)
    if cached is not None:
        return cached

    adjacency: dict[str, set[str]] = {}
    with open(key) as handle:
        for match in EDGE_PATTERN.finditer(handle.read()):
            source, target = match.group("source"), match.group("target")
            if source == target:
                continue
            adjacency.setdefault(source, set()).add(target)
            adjacency.setdefault(target, set()).add(source)

    _GRAPH_CACHE[key] = adjacency
    return adjacency


def _names(af_atoms) -> set[str]:
    """Flat AF name set from getAfAtoms (MeTTa list / atoms)."""
    if af_atoms is None:
        return set()
    if isinstance(af_atoms, (str, bytes)):
        text = af_atoms.decode() if isinstance(af_atoms, bytes) else af_atoms
        text = text.strip().strip('"')
        return {text} if text else set()

    get_children = getattr(af_atoms, "get_children", None)
    items = list(get_children()) if callable(get_children) else (
        list(af_atoms) if isinstance(af_atoms, (list, tuple)) else [af_atoms]
    )

    out: set[str] = set()
    for item in items:
        if isinstance(item, bytes):
            name = item.decode("utf-8", "replace")
        elif isinstance(item, str):
            name = item
        else:
            get_name = getattr(item, "get_name", None)
            name = str(get_name()) if callable(get_name) else str(item)
        name = name.strip().strip('"')
        if name:
            out.add(name)
    return out


def goal_candidates(af_atoms=None, graph_path=None, group_size=GROUP_SIZE):
    """Return EXPAND | BREAK relative to the AF, against the fluid graph."""
    size = int(group_size)
    adjacency = _adjacency(graph_path or DEFAULT_GRAPH)
    in_af = _names(af_atoms)

    outside = [(name, neighbours) for name, neighbours in adjacency.items() if name not in in_af]

    frontier = sorted(
        (
            (name, len(neighbours & in_af), len(neighbours))
            for name, neighbours in outside
            if neighbours & in_af
        ),
        key=lambda item: (-item[1], -item[2], item[0]),
    )
    expand = " ".join(f"{name}:{n}af" for name, n, _ in frontier[:size]) or "none"

    detached = sorted(
        (
            (name, len(neighbours))
            for name, neighbours in outside
            if not (neighbours & in_af)
        ),
        key=lambda item: (item[1], item[0]),
    )
    if not detached:
        detached = sorted(
            ((name, len(neighbours)) for name, neighbours in outside),
            key=lambda item: (len(adjacency[item[0]] & in_af), item[1], item[0]),
        )
    breakout = " ".join(f"{name}:d{degree}" for name, degree in detached[:size]) or "none"

    return f"EXPAND(out-AF, adjacent) {expand} | BREAK(out-AF, distant) {breakout}"
