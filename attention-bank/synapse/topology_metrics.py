from typing import Any, Dict, Iterable, List, Optional, Set, Tuple

import igraph as ig


HEBBIAN_LINK_TYPES = {
    "ASYMMETRIC_HEBBIAN_LINK",
    "SYMMETRIC_HEBBIAN_LINK",
    "HEBBIAN_LINK",
}


def _children(atom: Any) -> Optional[List[Any]]:
    if isinstance(atom, (list, tuple)):
        return list(atom)

    get_children = getattr(atom, "get_children", None)
    if callable(get_children):
        try:
            return list(get_children())
        except Exception:
            return None

    return None


def _atom_key(atom: Any) -> str:
    children = _children(atom)
    if children is not None:
        return "(" + " ".join(_atom_key(child) for child in children) + ")"

    get_name = getattr(atom, "get_name", None)
    if callable(get_name):
        try:
            return str(get_name())
        except Exception:
            pass

    return str(atom)


def _iter_link_records(edges: Any) -> Iterable[Any]:
    if edges is None:
        return []

    children = _children(edges)
    if children:
        head = _atom_key(children[0])
        if head in HEBBIAN_LINK_TYPES:
            return [edges]
        return children

    if isinstance(edges, Iterable) and not isinstance(edges, (str, bytes)):
        return edges

    return []


def _extract_edge(record: Any) -> Optional[Tuple[str, str]]:
    children = _children(record)
    if not children:
        return None

    if len(children) >= 3 and _atom_key(children[0]) in HEBBIAN_LINK_TYPES:
        return _atom_key(children[1]), _atom_key(children[2])

    if len(children) >= 2:
        return _atom_key(children[0]), _atom_key(children[1])

    return None


def _normalize_edges(edges: Any) -> Tuple[List[str], List[Tuple[str, str]]]:
    vertices: Set[str] = set()
    undirected_edges: Set[Tuple[str, str]] = set()

    for record in _iter_link_records(edges):
        edge = _extract_edge(record)
        if edge is None:
            continue

        source, target = edge
        vertices.update((source, target))

        if source == target:
            continue

        undirected_edges.add(tuple(sorted((source, target))))

    return sorted(vertices), sorted(undirected_edges)


def topology_metrics(edges: Any) -> Dict[str, int]:
    """
    Compute topological invariants for the current Hebbian graph.

    MeTTa passes links as `(ASYMMETRIC_HEBBIAN_LINK source target)` records, but
    plain Python `(source, target)` pairs are accepted as well. Direction and
    duplicate links are ignored before metrics are computed.
    """
    vertices, undirected_edges = _normalize_edges(edges)
    if not vertices:
        return {"triangles": 0, "betti0": 0, "betti1": 0}

    vertex_to_index = {vertex: index for index, vertex in enumerate(vertices)}
    graph_edges = [
        (vertex_to_index[source], vertex_to_index[target])
        for source, target in undirected_edges
    ]

    graph = ig.Graph(directed=False)
    graph.add_vertices(len(vertices))
    graph.add_edges(graph_edges)

    components = len(graph.connected_components())
    triangles = len(graph.list_triangles())
    betti1 = graph.ecount() - graph.vcount() + components

    # 𝛽 ​= E − V + C

    return {
        "triangles": int(triangles),
        "betti0": int(components),
        "betti1": int(betti1),
    }


def topology_metric_values(edges: Any) -> List[int]:
    metrics = topology_metrics(edges)
    return [metrics["triangles"], metrics["betti0"], metrics["betti1"]]
