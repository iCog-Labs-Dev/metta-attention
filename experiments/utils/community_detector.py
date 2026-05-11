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


def get_communities(metta_data_string: str) -> List[List[str]]:
    """Offline high-performance clustering for the static KG."""
    nodes = set()
    edges = []

    for _, node1, node2 in _RELATION_TRIPLET_PATTERN.findall(metta_data_string):
        nodes.update([node1, node2])
        edges.append((node1, node2))

    if not nodes:
        return []
    if not edges:
        return [[node] for node in nodes]

    node_list = list(nodes)
    node_to_id = {node: i for i, node in enumerate(node_list)}
    edge_ids = [(node_to_id[u], node_to_id[v]) for u, v in edges]

    graph = ig.Graph(directed=False)
    graph.add_vertices(len(node_list))
    graph.vs["name"] = node_list
    graph.add_edges(edge_ids)

    try:
        partition = graph.community_multilevel()
    except Exception:
        partition = graph.components()

    return [sorted([graph.vs[vid]["name"] for vid in cluster]) for cluster in partition]


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

    # print(f"\n[LOUVAIN DEBUG] Active Atoms: {len(node_to_id)} | Active Links: {len(edges)}")
    # print(f"[LOUVAIN DEBUG] Louvain generated {len(grouped)} distinct modules.")
    # for idx, mod in enumerate(grouped):
    #     print(f"   -> Module {idx + 1} size: {len(mod)} atoms")
    # print("-" * 40)

    return grouped




def identify_modules_from_kg_file(file_path: str) -> List[List[str]]:
    path = Path(file_path)
    if not path.is_absolute():
        path = Path(__file__).resolve().parents[2] / path
    return get_communities(path.read_text(encoding="utf-8", errors="ignore"))


def write_communities_to_file(communities: List[List[str]], output_file_path: str) -> str:
    output_path = Path(output_file_path)
    if not output_path.is_absolute():
        output_path = Path(__file__).resolve().parents[2] / output_path

    output_path.parent.mkdir(parents=True, exist_ok=True)

    lines = [f"; Identified {len(communities)} modules"]
    for index, module in enumerate(communities, 1):
        lines.append(f"(module Module{index} ({" ".join(module)}))")

    output_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return str(output_path)


def _build_arg_parser():
    parser = argparse.ArgumentParser(description="Detect communities from a MeTTa file using igraph.")
    parser.add_argument("input", nargs="?", default="experiments/data/kg.metta", help="Input MeTTa file path.")
    parser.add_argument("output", nargs="?", default="experiments/data/found_communities.metta", help="Output file path.")
    parser.add_argument("--no-write", action="store_true", help="Only print communities to stdout.")
    return parser


if __name__ == "__main__":
    args = _build_arg_parser().parse_args()
    print("Identifying modules using louvain...")
    
    start_time = time.time()
    communities = identify_modules_from_kg_file(args.input)
    
    print(f"Identified {len(communities)} modules")

    if not args.no_write:
        output_path = write_communities_to_file(communities, args.output)
        print(f"Written to: {output_path}")