"""Goal candidates for Mettaclaw, grouped by position relative to the attentional focus.

A goal is a drain in the fluid simulation, so what matters is where it sits relative to
where attention already is:

    SHARPEN  in the AF, best funded    -> concentrates harder, builds a focus
    SETTLE   in the AF, starved        -> redistributes inside the AF, consolidates new arrivals
    EXPAND   outside the AF, adjacent  -> grows the frontier one step
    BREAK    outside the AF, distant   -> stretches the flow across the grid, disperses a jet

Every candidate is a node of `adagram_sparse_random.metta`. The fluid simulation resolves
goal names against that graph and silently falls back to grid-centre seeds for anything it
cannot find, so a name absent from it wastes the whole cycle. AF members that are not in
the graph are therefore dropped from SHARPEN and SETTLE.

See `ECAN_goal_setting_report.md`.
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
    """Undirected neighbour sets per node. Cached — the graph file is static."""
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


def _text(atom) -> str:
    """Best-effort plain name for whatever MeTTa hands over."""
    if atom is None:
        return ""
    if isinstance(atom, bytes):
        return atom.decode("utf-8", "replace").strip().strip('"')
    if isinstance(atom, str):
        return atom.strip().strip('"')

    get_name = getattr(atom, "get_name", None)
    if callable(get_name):
        try:
            return str(get_name()).strip().strip('"')
        except Exception:
            pass
    return str(atom).strip().strip('"')


def _children(atom):
    """Sub-atoms of an expression, or None if this is a leaf."""
    get_children = getattr(atom, "get_children", None)
    if callable(get_children):
        try:
            return list(get_children())
        except Exception:
            return None
    if isinstance(atom, (list, tuple)):
        return list(atom)
    return None


def _af_pairs(af_pairs) -> list[tuple[str, float]]:
    """Parse ((atom sti) (atom sti) ...) into [(name, sti)], skipping anything malformed."""
    items = _children(af_pairs)
    if not items:
        return []

    parsed: list[tuple[str, float]] = []
    for item in items:
        fields = _children(item)
        if not fields or len(fields) < 2:
            continue
        name = _text(fields[0])
        if not name:
            continue
        try:
            sti = float(_text(fields[1]))
        except ValueError:
            sti = 0.0
        parsed.append((name, sti))
    return parsed


def _format(label: str, note: str, entries: list[tuple[str, str]]) -> str:
    if not entries:
        return f"{label}({note}) none"
    body = " ".join(f"{name}:{tag}" for name, tag in entries)
    return f"{label}({note}) {body}"


def goal_candidates(af_pairs=None, graph_path=None, group_size=GROUP_SIZE):
    """Return the four AF-relative candidate groups as one prompt-ready string.

    `af_pairs` is the collapsed `((atom sti) ...)` content of the AF space.
    """
    size = int(group_size)
    adjacency = _adjacency(graph_path or DEFAULT_GRAPH)

    pairs = _af_pairs(af_pairs)
    in_af = {name for name, _ in pairs}

    # Only AF members the fluid simulation can actually place on the grid.
    resolvable = sorted(
        ((name, sti) for name, sti in pairs if name in adjacency),
        key=lambda item: (-item[1], item[0]),
    )
    sharpen = [(name, f"{sti:.3g}") for name, sti in resolvable[:size]]
    settle = [(name, f"{sti:.3g}") for name, sti in reversed(resolvable[-size:])]

    outside = [(name, neighbours) for name, neighbours in adjacency.items() if name not in in_af]

    # Adjacent: most links back into the AF -> nearest to the current frontier.
    frontier = sorted(
        (
            (name, len(neighbours & in_af), len(neighbours))
            for name, neighbours in outside
            if neighbours & in_af
        ),
        key=lambda item: (-item[1], -item[2], item[0]),
    )
    expand = [(name, f"{touching}af") for name, touching, _ in frontier[:size]]

    # Distant: no link into the AF at all, sparsest first.
    detached = sorted(
        (
            (name, len(neighbours))
            for name, neighbours in outside
            if not (neighbours & in_af)
        ),
        key=lambda item: (item[1], item[0]),
    )
    if not detached:
        # Fully enclosed AF - fall back to the weakest attachment we can find.
        detached = sorted(
            ((name, len(neighbours)) for name, neighbours in outside),
            key=lambda item: (len(adjacency[item[0]] & in_af), item[1], item[0]),
        )
    breakout = [(name, f"d{degree}") for name, degree in detached[:size]]

    return " | ".join(
        [
            _format("SHARPEN", "in-AF, best funded", sharpen),
            _format("SETTLE", "in-AF, starved", settle),
            _format("EXPAND", "out-AF, adjacent", expand),
            _format("BREAK", "out-AF, distant", breakout),
        ]
    )
