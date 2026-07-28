from __future__ import annotations

import re

import numpy as np
import scipy.linalg
import scipy.sparse
import scipy.sparse.linalg
import scipy.sparse.csgraph


EDGE_PATTERN = re.compile(
    r"\(\((?P<link>\w+)\s+(?P<source>\S+)\s+(?P<target>\S+)\)\s+"
    r"\((?P<mean>[-+0-9.eE]+)\s+(?P<confidence>[-+0-9.eE]+)\)\)"
)


def parse_metta_edges(filepath: str) -> list[tuple[str, str, float, float]]:
    """Parse weighted MeTTa links into source, target, mean, confidence tuples."""

    with open(filepath) as handle:
        content = handle.read()

    return [
        (
            match.group("source"),
            match.group("target"),
            float(match.group("mean")),
            float(match.group("confidence")),
        )
        for match in EDGE_PATTERN.finditer(content)
    ]


def extract_atoms(edges: list[tuple[str, str, float, float]]) -> list[str]:
    return sorted(set([edge[0] for edge in edges] + [edge[1] for edge in edges]))


def build_adjacency_matrix(
    edges: list[tuple[str, str, float, float]],
    nodes: list[str],
    make_symmetric: bool = False,
) -> tuple[scipy.sparse.csr_matrix, dict[str, int]]:
    """Build a sparse adjacency matrix from weighted MeTTa edges."""
    n = len(nodes)
    node_to_idx = {node: i for i, node in enumerate(nodes)}
    matrix = scipy.sparse.lil_matrix((n, n), dtype=np.float64)

    for source, target, mean, confidence in edges:
        i, j = node_to_idx[source], node_to_idx[target]
        matrix[i, j] = mean * confidence
        if make_symmetric:
            matrix[j, i] = mean * confidence

    return matrix.tocsr(), node_to_idx


def get_spectral_coordinates_magnetic(
    matrix: scipy.sparse.csr_matrix, nodes: list[str], q: float = 0.25
) -> dict[str, tuple[float, float]]:
    """
    Embed atoms using a magnetic Laplacian.

    Gives the fluid layer manifold coordinates; it does not mutate ECAN
    state or decide atom importance.
    Uses eigsh (Lanczos) to extract only the 2 smallest eigenvectors,
    avoiding the O(N^3) dense eigendecomposition.
    """

    if not nodes:
        return {}
    if len(nodes) == 1:
        return {nodes[0]: (0.0, 0.0)}

    n = len(nodes)

    if n <= 3:
        dense = matrix.toarray()
        weights = 0.5 * (dense + dense.T)
        theta_mat = 2 * np.pi * q * (dense - dense.T)
        hermitian = weights * np.exp(1j * theta_mat)
        degree = np.diag(np.sum(weights, axis=1))
        laplacian = degree - hermitian
        try:
            _, eigenvectors = scipy.linalg.eigh(laplacian)
            vector = eigenvectors[:, 1]
            return {
                node: (float(np.real(vector[i])), float(np.imag(vector[i])))
                for i, node in enumerate(nodes)
            }
        except Exception as exc:
            print(f"Dense eigendecomposition failed: {exc}")
            return {
                node: (
                    float(np.cos(2 * np.pi * i / n)),
                    float(np.sin(2 * np.pi * i / n)),
                )
                for i, node in enumerate(nodes)
            }

    weights = (matrix + matrix.T).multiply(0.5)
    skew = matrix - matrix.T
    theta_data = 2 * np.pi * q * skew.data
    phase = skew.copy()
    phase.data = np.exp(1j * theta_data)
    hermitian = weights.multiply(phase).tocsr()

    degree_vals = np.array(weights.sum(axis=1)).flatten()
    degree_diag = scipy.sparse.diags(degree_vals, format="csr")
    laplacian = degree_diag - hermitian

    try:
        diag_vals = np.real(laplacian.diagonal())
        diag_vals[diag_vals == 0] = 1.0
        M = scipy.sparse.diags(1.0 / diag_vals)

        X = np.random.rand(laplacian.shape[0], 2) + 1j * np.random.rand(laplacian.shape[0], 2)
        
        _, eigenvectors = scipy.sparse.linalg.lobpcg(laplacian, X, M=M, largest=False, maxiter=200, tol=1e-2)
        
        vector = eigenvectors[:, 1]
        return {
            node: (float(np.real(vector[i])), float(np.imag(vector[i])))
            for i, node in enumerate(nodes)
        }
    except Exception as exc:
        print(f"Sparse eigendecomposition failed: {exc}")
        return {
            node: (
                float(np.cos(2 * np.pi * i / n)),
                float(np.sin(2 * np.pi * i / n)),
            )
            for i, node in enumerate(nodes)
        }


def spectral_to_grid_coords(
    spectral_coords: dict[str, tuple[float, float]], grid_size: int
) -> dict[str, tuple[int, int]]:
    if not spectral_coords:
        return {}

    coords = np.array(list(spectral_coords.values()), dtype=np.float64)
    n = len(spectral_coords)

    ranks_x = np.argsort(np.argsort(coords[:, 0]))
    ranks_y = np.argsort(np.argsort(coords[:, 1]))

    positions: dict[str, tuple[int, int]] = {}
    for i, node in enumerate(spectral_coords):
        grid_x = int(ranks_x[i] / n * (grid_size - 1)) % grid_size if n > 1 else 0
        grid_y = int(ranks_y[i] / n * (grid_size - 1)) % grid_size if n > 1 else 0
        positions[node] = (grid_x, grid_y)
    return positions
