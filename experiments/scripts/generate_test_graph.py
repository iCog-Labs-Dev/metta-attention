import argparse
import random
import re
import hashlib
from collections import defaultdict, deque

INNER_PATTERN = re.compile(r"\(\s*(\w+)\s+([^\s()]+)\s+([^\s()]+)\s*\)")

def _connected_subgraph(
    adjacency: dict[str, list[str]], min_edges: int, rng: random.Random
) -> list[tuple[str, str]]:
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
    # Create a deterministic pseudo-random float between 0 and 1
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

RELATION_WEIGHTS = {
    "synonym": 0.9,
    "isa": 0.8,
    "formof": 0.75,
    "derivedfrom": 0.7,
    "relatedto": 0.5,
    "hascontext": 0.4,
    "antonym": 0.2
}

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

    print(f"Reading {args.input} ...")
    with open(args.input) as f:
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

    component = _connected_subgraph(adjacency, args.num_edges, rng)
    subgraph_edges = component[: args.num_edges]

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
    print(f"Using weight strategy: {args.weight_strategy}")
    print(f"Writing to {args.output} ...")

    with open(args.output, "w") as f:
        for src, tgt in subgraph_edges:
            rel = args.relation if args.relation else edge_lookup.get((src, tgt), "relatedto")
            
            # Determine Weight
            if args.weight_strategy == "random":
                weight = rng.uniform(args.min_weight, args.max_weight)
            elif args.weight_strategy == "hash":
                weight = deterministic_hash_weight(src, tgt, args.min_weight, args.max_weight)
            elif args.weight_strategy == "jaccard":
                sim = jaccard_similarity(src, tgt, adjacency)
                # scale jaccard to min_weight / max_weight
                weight = args.min_weight + sim * (args.max_weight - args.min_weight)
            elif args.weight_strategy == "relation":
                base_w = RELATION_WEIGHTS.get(rel.lower(), 0.5)
                # add a tiny bit of deterministic hash noise to break ties
                noise = deterministic_hash_weight(src, tgt, -0.05, 0.05)
                weight = max(args.min_weight, min(args.max_weight, base_w + noise))

            # For confidence, we can just use the hash strategy to keep it deterministic
            if args.weight_strategy == "random":
                confidence = rng.uniform(args.min_conf, args.max_conf)
            else:
                confidence = deterministic_hash_weight(tgt, src, args.min_conf, args.max_conf)
                
            f.write(f"(({rel} {src} {tgt}) ({weight:.6f} {confidence:.6f}))\n")

    print("Done")

if __name__ == "__main__":
    main()
