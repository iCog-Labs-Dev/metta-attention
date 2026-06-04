import unittest

from topology_metrics import (
    _atom_key,
    _children,
    _extract_edge,
    _iter_link_records,
    _normalize_edges,
    topology_metric_values,
    topology_metrics,
)


class FakeAtom:
    def __init__(self, name=None, children=None):
        self._name = name
        self._children = children

    def get_name(self):
        return self._name

    def get_children(self):
        if self._children is None:
            raise TypeError("symbol atoms do not expose children")
        return self._children


class TopologyMetricsTest(unittest.TestCase):
    def test_children_supports_python_sequences_and_hyperon_like_atoms(self):
        self.assertEqual(_children(("A", "B")), ["A", "B"])
        self.assertEqual(_children(FakeAtom(children=["A", "B"])), ["A", "B"])
        self.assertIsNone(_children(FakeAtom(name="A")))

    def test_atom_key_stabilizes_nested_atoms(self):
        nested = FakeAtom(
            children=[
                FakeAtom(name="SimilarityLink"),
                FakeAtom(name="A"),
                FakeAtom(name="B"),
            ]
        )

        self.assertEqual(_atom_key(FakeAtom(name="A")), "A")
        self.assertEqual(_atom_key(nested), "(SimilarityLink A B)")

    def test_iter_link_records_accepts_single_link_or_collection(self):
        single_link = ["ASYMMETRIC_HEBBIAN_LINK", "A", "B"]
        link_collection = [single_link, ["ASYMMETRIC_HEBBIAN_LINK", "B", "C"]]

        self.assertEqual(list(_iter_link_records(single_link)), [single_link])
        self.assertEqual(list(_iter_link_records(link_collection)), link_collection)

    def test_extract_edge_accepts_hebbian_records_and_plain_pairs(self):
        self.assertEqual(
            _extract_edge(["ASYMMETRIC_HEBBIAN_LINK", "A", "B"]),
            ("A", "B"),
        )
        self.assertEqual(_extract_edge(("A", "B")), ("A", "B"))
        self.assertIsNone(_extract_edge(("A",)))

    def test_normalize_edges_ignores_direction_duplicates_and_self_loops(self):
        vertices, edges = _normalize_edges(
            [
                ["ASYMMETRIC_HEBBIAN_LINK", "A", "B"],
                ["ASYMMETRIC_HEBBIAN_LINK", "B", "A"],
                ["ASYMMETRIC_HEBBIAN_LINK", "B", "B"],
            ]
        )

        self.assertEqual(vertices, ["A", "B"])
        self.assertEqual(edges, [("A", "B")])

    def test_empty_graph_has_no_components_or_cycles(self):
        self.assertEqual(
            topology_metrics([]),
            {"triangles": 0, "betti0": 0, "betti1": 0},
        )

    def test_triangle_plus_disconnected_edge(self):
        metrics = topology_metrics(
            [
                ["ASYMMETRIC_HEBBIAN_LINK", "A", "B"],
                ["ASYMMETRIC_HEBBIAN_LINK", "B", "C"],
                ["ASYMMETRIC_HEBBIAN_LINK", "C", "A"],
                ["ASYMMETRIC_HEBBIAN_LINK", "B", "A"],
                ["ASYMMETRIC_HEBBIAN_LINK", "D", "E"],
            ]
        )

        self.assertEqual(metrics, {"triangles": 1, "betti0": 2, "betti1": 1})

    def test_square_cycle_has_betti_one_without_triangle(self):
        metrics = topology_metrics(
            [
                ("A", "B"),
                ("B", "C"),
                ("C", "D"),
                ("D", "A"),
            ]
        )

        self.assertEqual(metrics, {"triangles": 0, "betti0": 1, "betti1": 1})

    def test_hyperon_like_atoms_are_supported(self):
        link_type = FakeAtom(name="ASYMMETRIC_HEBBIAN_LINK")
        links = [
            FakeAtom(children=[link_type, FakeAtom(name="A"), FakeAtom(name="B")]),
            FakeAtom(children=[link_type, FakeAtom(name="B"), FakeAtom(name="C")]),
            FakeAtom(children=[link_type, FakeAtom(name="C"), FakeAtom(name="A")]),
        ]

        self.assertEqual(
            topology_metrics(links),
            {"triangles": 1, "betti0": 1, "betti1": 1},
        )

    def test_metric_values_returns_metta_friendly_order(self):
        self.assertEqual(
            topology_metric_values(
                [
                    ["ASYMMETRIC_HEBBIAN_LINK", "A", "B"],
                    ["ASYMMETRIC_HEBBIAN_LINK", "B", "A"],
                    ["ASYMMETRIC_HEBBIAN_LINK", "B", "C"],
                    ["ASYMMETRIC_HEBBIAN_LINK", "C", "A"],
                ]
            ),
            [1, 1, 1],
        )


if __name__ == "__main__":
    unittest.main()

