#!/usr/bin/env python3

import sys
import time
import argparse
import cProfile
import pstats
import io
import random
from pathlib import Path
from typing import List, Tuple, Any, Dict

# Set up module path to import from attention-bank/synapse
synapse_dir = Path(__file__).resolve().parent.parent / "attention-bank" / "synapse"
sys.path.insert(0, str(synapse_dir))

import topology_metrics
import community_detector


# ==============================================================================
# Synthetic Data Generators (Mocking MeTTa Hebbian Links & Atoms)
# ==============================================================================

def generate_mock_hebbian_links(
    num_nodes: int, 
    link_probability: float = 0.2, 
    nested_atoms: bool = False
) -> Tuple[List[str], List[List[Any]]]:
    """Generates realistic MeTTa-format Hebbian links and AF atoms."""
    if nested_atoms:
        nodes = [f"(ConceptNode node_{i})" for i in range(num_nodes)]
    else:
        nodes = [f"atom_{i}" for i in range(num_nodes)]

    links = []
    for i in range(num_nodes):
        for j in range(i + 1, num_nodes):
            if random.random() < link_probability:
                src, tgt = nodes[i], nodes[j]
                mean = round(random.uniform(0.1, 0.9), 3)
                conf = round(random.uniform(0.5, 0.95), 3)
                
                # Format 1: [["ASYMMETRIC_HEBBIAN_LINK", src, tgt], ["STV", mean, conf]]
                link_record = [
                    ["ASYMMETRIC_HEBBIAN_LINK", src, tgt],
                    ["STV", mean, conf]
                ]
                links.append(link_record)

    af_atoms = nodes[:max(1, int(num_nodes * 0.3))]  # Top 30% are in AF
    return af_atoms, links


def generate_structured_mesh(size: int = 5) -> List[List[Any]]:
    """Generates a structured triangular lattice grid rich in 2-simplices (triangles) and 3-simplices."""
    links = []
    for x in range(size):
        for y in range(size):
            u = f"v_{x}_{y}"
            if x + 1 < size:
                v = f"v_{x+1}_{y}"
                links.append([["ASYMMETRIC_HEBBIAN_LINK", u, v], ["STV", 0.8, 0.9]])
            if y + 1 < size:
                v = f"v_{x}_{y+1}"
                links.append([["ASYMMETRIC_HEBBIAN_LINK", u, v], ["STV", 0.8, 0.9]])
            if x + 1 < size and y + 1 < size:
                v = f"v_{x+1}_{y+1}"
                links.append([["ASYMMETRIC_HEBBIAN_LINK", u, v], ["STV", 0.8, 0.9]])
    return links


# ==============================================================================
# Benchmarking Engine
# ==============================================================================

def benchmark_callable(func, *args, iterations: int = 100) -> Dict[str, float]:
    """Runs a function for N iterations and returns timing statistics in milliseconds."""
    # Warmup
    for _ in range(max(1, iterations // 10)):
        func(*args)

    times = []
    for _ in range(iterations):
        t0 = time.perf_counter()
        func(*args)
        t1 = time.perf_counter()
        times.append((t1 - t0) * 1000.0)  # ms

    total_time = sum(times)
    avg_time = total_time / len(times)
    min_time = min(times)
    max_time = max(times)

    return {
        "iterations": iterations,
        "total_ms": total_time,
        "avg_ms": avg_time,
        "min_ms": min_time,
        "max_ms": max_time,
        "ops_per_sec": (iterations / (total_time / 1000.0)) if total_time > 0 else 0.0
    }


def print_bench_result(name: str, res: Dict[str, float]):
    print(f"  • {name:<36} | Avg: {res['avg_ms']:>8.4f} ms | Min: {res['min_ms']:>8.4f} ms | Total ({res['iterations']} iter): {res['total_ms']/1000.0:>6.3f} s | {res['ops_per_sec']:>9.1f} ops/s")


# ==============================================================================
# Workloads Suite
# ==============================================================================

def profile_topology_metrics(scale: str = "medium", iterations: int = 500):
    print("\n" + "=" * 80)
    print(f"1. PROFILING: Topology Metrics (topology_metrics.py) — Scale: {scale.upper()}")
    print("=" * 80)

    configs = {
        "small": {"nodes": 15, "p": 0.35, "iter": iterations},
        "medium": {"nodes": 40, "p": 0.25, "iter": iterations},
        "large": {"nodes": 100, "p": 0.15, "iter": max(20, iterations // 5)}
    }
    cfg = configs.get(scale, configs["medium"])

    _, random_links = generate_mock_hebbian_links(cfg["nodes"], cfg["p"])
    _, nested_links = generate_mock_hebbian_links(cfg["nodes"], cfg["p"], nested_atoms=True)
    mesh_links = generate_structured_mesh(size=6)

    print(f"  [Dataset: Random Graph ({cfg['nodes']} nodes, {len(random_links)} edges)]")
    res_norm = benchmark_callable(topology_metrics._normalize_edges, random_links, iterations=cfg["iter"])
    print_bench_result("Edge Normalization (_normalize_edges)", res_norm)

    res_metric_vals = benchmark_callable(topology_metrics.topology_metric_values, random_links, iterations=cfg["iter"])
    print_bench_result("Full Metrics (topology_metric_values)", res_metric_vals)

    res_metrics_dict = benchmark_callable(topology_metrics.topology_metrics, random_links, iterations=cfg["iter"])
    print_bench_result("Full Dictionary (topology_metrics)", res_metrics_dict)

    print(f"\n  [Dataset: Structured 2D Simplicial Mesh ({len(mesh_links)} edges)]")
    res_mesh = benchmark_callable(topology_metrics.topology_metric_values, mesh_links, iterations=cfg["iter"])
    print_bench_result("Triangular Mesh Betti Invariants", res_mesh)

    print(f"\n  [Dataset: Nested MeTTa S-Expression Atoms ({len(nested_links)} edges)]")
    res_nested = benchmark_callable(topology_metrics.topology_metric_values, nested_links, iterations=cfg["iter"])
    print_bench_result("Nested S-Exp Parsing & Topology", res_nested)


def profile_community_detector(scale: str = "medium", iterations: int = 500):
    print("\n" + "=" * 80)
    print(f"2. PROFILING: Community Detector (community_detector.py) — Scale: {scale.upper()}")
    print("=" * 80)

    configs = {
        "small": {"nodes": 20, "p": 0.3, "iter": iterations},
        "medium": {"nodes": 60, "p": 0.2, "iter": iterations},
        "large": {"nodes": 150, "p": 0.1, "iter": max(20, iterations // 5)}
    }
    cfg = configs.get(scale, configs["medium"])

    af_atoms, all_links = generate_mock_hebbian_links(cfg["nodes"], cfg["p"])

    print(f"  [Dataset: Active AF Graph ({len(af_atoms)} AF atoms, {len(all_links)} total links)]")
    
    res_dyn_modules = benchmark_callable(
        community_detector.get_dynamic_modules, 
        af_atoms, 
        all_links, 
        iterations=cfg["iter"]
    )
    print_bench_result("get_dynamic_modules (AF-scoped)", res_dyn_modules)

    res_hebb_modules = benchmark_callable(
        community_detector.get_dynamic_hebbian_modules, 
        all_links, 
        iterations=cfg["iter"]
    )
    print_bench_result("get_dynamic_hebbian_modules (Global)", res_hebb_modules)


# ==============================================================================
# Detailed cProfile Function Call Inspection
# ==============================================================================

def run_cprofile_analysis(scale: str = "medium"):
    print("\n" + "=" * 80)
    print("DETAILED CPROFILE BREAKDOWN (Top Internal Python Function Costs)")
    print("=" * 80)

    num_nodes = 50 if scale == "medium" else (20 if scale == "small" else 100)
    af_atoms, links = generate_mock_hebbian_links(num_nodes, 0.25)

    def full_synapse_workload():
        for _ in range(50):
            topology_metrics.topology_metric_values(links)
            community_detector.get_dynamic_modules(af_atoms, links)

    pr = cProfile.Profile()
    pr.enable()
    full_synapse_workload()
    pr.disable()

    s = io.StringIO()
    ps = pstats.Stats(pr, stream=s).sort_stats("cumtime")
    ps.print_stats(25)
    print(s.getvalue())


# ==============================================================================
# CLI Entry Point
# ==============================================================================

def main():
    parser = argparse.ArgumentParser(description="Profile Synapse Python Implementations")
    parser.add_argument("--scale", choices=["small", "medium", "large"], default="medium", help="Dataset size scale")
    parser.add_argument("--iterations", type=int, default=500, help="Number of benchmark iterations")
    parser.add_argument("--cprofile", action="store_true", help="Run line-level cProfile analysis")
    args = parser.parse_args()

    random.seed(42)  # Deterministic benchmarking

    print(f"Starting Synapse Python Profiling (Scale: {args.scale}, Iterations: {args.iterations})...")
    
    profile_topology_metrics(scale=args.scale, iterations=args.iterations)
    profile_community_detector(scale=args.scale, iterations=args.iterations)

    if args.cprofile:
        run_cprofile_analysis(scale=args.scale)

    print("\nProfiling Complete.\n")


if __name__ == "__main__":
    main()
