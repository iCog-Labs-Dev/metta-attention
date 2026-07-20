import re
import argparse
import time
from pathlib import Path
from typing import List, Tuple, Any
import igraph as ig


_RELATION_TRIPLET_PATTERN = re.compile(r"\(\s*([^\s()]+)\s+([^\s()]+)\s+([^\s()]+)\s*\)")


def list_to_sexp(lst):
    return '(' + ' '.join(str(item) for item in lst) + ')'


def _atom_key(atom: Any) -> str:
    if isinstance(atom, list):
        return list_to_sexp(atom)
    return str(atom).strip()


def _add_node(atom: Any, node_to_id: dict, id_to_original_atom: dict) -> None:
    atom_key = _atom_key(atom)
    if atom_key and atom_key not in node_to_id:
        idx = len(node_to_id)
        node_to_id[atom_key] = idx
        id_to_original_atom[idx] = atom_key


def _as_float(value: Any) -> float | None:
    try:
        return float(value)
    except (TypeError, ValueError):
        return None


def _stv_mean(value: Any) -> float | None:
    if _as_float(value) is not None:
        return _as_float(value)

    if not isinstance(value, list):
        return None

    if len(value) >= 3 and str(value[0]) == "STV":
        return _as_float(value[1] * value[2])


    return None


def _edge_from_link(link: Any) -> tuple[str, str, float] | None:
    if not isinstance(link, list):
        return None

    if len(link) == 2 and isinstance(link[0], list) and len(link[0]) >= 3:
        # refering [['ASYMMETRIC_HEBBIAN_LINK', 'A', 'B'], ['STV', 0.8, 0.5]] kind of link/list
        src = _atom_key(link[0][1])
        tgt = _atom_key(link[0][2])
        weight = _stv_mean(link[1])
        # weight = _atom_key(link[1][1])

        # print("weight ", weight)
        return src, tgt, weight if weight is not None else 0.5

    if len(link) >= 3:
        src = _atom_key(link[1])
        tgt = _atom_key(link[2])
        weight = _as_float(link[3]) if len(link) > 3 else None
        return src, tgt, weight if weight is not None else 0.5

    return None


def get_dynamic_modules(af_atoms: Any, af_links: Any) -> List[List[Any]]:
    """Live dynamic clustering for the active Attentional Focus."""
    # af_links = _normalize_atoms(af_links)
    
    node_to_id = {}
    id_to_original_atom = {}

    edges = []
    weights = []

    for atom in af_atoms:
        _add_node(atom, node_to_id, id_to_original_atom)
    
    for link in af_links:
        # print("link --> ", link)
        # print("length of link --> ", len(link))

        edge = _edge_from_link(link)
        if edge is None:
            continue

        src, tgt, weight = edge

        for atom in (src, tgt):
            _add_node(atom, node_to_id, id_to_original_atom)

        if src == tgt or weight <= 0:
            continue
        
        edges.append((node_to_id[src], node_to_id[tgt]))
        # print("edges ", edges)
        weights.append(weight)
        # print("weights ", weights)


    if not node_to_id:
        return []

    graph = ig.Graph(directed=False)
    graph.add_vertices(len(node_to_id))
    
    if edges:
        graph.add_edges(edges)
        graph.es["weight"] = weights

    try:
        partition = graph.community_multilevel(weights=graph.es["weight"], resolution=2.0) if edges else graph.components()
    except Exception:
        partition = graph.components()

    grouped = [[id_to_original_atom[vid] for vid in cluster] for cluster in partition]

    return grouped


def get_dynamic_hebbian_modules(hebbian_links: Any) -> List[List[Any]]:
    """Cluster all supplied Hebbian links without limiting the graph to AF atoms."""
    return get_dynamic_modules([], hebbian_links)
