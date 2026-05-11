import re
import argparse
import time
from pathlib import Path
from typing import List, Tuple, Any
import igraph as ig


_RELATION_TRIPLET_PATTERN = re.compile(r"\(\s*([^\s()]+)\s+([^\s()]+)\s+([^\s()]+)\s*\)")


def _normalize_atoms(atoms: Any) -> List[Any]:
    if atoms is None or isinstance(atoms, (int, float, bool)):
        return []
    if isinstance(atoms, (str, bytes)):
        return [atoms]
    try:
        return list(atoms)
    except TypeError:
        return [atoms]


def _atom_to_name(atom: Any) -> str:
    try:
        if hasattr(atom, "get_name"):
            return str(atom.get_name()).strip()
    except Exception:
        pass
    return str(atom).replace('(', '').replace(')', '').strip()

def get_dynamic_modules(af_atoms: Any, af_links: Any) -> List[List[Any]]:

    """Live dynamic clustering for the active Attentional Focus."""
    af_atoms_norm = _normalize_atoms(af_atoms)
    
    node_to_id = {}
    id_to_original_atom = {}
    
    for i, atom in enumerate(af_atoms_norm):
        atom_name = _atom_to_name(atom)
        if atom_name:
            node_to_id[atom_name] = i
            id_to_original_atom[i] = atom

    edges = []
    weights = []
    
    for link in _normalize_atoms(af_links):
        if isinstance(link, list) and len(link) >= 3:
            src = str(link[1]).strip()
            tgt = str(link[2]).strip()
            weight = float(link[3]) if len(link) > 3 else 0.5
            
            if src in node_to_id and tgt in node_to_id:
                edges.append((node_to_id[src], node_to_id[tgt]))
                weights.append(weight)

    if not node_to_id:
        return []

    graph = ig.Graph(directed=False)
    graph.add_vertices(len(node_to_id))
    
    if edges:
        graph.add_edges(edges)
        graph.es["weight"] = weights

    try:
        partition = graph.community_multilevel(weights=graph.es["weight"]) if edges else graph.components()
    except Exception:
        partition = graph.components()

    grouped = [[id_to_original_atom[vid] for vid in cluster] for cluster in partition]

    return grouped

