"""Fluid-graph frontier candidates for Mettaclaw.

MettaClaw already sees &af (names + STI) from atomspace in the prompt.
This module answers which out-of-AF graph nodes are adjacent (EXPAND)
or distant (BREAK), given the current AF name set.

Modes:
- STATIC (default, USE_DYNAMIC = False): Computes frontier against the static
  fluid transport graph (adagram_sparse_random.metta).
- DYNAMIC (USE_DYNAMIC = True): Augments the frontier with live AtomSpace
  Hebbian links created by HebbianCreationAgent/HebbianUpdatingAgent,
  properly unpacking STV (mean * confidence) and filtering top 20% strongest links.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import Any, Iterable

EDGE_PATTERN = re.compile(
    r"\(\((?P<link>\w+)\s+(?P<source>\S+)\s+(?P<target>\S+)\)\s+"
    r"\((?P<mean>[-+0-9.eE]+)\s+(?P<confidence>[-+0-9.eE]+)\)\)"
)

DEFAULT_GRAPH = Path(__file__).parent.parent / "data" / "adagram_sparse_random.metta"
GROUP_SIZE = 5
USE_DYNAMIC = False  # Toggle: False = Static graph default, True = Dynamic Hebbian AtomSpace
HEBBIAN_TOP_PERCENTILE = 0.20  # Keep top 20% strongest Hebbian links
HEBBIAN_MIN_WEIGHT = 0.05      # Minimum expected strength (mean * conf)

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


def _children(atom: Any) -> list[Any] | None:
    if isinstance(atom, (list, tuple)):
        return list(atom)
    get_children = getattr(atom, "get_children", None)
    if callable(get_children):
        try:
            return list(get_children())
        except Exception:
            return None
    return None


def _atom_name(atom: Any) -> str:
    if isinstance(atom, bytes):
        name = atom.decode("utf-8", "replace")
    elif isinstance(atom, str):
        name = atom
    else:
        get_name = getattr(atom, "get_name", None)
        name = str(get_name()) if callable(get_name) else str(atom)
    return name.strip().strip('"')


def _names(af_atoms) -> set[str]:
    """Flat AF name set from getAfAtoms (MeTTa list / atoms)."""
    if af_atoms is None:
        return set()
    if isinstance(af_atoms, (str, bytes)):
        text = af_atoms.decode() if isinstance(af_atoms, bytes) else af_atoms
        text = text.strip().strip('"')
        return {text} if text else set()

    children = _children(af_atoms)
    items = children if children is not None else (
        list(af_atoms) if isinstance(af_atoms, (list, tuple)) else [af_atoms]
    )

    out: set[str] = set()
    for item in items:
        name = _atom_name(item)
        if name:
            out.add(name)
    return out


def _parse_stv_weight(val_part: Any) -> float:
    """Properly extract expected associative strength from STV (mean * confidence)."""
    if val_part is None:
        return 0.5

    # Check if val_part has children e.g. [mean, conf]
    val_children = _children(val_part)
    if val_children and len(val_children) >= 2:
        try:
            mean = float(_atom_name(val_children[0]))
            conf = float(_atom_name(val_children[1]))
            return max(0.0, min(1.0, mean * conf))
        except (ValueError, TypeError):
            pass
    elif val_children and len(val_children) == 1:
        try:
            return float(_atom_name(val_children[0]))
        except (ValueError, TypeError):
            pass

    # String fallback e.g. "(0.85 0.90)" or "0.85"
    raw_str = _atom_name(val_part).strip("()[]")
    tokens = [t for t in raw_str.split() if t]
    if len(tokens) >= 2:
        try:
            mean = float(tokens[0])
            conf = float(tokens[1])
            return max(0.0, min(1.0, mean * conf))
        except (ValueError, TypeError):
            pass
    elif len(tokens) == 1:
        try:
            return float(tokens[0])
        except (ValueError, TypeError):
            pass

    return 0.5


def _extract_hebbian_edges(hebbian_data: Any) -> list[tuple[str, str, float]]:
    """Extract (source, target, weight) tuples from getAllHebLinksWithValues."""
    if not hebbian_data:
        return []

    records = _children(hebbian_data) or (
        list(hebbian_data) if isinstance(hebbian_data, Iterable) and not isinstance(hebbian_data, (str, bytes)) else [hebbian_data]
    )

    edges: list[tuple[str, str, float]] = []
    for record in records:
        parts = _children(record)
        if not parts:
            continue

        # Format: [ (ASYMMETRIC_HEBBIAN_LINK src tgt), (mean conf) ]
        link_part = parts[0]
        weight = 0.5
        if len(parts) >= 2:
            weight = _parse_stv_weight(parts[1])

        link_children = _children(link_part) or parts
        names = [
            _atom_name(c) for c in link_children
            if _atom_name(c) not in {"ASYMMETRIC_HEBBIAN_LINK", "SYMMETRIC_HEBBIAN_LINK", "HEBBIAN_LINK"}
        ]

        if len(names) >= 2:
            src, tgt = names[0], names[1]
            if src != tgt:
                edges.append((src, tgt, weight))

    return edges


def _filter_strong_hebbian_edges(
    edges: list[tuple[str, str, float]],
    top_percentile: float = HEBBIAN_TOP_PERCENTILE,
    min_weight: float = HEBBIAN_MIN_WEIGHT,
) -> dict[str, dict[str, float]]:
    """Threshold Hebbian links to top N% expected weights to avoid clique-saturation."""
    if not edges:
        return {}

    # Sort edges descending by STV weight (mean * conf)
    sorted_edges = sorted(edges, key=lambda e: e[2], reverse=True)
    
    # Filter by min_weight and percentile cutoff
    cutoff_idx = max(1, int(len(sorted_edges) * top_percentile))
    strong_edges = [e for e in sorted_edges[:cutoff_idx] if e[2] >= min_weight]

    hebbian_adj: dict[str, dict[str, float]] = {}
    for src, tgt, weight in strong_edges:
        hebbian_adj.setdefault(src, {})[tgt] = weight
        hebbian_adj.setdefault(tgt, {})[src] = weight

    return hebbian_adj


def goal_candidates_static(af_atoms=None, graph_path=None, group_size=GROUP_SIZE) -> str:
    """STATIC mode: Return EXPAND | BREAK relative to AF, purely from static fluid graph."""
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


def goal_candidates_dynamic(
    af_atoms=None,
    hebbian_links=None,
    graph_path=None,
    group_size=GROUP_SIZE,
    top_percentile: float = HEBBIAN_TOP_PERCENTILE,
    min_weight: float = HEBBIAN_MIN_WEIGHT,
) -> str:
    """DYNAMIC mode: Augments static graph with top-thresholded live Hebbian links from AtomSpace."""
    size = int(group_size)
    static_adj = _adjacency(graph_path or DEFAULT_GRAPH)
    in_af = _names(af_atoms)

    # Parse and threshold live Hebbian links from AtomSpace
    raw_hebbian = _extract_hebbian_edges(hebbian_links)
    hebb_adj = _filter_strong_hebbian_edges(raw_hebbian, top_percentile, min_weight)

    # All known nodes (from static graph + any dynamic Hebbian nodes)
    all_nodes = set(static_adj.keys()) | set(hebb_adj.keys())
    outside_nodes = [name for name in all_nodes if name not in in_af]

    # Score EXPAND: nodes connected to AF via static edges OR strong Hebbian links
    expand_candidates = []
    for name in outside_nodes:
        static_af_neighbors = static_adj.get(name, set()) & in_af
        hebb_af_neighbors = set(hebb_adj.get(name, {}).keys()) & in_af

        if static_af_neighbors or hebb_af_neighbors:
            hebb_weight = sum(hebb_adj.get(name, {}).get(af_n, 0.0) for af_n in hebb_af_neighbors)
            score = len(static_af_neighbors) * 1.0 + len(hebb_af_neighbors) * 2.0 + hebb_weight
            expand_candidates.append((name, len(static_af_neighbors), len(hebb_af_neighbors), score))

    expand_candidates.sort(key=lambda item: (-item[3], item[0]))
    expand = " ".join(
        f"{name}:{n_stat}af+{n_heb}heb" if n_heb > 0 else f"{name}:{n_stat}af"
        for name, n_stat, n_heb, _ in expand_candidates[:size]
    ) or "none"

    # Score BREAK: nodes with ZERO connections to the current AF in BOTH static AND Hebbian graphs
    break_candidates = []
    for name in outside_nodes:
        static_af_neighbors = static_adj.get(name, set()) & in_af
        hebb_af_neighbors = set(hebb_adj.get(name, {}).keys()) & in_af

        if len(static_af_neighbors) == 0 and len(hebb_af_neighbors) == 0:
            total_deg = len(static_adj.get(name, set())) + len(hebb_adj.get(name, {}))
            break_candidates.append((name, total_deg))

    if not break_candidates:
        # Fallback: pick nodes with lowest total connectivity to AF
        for name in outside_nodes:
            static_af_neighbors = static_adj.get(name, set()) & in_af
            hebb_af_neighbors = set(hebb_adj.get(name, {}).keys()) & in_af
            af_conn = len(static_af_neighbors) + len(hebb_af_neighbors)
            total_deg = len(static_adj.get(name, set()))
            break_candidates.append((name, af_conn, total_deg))
        break_candidates.sort(key=lambda item: (item[1], item[2], item[0]))
        breakout = " ".join(f"{name}:c{conn}" for name, conn, _ in break_candidates[:size]) or "none"
    else:
        break_candidates.sort(key=lambda item: (item[1], item[0]))
        breakout = " ".join(f"{name}:d{deg}" for name, deg in break_candidates[:size]) or "none"

    return f"EXPAND(out-AF, dynamic-adj) {expand} | BREAK(out-AF, isolated) {breakout}"


def _parse_bool(val: Any) -> bool:
    if isinstance(val, bool):
        return val
    if isinstance(val, (int, float)):
        return bool(val)
    val_str = str(val).strip().strip("\"'").lower()
    return val_str in ("true", "1", "yes", "t")

def goal_candidates(
    af_atoms=None,
    hebbian_links=None,
    graph_path=None,
    group_size=GROUP_SIZE,
    use_dynamic: Any = None,
) -> str:
    """Entry point dispatching between static and dynamic modes based on use_dynamic / USE_DYNAMIC."""
    is_dynamic = USE_DYNAMIC if use_dynamic is None else _parse_bool(use_dynamic)
    if is_dynamic:
        return goal_candidates_dynamic(
            af_atoms=af_atoms,
            hebbian_links=hebbian_links,
            graph_path=graph_path,
            group_size=group_size,
        )
    return goal_candidates_static(
        af_atoms=af_atoms,
        graph_path=graph_path,
        group_size=group_size,
    )
