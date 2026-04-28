import argparse
import re
from pathlib import Path

import networkx as nx
from networkx.algorithms import community


_RELATION_TRIPLET_PATTERN = re.compile(r"\(\s*([^\s()]+)\s+([^\s()]+)\s+([^\s()]+)\s*\)")


def get_communities(metta_data_string: str):
    graph = nx.Graph()

    for _relation, node1, node2 in _RELATION_TRIPLET_PATTERN.findall(metta_data_string):
        graph.add_edge(node1, node2)

    if graph.number_of_nodes() == 0:
        return []

    if graph.number_of_edges() == 0:
        return [[node] for node in graph.nodes()]

    try:
        modules = community.louvain_communities(graph)
    except Exception:
        modules = list(nx.connected_components(graph))

    return [sorted(list(module)) for module in modules]


def identify_modules_from_kg_file(file_path: str):
    """
    Load a KG MeTTa file and return communities.
    """
    path = Path(file_path)
    if not path.is_absolute():
        repo_root = Path(__file__).resolve().parents[2]
        path = repo_root / path

    data = path.read_text(encoding="utf-8", errors="ignore")
    return get_communities(data)


def write_communities_to_file(communities, output_file_path: str):
    
    output_path = Path(output_file_path)
    if not output_path.is_absolute():
        repo_root = Path(__file__).resolve().parents[2]
        output_path = repo_root / output_path

    output_path.parent.mkdir(parents=True, exist_ok=True)

    lines = [f"Found {len(communities)} communities:"]
    for index, module in enumerate(communities, 1):
        nodes = ", ".join(module)
        lines.append(f"Module {index} (size={len(module)}): {nodes}")

    output_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return str(output_path)

def _build_arg_parser():
    default_input = "experiments/data/kg.metta"
    default_output = "experiments/data/found_communities.txt"

    parser = argparse.ArgumentParser(
        description="Detect communities from a MeTTa file and optionally write to output."
    )
    parser.add_argument(
        "input",
        nargs="?",
        default=str(default_input),
        help="Input MeTTa file path (default: experiments/data/kg.metta).",
    )
    parser.add_argument(
        "output",
        nargs="?",
        default=str(default_output),
        help="Output text file path (default: experiments/data/found_communities.txt).",
    )
    parser.add_argument(
        "--no-write",
        action="store_true",
        help="Only print communities to stdout; do not write output file.",
    )
    return parser

# Create a global cache so we only read the massive text file ONCE
_MODULE_CACHE = {}


def _normalize_af_atoms(af_atoms):
    if af_atoms is None:
        return []

    if isinstance(af_atoms, (int, float, bool)):
        return []

    if isinstance(af_atoms, (str, bytes)):
        return [af_atoms]

    try:
        return list(af_atoms)
    except TypeError:
        return [af_atoms]


def _atom_to_name(atom):
    try:
        if hasattr(atom, "get_name"):
            return str(atom.get_name()).strip()
    except Exception:
        pass

    return str(atom).replace('(', '').replace(')', '').strip()

def get_af_modules(af_atoms):
    """
    Called live by MeTTa. Takes the active atoms in the Attentional Focus, 
    looks up their Global Module ID, and groups them together.
    """
    global _MODULE_CACHE
    
    if not _MODULE_CACHE:
        repo_root = Path(__file__).resolve().parents[2]
        output_file = repo_root / "experiments" / "data" / "found_communities.txt"
        
        try:
            with open(output_file, "r", encoding="reutf-8") as f:
                for line in f:
                    if line.startswith("Module"):
                        parts = line.split("): ")
                        if len(parts) == 2:
                            mod_id = parts[0].split()[1] 
                            nodes = parts[1].strip().split(", ")
                            for node in nodes:
                                _MODULE_CACHE[node] = mod_id
        except FileNotFoundError:
            print(
                "Warning: experiments/data/found_communities.txt not found. "
                "Run the detector offline first!"
            )

    grouped = {}
    af_atoms_norm = _normalize_af_atoms(af_atoms)

    for atom in af_atoms_norm:
        atom_name = _atom_to_name(atom)

        if atom_name == "":
            continue
        mod_id = _MODULE_CACHE.get(atom_name, "isolated_" + atom_name) 
        
        if mod_id not in grouped:
            grouped[mod_id] = []
        grouped[mod_id].append(atom)

    return list(grouped.values())


if __name__ == "__main__":
    args = _build_arg_parser().parse_args()
    print("Identifying modules... (this may take a moment)")
    communities = identify_modules_from_kg_file(args.input)

    print(f"Found {len(communities)} communities")

    if not args.no_write:
        output_path = write_communities_to_file(communities, args.output)
        print(f"Written to: {output_path}")
