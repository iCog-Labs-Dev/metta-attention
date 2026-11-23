from __future__ import annotations

import re

import numpy as np
import scipy.linalg
import scipy.sparse
import scipy.sparse.linalg


EDGE_PATTERN = re.compile(
    r"\(\((?P<link>\w+)\s+(?P<source>\S+)\s+(?P<target>\S+)\)\s+"
    r"\((?P<mean>[-+0-9.eE]+)\s+(?P<confidence>[-+0-9.eE]+)\)\)"
)


def parse_metta_edges(filepath: str) -> list[tuple[str, str, float, float]]:
    """Read weighted MeTTa links used to construct the attention manifold."""
    with open(filepath, encoding="utf-8") as handle:
        content = handle.read()
    return [
        (match.group("source"), match.group("target"), float(match.group("mean")), float(match.group("confidence")))
        for match in EDGE_PATTERN.finditer(content)
    ]


def extract_atoms(edges: list[tuple[str, str, float, float]]) -> list[str]:
    return sorted({endpoint for source, target, _mean, _confidence in edges for endpoint in (source, target)})


def build_adjacency_matrix(edges: list[tuple[str, str, float, float]], nodes: list[str]) -> scipy.sparse.csr_matrix:
    """Construct the directed weighted graph used by the magnetic Laplacian."""
    index = {node: i for i, node in enumerate(nodes)}
    matrix = scipy.sparse.lil_matrix((len(nodes), len(nodes)), dtype=np.float64)
    for source, target, mean, confidence in edges:
        matrix[index[source], index[target]] = mean * confidence
    return matrix.tocsr()


def _fallback(nodes: list[str]) -> dict[str, tuple[float, float]]:
    count = max(len(nodes), 1)
    return {node: (float(np.cos(2.0 * np.pi * i / count)), float(np.sin(2.0 * np.pi * i / count))) for i, node in enumerate(nodes)}


def get_magnetic_coordinates(matrix: scipy.sparse.csr_matrix, nodes: list[str], q: float = 0.25) -> dict[str, tuple[float, float]]:
    """Return a two-dimensional embedding of the graph.

    For directed graphs (asymmetric edges), uses the magnetic-Laplacian: the
    2nd-smallest complex eigenvector is split into (Re, Im) coordinates.

    For undirected/symmetric graphs (where A ≈ Aᵀ), the imaginary part is zero
    so we fall back to standard spectral embedding using the 2nd and 3rd
    smallest real eigenvectors of the symmetric Laplacian.
    """
    count = len(nodes)
    if count == 0:
        return {}
    if count == 1:
        return {nodes[0]: (0.0, 0.0)}
    if count == 2:
        return {nodes[0]: (-1.0, 0.0), nodes[1]: (1.0, 0.0)}
    weights = (matrix + matrix.T).multiply(0.5)
    skew = matrix - matrix.T
    is_directed = abs(skew).nnz > 0 and float(abs(skew).max()) > 1e-10

    # Symmetric degree normalization: prevents peripheral leaf nodes from
    # crushing the coordinates of high-degree core nodes to zero.
    deg_arr = np.asarray(weights.sum(axis=1)).ravel()
    deg_inv_sqrt = np.where(deg_arr > 1e-12, 1.0 / np.sqrt(deg_arr), 0.0)
    d_inv = scipy.sparse.diags(deg_inv_sqrt)

    try:
        if is_directed:
            phase = skew.copy()
            phase.data = np.exp(1j * (2.0 * np.pi * q * skew.data))
            norm_adj = d_inv @ weights.multiply(phase) @ d_inv
            laplacian = scipy.sparse.eye(count) - norm_adj
            k = min(4, count - 1)
            if count <= 4:
                _values, vectors = scipy.linalg.eigh(laplacian.toarray())
            else:
                _values, vectors = scipy.sparse.linalg.eigsh(laplacian.tocsr(), k=k, which="SM")
            v1 = vectors[:, 1]
            # If imaginary part has meaningful variance, use (Re, Im)
            if float(np.std(v1.imag)) > 1e-3 * max(float(np.std(v1.real)), 1e-12):
                return {node: (float(v1[i].real), float(v1[i].imag)) for i, node in enumerate(nodes)}
            # Otherwise use the real parts of the 2nd and 3rd eigenvectors
            v2 = vectors[:, min(2, vectors.shape[1] - 1)]
            return {node: (float(v1[i].real), float(v2[i].real)) for i, node in enumerate(nodes)}
        else:
            norm_adj = d_inv @ weights @ d_inv
            laplacian = scipy.sparse.eye(count) - norm_adj
            k = min(3, count - 1)
            if count <= 4:
                _values, vectors = scipy.linalg.eigh(laplacian.toarray())
            else:
                _values, vectors = scipy.sparse.linalg.eigsh(laplacian.tocsr(), k=k + 1, which="SM")
            v1 = vectors[:, 1].real
            v2 = vectors[:, min(2, vectors.shape[1] - 1)].real
            return {node: (float(v1[i]), float(v2[i])) for i, node in enumerate(nodes)}
    except Exception:
        return _fallback(nodes)
