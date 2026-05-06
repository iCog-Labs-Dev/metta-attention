import re
import sys
import numpy as np


def parse_metta(filepath):
    pattern = r"\(\(SimilarityLink (\w+) (\w+)\) \((\S+) (\S+)\)\)"
    with open(filepath) as f:
        content = f.read()

    matches = re.findall(pattern, content)
    edges = [(m[0], m[1], float(m[2]), float(m[3])) for m in matches]
    return edges


def edges_to_normalized_matrix(edges, make_symmetric=True, missing_value=0.0):
    nodes = sorted(set([e[0] for e in edges] + [e[1] for e in edges]))
    node_to_idx = {n: i for i, n in enumerate(nodes)}
    n = len(nodes)

    matrix = [[0.0] * n for _ in range(n)]
    for src, dst, s1, s2 in edges:
        i, j = node_to_idx[src], node_to_idx[dst]
        matrix[i][j] = s1
        if make_symmetric:
            existing = matrix[j][i]
            matrix[j][i] = (s1 + existing) / 2

    if missing_value != 0.0:
        for i in range(n):
            for j in range(n):
                if matrix[i][j] == 0.0:
                    matrix[i][j] = missing_value

    row_min = [min(row) for row in matrix]
    row_max = [max(row) for row in matrix]

    normalized = []
    for i, row in enumerate(matrix):
        normalized_row = []
        denom = row_max[i] - row_min[i] + 1e-10
        for val in row:
            normalized_row.append((val - row_min[i]) / denom)
        normalized.append(normalized_row)
    return normalized, nodes


def load_adagram_matrix(metta_path="experiments/data/adagram.metta"):
    edges = parse_metta(metta_path)
    matrix, nodes = edges_to_normalized_matrix(edges)
    return matrix, nodes


def compute_coordinates(matrix, nodes):
    A = np.array(matrix, dtype=np.float64)
    eigenvalues, eigenvectors = np.linalg.eig(A)

    idx = np.argsort(np.abs(eigenvalues))[::-1]

    lambda2, lambda3 = eigenvalues[idx[1]], eigenvalues[idx[2]]
    psi2, psi3 = eigenvectors[:, idx[1]], eigenvectors[:, idx[2]]

    coords = {}
    for i, node in enumerate(nodes):
        coords[node] = (float(lambda2 * psi2[i]), float(lambda3 * psi3[i]))

    return coords, (float(lambda2), float(lambda3))


if __name__ == "__main__":
    matrix, nodes = load_adagram_matrix()
    coords, (l2, l3) = compute_coordinates(matrix, nodes)
    print(f"λ₂ = {l2:.4f}, λ₃ = {l3:.4f}")
    print(f"\nCoordinates ({len(coords)} nodes):")
    for node, (x, y) in coords.items():
        print(f"  {node}: ({x:.4f}, {y:.4f})")
