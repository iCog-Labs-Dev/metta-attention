from itertools import combinations
from typing import Any, Dict, Iterable, List, Optional, Sequence, Set, Tuple

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


def _rank_mod2(columns: Iterable[int]) -> int:
    basis: Dict[int, int] = {}

    for column in columns:
        vector = column
        while vector:
            pivot = vector.bit_length() - 1
            if pivot not in basis:
                basis[pivot] = vector
                break
            vector ^= basis[pivot]

    return len(basis)


def _boundary_columns(
    simplices: Iterable[Sequence[int]],
    face_to_index: Dict[Tuple[int, ...], int],
) -> Iterable[int]:
    for simplex in simplices:
        column = 0
        for face in combinations(simplex, len(simplex) - 1):
            column ^= 1 << face_to_index[tuple(face)]
        yield column


def topology_metrics(edges: Any) -> Dict[str, int]:
    """
    Compute topological invariants for the current Hebbian graph's clique complex.

    MeTTa passes links as `(ASYMMETRIC_HEBBIAN_LINK source target)` records, but
    plain Python `(source, target)` pairs are accepted as well. Direction and
    duplicate links are ignored before metrics are computed.
    """
    vertices, undirected_edges = _normalize_edges(edges)
    # print("vertices ", vertices)
    # print("\n edges ", undirected_edges)

    if not vertices:
        return {"triangles": 0, "betti0": 0, "betti1": 0, "betti2": 0}

    vertex_to_index = {vertex: index for index, vertex in enumerate(vertices)}
    graph_edges = [
        (vertex_to_index[source], vertex_to_index[target])
        for source, target in undirected_edges
    ]

    graph = ig.Graph(directed=False)
    graph.add_vertices(len(vertices))
    graph.add_edges(graph_edges)

    vertex_simplices = [(index,) for index in range(graph.vcount())]
    # print("vertex simplices ", vertex_simplices)
    edge_simplices = [tuple(edge) for edge in graph.get_edgelist()]
    # print("edge simplices ", edge_simplices)
    triangle_simplices = [tuple(sorted(simplex)) for simplex in graph.cliques(min=3, max=3)]
    # print("triangle simplices ", triangle_simplices)
    tetrahedron_simplices = [tuple(sorted(simplex)) for simplex in graph.cliques(min=4, max=4)]
    # print("tetrahedron simplices ", tetrahedron_simplices)


    vertex_to_index = {simplex: index for index, simplex in enumerate(vertex_simplices)}
    # print("verted to index ", vertex_to_index)
    edge_to_index = {simplex: index for index, simplex in enumerate(edge_simplices)}
    triangle_to_index = {
        simplex: index for index, simplex in enumerate(triangle_simplices)
    }

    rank_d1 = _rank_mod2(_boundary_columns(edge_simplices, vertex_to_index))
    rank_d2 = _rank_mod2(_boundary_columns(triangle_simplices, edge_to_index))
    rank_d3 = _rank_mod2(_boundary_columns(tetrahedron_simplices, triangle_to_index))

    betti0 = len(vertex_simplices) - rank_d1
    betti1 = len(edge_simplices) - rank_d1 - rank_d2
    betti2 = len(triangle_simplices) - rank_d2 - rank_d3

    return {
        "triangles": len(triangle_simplices),
        "betti0": max(0, int(betti0)),
        "betti1": max(0, int(betti1)),
        "betti2": max(0, int(betti2)),
    }


def topology_metric_values(edges: Any) -> List[int]:
    metrics = topology_metrics(edges)
    return [
        metrics["triangles"],
        metrics["betti0"],
        metrics["betti1"],
        metrics["betti2"],
    ]
