import argparse
import random
import re
import hashlib
from collections import defaultdict, deque

INNER_PATTERN = re.compile(r"\(\s*(\w+)\s+([^\s()]+)\s+([^\s()]+)\s*\)")

RELATION_WEIGHTS = {
    "synonym": 0.9,
    "isa": 0.8,
    "formof": 0.75,
    "derivedfrom": 0.7,
    "relatedto": 0.5,
    "hascontext": 0.4,
    "antonym": 0.2
}


def _connected_subgraph(
    adjacency: dict[str, list[str]], min_edges: int
) -> list[tuple[str, str]]:
    """BFS to find the largest connected component, returning up to min_edges edges."""
    visited_nodes = set()
    largest_component_edges = set()
    
    for start in adjacency.keys():
        if start in visited_nodes:
            continue
            
        queue = deque([start])
        visited_nodes.add(start)
        edge_set = set()
        
        while queue:
            node = queue.popleft()
            for neighbor in adjacency[node]:
                edge = (node, neighbor) if node < neighbor else (neighbor, node)
                edge_set.add(edge)
                if neighbor not in visited_nodes:
                    visited_nodes.add(neighbor)
                    queue.append(neighbor)
                    
        if len(edge_set) > len(largest_component_edges):
            largest_component_edges = edge_set
            
        if len(largest_component_edges) >= min_edges:
            return list(largest_component_edges)[:min_edges]
            
    print(f"\nWarning: You asked for {min_edges} edges, but the largest unbroken continent in ConceptNet only has {len(largest_component_edges)} edges!")
    print("Returning the absolute largest component possible.\n")
    return list(largest_component_edges)


def deterministic_hash_weight(s1: str, s2: str, min_w: float, max_w: float) -> float:
    """Create a deterministic pseudo-random float between min_w and max_w."""
    h = hashlib.sha256(f"{s1}-{s2}".encode()).hexdigest()
    val = int(h[:8], 16) / 0xffffffff
    return min_w + val * (max_w - min_w)


def jaccard_similarity(u: str, v: str, adjacency: dict[str, list[str]]) -> float:
    neighbors_u = set(adjacency[u])
    neighbors_v = set(adjacency[v])
    intersection = len(neighbors_u.intersection(neighbors_v))
    union = len(neighbors_u.union(neighbors_v))
    if union == 0:
        return 0.1
    return intersection / union

def parse_input(path: str) -> tuple[list[tuple[str, str, str]], dict[str, list[str]]]:
    """Read a ConceptNet .metta file and return (edge pool, adjacency dict)."""
    print(f"Reading {path} ...")
    with open(path) as f:
        lines = f.readlines()

    adjacency: dict[str, list[str]] = defaultdict(list)
    pool = []
    skipped = 0
    for line in lines:
        line = line.strip()
        matches = list(INNER_PATTERN.finditer(line))
        if matches:
            for match in matches:
                rel, src, tgt = match.group(1), match.group(2), match.group(3)
                pool.append((rel.lower(), src, tgt))
                adjacency[src].append(tgt)
                adjacency[tgt].append(src)
        else:
            skipped += 1

    if skipped:
        print(f"Skipped {skipped} unparseable lines")
    print(f"Total edges: {len(pool)}")

    return pool, adjacency

def extract_subgraph(
    pool: list[tuple[str, str, str]],
    adjacency: dict[str, list[str]],
    num_edges: int,
) -> tuple[list[tuple[str, str]], dict[tuple[str, str], str]]:
    """Extract a connected subgraph and build an edge-to-relation lookup."""
    subgraph_edges = _connected_subgraph(adjacency, num_edges)

    edge_lookup: dict[tuple[str, str], str] = {}
    for rel, src, tgt in pool:
        edge_lookup[(src, tgt)] = rel
        edge_lookup[(tgt, src)] = rel

    sampled_nodes = set()
    for s, t in subgraph_edges:
        sampled_nodes.add(s)
        sampled_nodes.add(t)

    avg_deg = 2 * len(subgraph_edges) / max(len(sampled_nodes), 1)
    print(f"Subgraph: {len(sampled_nodes)} nodes, {len(subgraph_edges)} edges (avg_deg={avg_deg:.2f})")

    return subgraph_edges, edge_lookup

def compute_weight(
    src: str,
    tgt: str,
    rel: str,
    strategy: str,
    adjacency: dict[str, list[str]],
    rng: random.Random,
    min_weight: float,
    max_weight: float,
) -> float:
    """Return the edge weight for a single (src, tgt) pair."""
    if strategy == "random":
        return rng.uniform(min_weight, max_weight)
    elif strategy == "hash":
        return deterministic_hash_weight(src, tgt, min_weight, max_weight)
    elif strategy == "jaccard":
        sim = jaccard_similarity(src, tgt, adjacency)
        return min_weight + sim * (max_weight - min_weight)
    elif strategy == "relation":
        base_w = RELATION_WEIGHTS.get(rel.lower(), 0.5)
        noise = deterministic_hash_weight(src, tgt, -0.05, 0.05)
        return max(min_weight, min(max_weight, base_w + noise))
    else:
        return rng.uniform(min_weight, max_weight)


def compute_confidence(
    src: str,
    tgt: str,
    strategy: str,
    rng: random.Random,
    min_conf: float,
    max_conf: float,
) -> float:
    """Return the confidence value for a single (src, tgt) pair."""
    if strategy == "random":
        return rng.uniform(min_conf, max_conf)
    else:
        return deterministic_hash_weight(tgt, src, min_conf, max_conf)

def write_output(
    output_path: str,
    subgraph_edges: list[tuple[str, str]],
    edge_lookup: dict[tuple[str, str], str],
    adjacency: dict[str, list[str]],
    args: argparse.Namespace,
    rng: random.Random,
) -> None:
    """Write the final .metta graph file."""
    print(f"Using weight strategy: {args.weight_strategy}")
    print(f"Writing to {output_path} ...")

    with open(output_path, "w") as f:
        for src, tgt in subgraph_edges:
            rel = args.relation if args.relation else edge_lookup.get((src, tgt), "relatedto")

            weight = compute_weight(
                src, tgt, rel, args.weight_strategy,
                adjacency, rng, args.min_weight, args.max_weight,
            )
            confidence = compute_confidence(
                src, tgt, args.weight_strategy,
                rng, args.min_conf, args.max_conf,
            )

            f.write(f"(({rel} {src} {tgt}) ({weight:.6f} {confidence:.6f}))\n")

    print("Done")

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Sample a connected subgraph from ConceptNet with controllable weights."
    )
    parser.add_argument("--input", default="experiments/data/conceptnet.metta")
    parser.add_argument("-o", "--output", default="experiments/data/test_graph.metta")
    parser.add_argument("--num-edges", type=int, default=5000)
    parser.add_argument("--min-weight", type=float, default=0.01)
    parser.add_argument("--max-weight", type=float, default=1.0)
    parser.add_argument("--min-conf", type=float, default=0.3)
    parser.add_argument("--max-conf", type=float, default=1.0)
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--relation", type=str, default=None)
    parser.add_argument(
        "--weight-strategy", 
        type=str, 
        choices=["random", "hash", "jaccard", "relation"], 
        default="random",
        help="Strategy for assigning weights (default: random)"
    )

    args = parser.parse_args()
    rng = random.Random(args.seed)

    pool, adjacency = parse_input(args.input)
    subgraph_edges, edge_lookup = extract_subgraph(pool, adjacency, args.num_edges)
    write_output(args.output, subgraph_edges, edge_lookup, adjacency, args, rng)


if __name__ == "__main__":
    main()
