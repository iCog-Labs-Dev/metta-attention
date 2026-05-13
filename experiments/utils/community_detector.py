import re
import argparse
import time
from pathlib import Path
from typing import List, Tuple, Any
import igraph as ig


_RELATION_TRIPLET_PATTERN = re.compile(r"\(\s*([^\s()]+)\s+([^\s()]+)\s+([^\s()]+)\s*\)")


def list_to_sexp(lst):
    return '(' + ' '.join(str(item) for item in lst) + ')'

def get_dynamic_modules(af_atoms: Any, af_links: Any) -> List[List[Any]]:
    """Live dynamic clustering for the active Attentional Focus."""
    # af_links = _normalize_atoms(af_links)
    
    node_to_id = {}
    id_to_original_atom = {}

    edges = []
    weights = []
    
    for link in af_links:
        if isinstance(link, list) and len(link) > 1:
            for word in link[1:]:
                if isinstance(word, list):
                    word = list_to_sexp(word)
                word_str = word
                if word_str and word_str not in node_to_id:
                    idx = len(node_to_id)
                    node_to_id[word_str] = idx
                    id_to_original_atom[idx] = word_str

        if isinstance(link, list) and len(link) >= 3:
            src = list_to_sexp(link[1]) if isinstance(link[1], list) else str(link[1]).strip()
            tgt = list_to_sexp(link[2]) if isinstance(link[2], list) else str(link[2]).strip()
            weight = float(link[3]) if len(link) > 3 else 0.5
            
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
        partition = graph.community_multilevel(weights=graph.es["weight"], resolution=1.01) if edges else graph.components()
    except Exception:
        partition = graph.components()

    grouped = [[id_to_original_atom[vid] for vid in cluster] for cluster in partition]

    return grouped

# def _normalize_atoms(atoms: Any) -> List[Any]:
#     if atoms is None or isinstance(atoms, (int, float, bool)):
#         return []
#     if isinstance(atoms, (str, bytes)):
#         return [atoms]
#     try:
#         return list(atoms)
#     except TypeError:
#         return [atoms]

# def _atom_to_name(atom: Any) -> str:
#     try:
#         if hasattr(atom, "get_name"):
#             return str(atom.get_name()).strip()
#     except Exception:
#         pass
#     return str(atom).replace('(', '').replace(')', '').strip()