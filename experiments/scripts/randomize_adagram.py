#!/usr/bin/env python3
"""Create a sparse randomized Adagram graph for fluid-diffusion experiments."""

from __future__ import annotations

import argparse
from collections import defaultdict
from dataclasses import dataclass
import random
import re
from pathlib import Path


EDGE_RE = re.compile(
    r"^\s*\(\(SimilarityLink\s+(?P<source>\S+)\s+(?P<target>\S+)\)\s+"
    r"\((?P<mean>[-+0-9.eE]+)\s+(?P<conf>[-+0-9.eE]+)\)\)\s*$"
)


@dataclass(frozen=True)
class Edge:
    source: str
    target: str
    mean: float
    conf: float


def parse_edges(path: Path) -> list[Edge]:
    edges: list[Edge] = []
    for line_no, line in enumerate(path.read_text().splitlines(), start=1):
        if not line.strip() or line.lstrip().startswith(";"):
            continue
        match = EDGE_RE.match(line)
        if not match:
            raise ValueError(f"Unsupported edge format at {path}:{line_no}: {line}")
        edges.append(
            Edge(
                source=match.group("source"),
                target=match.group("target"),
                mean=float(match.group("mean")),
                conf=float(match.group("conf")),
            )
        )
    return edges


def parse_sentence_words(path: Path) -> set[str]:
    words = re.findall(r"\b[a-zA-Z][a-zA-Z0-9_]*\b", path.read_text())
    return {word for word in words if word != "insectSent"}


def dedupe_by_max_weight(edges: list[Edge]) -> list[Edge]:
    best: dict[tuple[str, str], Edge] = {}
    for edge in edges:
        key = (edge.source, edge.target)
        if key not in best or edge.mean > best[key].mean:
            best[key] = edge
    return list(best.values())


def clamp(value: float, low: float, high: float) -> float:
    return max(low, min(high, value))


def jitter_weight(weight: float, rng: random.Random, jitter: float) -> float:
    factor = rng.uniform(1.0 - jitter, 1.0 + jitter)
    return clamp(weight * factor, 0.001, 1.0)


def choose_sparse_edges(
    edges: list[Edge],
    coverage_words: set[str],
    top_k: int,
    random_k: int,
    fallback_threshold: float,
    jitter: float,
    seed: int,
    diversity_links: int,
    diversity_min_weight: float,
    diversity_max_weight: float,
) -> list[Edge]:
    rng = random.Random(seed)
    by_source: dict[str, list[Edge]] = defaultdict(list)
    original_incident: dict[str, list[Edge]] = defaultdict(list)

    for edge in edges:
        by_source[edge.source].append(edge)
        original_incident[edge.source].append(edge)
        original_incident[edge.target].append(edge)

    selected: dict[tuple[str, str], Edge] = {}

    for source in sorted(by_source):
        candidates = [edge for edge in by_source[source] if edge.mean > fallback_threshold]
        candidates.sort(key=lambda edge: (-edge.mean, edge.target))

        chosen = candidates[:top_k]
        remaining = candidates[top_k:]
        if random_k > 0 and remaining:
            chosen.extend(rng.sample(remaining, k=min(random_k, len(remaining))))

        for edge in chosen:
            selected[(edge.source, edge.target)] = edge

    original_nodes = set(original_incident)
    required_nodes = coverage_words & original_nodes
    covered_nodes = {node for edge in selected.values() for node in (edge.source, edge.target)}

    for node in sorted(required_nodes - covered_nodes):
        strongest = max(
            original_incident[node],
            key=lambda edge: (edge.mean, edge.conf, edge.source, edge.target),
        )
        selected[(strongest.source, strongest.target)] = strongest

    if diversity_links > 0:
        if diversity_min_weight > diversity_max_weight:
            raise ValueError("--diversity-min-weight cannot exceed --diversity-max-weight")
        covered_nodes = sorted(
            node for edge in selected.values() for node in (edge.source, edge.target)
        )
        covered_nodes = sorted(set(covered_nodes))
        for source in covered_nodes:
            candidates = [
                target
                for target in covered_nodes
                if target != source and (source, target) not in selected
            ]
            for target in rng.sample(candidates, k=min(diversity_links, len(candidates))):
                selected[(source, target)] = Edge(
                    source=source,
                    target=target,
                    mean=rng.uniform(diversity_min_weight, diversity_max_weight),
                    conf=1.0,
                )

    sparse_edges: list[Edge] = []
    for edge in selected.values():
        sparse_edges.append(
            Edge(
                source=edge.source,
                target=edge.target,
                mean=jitter_weight(edge.mean, rng, jitter),
                conf=edge.conf,
            )
        )

    return sorted(sparse_edges, key=lambda edge: (edge.source, edge.target))


def fmt_num(value: float) -> str:
    text = f"{value:.6f}".rstrip("0").rstrip(".")
    return text if text else "0"


def write_edges(path: Path, edges: list[Edge]) -> None:
    lines = [
        "; Generated by experiments/scripts/randomize_adagram.py.",
        "; Sparse randomized Adagram variant for less homogeneous fluid diffusion.",
    ]
    lines.extend(
        f"((SimilarityLink {edge.source} {edge.target}) "
        f"({fmt_num(edge.mean)} {fmt_num(edge.conf)}))"
        for edge in edges
    )
    path.write_text("\n".join(lines) + "\n")


def neighbor_jaccard_mean(edges: list[Edge]) -> float:
    by_source: dict[str, set[str]] = defaultdict(set)
    for edge in edges:
        by_source[edge.source].add(edge.target)

    sources = sorted(by_source)
    if len(sources) < 2:
        return 0.0

    scores: list[float] = []
    for i, left in enumerate(sources):
        for right in sources[i + 1 :]:
            union = by_source[left] | by_source[right]
            if union:
                scores.append(len(by_source[left] & by_source[right]) / len(union))
    return sum(scores) / len(scores) if scores else 0.0


def graph_stats(edges: list[Edge]) -> dict[str, float]:
    by_source: dict[str, list[Edge]] = defaultdict(list)
    nodes: set[str] = set()
    for edge in edges:
        by_source[edge.source].append(edge)
        nodes.add(edge.source)
        nodes.add(edge.target)

    outdegrees = [len(value) for value in by_source.values()]
    return {
        "edges": len(edges),
        "sources": len(by_source),
        "nodes": len(nodes),
        "outdegree_min": min(outdegrees) if outdegrees else 0,
        "outdegree_max": max(outdegrees) if outdegrees else 0,
        "outdegree_mean": sum(outdegrees) / len(outdegrees) if outdegrees else 0.0,
        "neighbor_jaccard_mean": neighbor_jaccard_mean(edges),
    }


def print_stats(label: str, stats: dict[str, float]) -> None:
    print(
        f"{label}: edges={stats['edges']}, sources={stats['sources']}, "
        f"nodes={stats['nodes']}, outdegree={stats['outdegree_min']}/"
        f"{stats['outdegree_mean']:.2f}/{stats['outdegree_max']}, "
        f"source-neighbor-jaccard={stats['neighbor_jaccard_mean']:.4f}"
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Generate a sparse randomized variant of adagram.metta."
    )
    parser.add_argument(
        "--input",
        type=Path,
        default=Path("experiments/data/adagram.metta"),
        help="Input Adagram MeTTa file.",
    )
    parser.add_argument(
        "--sentence",
        type=Path,
        default=Path("experiments/data/insect-sent.metta"),
        help="Sentence file whose words must remain covered.",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("experiments/data/adagram_sparse_random.metta"),
        help="Output sparse randomized MeTTa file.",
    )
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--top-k", type=int, default=8)
    parser.add_argument("--random-k", type=int, default=4)
    parser.add_argument("--fallback-threshold", type=float, default=0.01)
    parser.add_argument("--jitter", type=float, default=0.15)
    parser.add_argument(
        "--diversity-links",
        type=int,
        default=1,
        help="Low-weight random outgoing links to add per covered node.",
    )
    parser.add_argument("--diversity-min-weight", type=float, default=0.05)
    parser.add_argument("--diversity-max-weight", type=float, default=0.35)
    return parser


def main() -> None:
    args = build_parser().parse_args()

    edges = dedupe_by_max_weight(parse_edges(args.input))
    words = parse_sentence_words(args.sentence)
    sparse_edges = choose_sparse_edges(
        edges=edges,
        coverage_words=words,
        top_k=args.top_k,
        random_k=args.random_k,
        fallback_threshold=args.fallback_threshold,
        jitter=args.jitter,
        seed=args.seed,
        diversity_links=args.diversity_links,
        diversity_min_weight=args.diversity_min_weight,
        diversity_max_weight=args.diversity_max_weight,
    )

    args.output.parent.mkdir(parents=True, exist_ok=True)
    write_edges(args.output, sparse_edges)

    print_stats("input", graph_stats(edges))
    print_stats("output", graph_stats(sparse_edges))

    original_nodes = {node for edge in edges for node in (edge.source, edge.target)}
    output_nodes = {node for edge in sparse_edges for node in (edge.source, edge.target)}
    missing = sorted((words & original_nodes) - output_nodes)
    if missing:
        raise SystemExit(f"Coverage validation failed; missing words: {missing}")
    print(f"coverage: preserved {len(words & original_nodes)} sentence words")
    print(f"wrote: {args.output}")


if __name__ == "__main__":
    main()
