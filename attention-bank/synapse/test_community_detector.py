import sys
import unittest
from pathlib import Path


ROOT_DIR = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT_DIR))

from community_detector import (
    get_dynamic_hebbian_modules,
    get_dynamic_modules,
)


def _flat_atoms(modules):
    return {atom for module in modules for atom in module}


def _sorted_modules(modules):
    return sorted(tuple(sorted(module)) for module in modules)


class DynamicModulesTest(unittest.TestCase):
    def test_empty_links_return_no_modules(self):
        self.assertEqual(get_dynamic_modules([], []), [])

    def test_unlinked_af_atoms_become_singleton_modules(self):
        modules = get_dynamic_modules(["A", "B", "C"], [["ASYMMETRIC_HEBBIAN_LINK", "A", "B"]])

        self.assertEqual(
            _sorted_modules(modules),
            [("A", "B"), ("C",)],
        )

    def test_weight_values_do_not_become_module_atoms(self):
        modules = get_dynamic_modules(
            [],
            [
                ["ASYMMETRIC_HEBBIAN_LINK", "A", "B", 0.9],
                ["ASYMMETRIC_HEBBIAN_LINK", "B", "C", 0.8],
            ],
        )

        self.assertEqual(_flat_atoms(modules), {"A", "B", "C"})

    def test_nested_atoms_are_returned_as_sexpressions(self):
        modules = get_dynamic_modules(
            [],
            [
                [
                    "SimilarityLink",
                    ["ConceptNode", "dog"],
                    ["ConceptNode", "animal"],
                    0.75,
                ]
            ],
        )

        self.assertEqual(
            _sorted_modules(modules),
            [("(ConceptNode animal)", "(ConceptNode dog)")],
        )

    def test_multilevel_community_detection_separates_strong_clusters(self):
        modules = get_dynamic_modules(
            [],
            [
                ["ASYMMETRIC_HEBBIAN_LINK", "A", "B", 5.0],
                ["ASYMMETRIC_HEBBIAN_LINK", "B", "C", 5.0],
                ["ASYMMETRIC_HEBBIAN_LINK", "A", "C", 5.0],
                ["ASYMMETRIC_HEBBIAN_LINK", "D", "E", 5.0],
                ["ASYMMETRIC_HEBBIAN_LINK", "E", "F", 5.0],
                ["ASYMMETRIC_HEBBIAN_LINK", "D", "F", 5.0],
                ["ASYMMETRIC_HEBBIAN_LINK", "C", "D", 0.01],
            ],
        )

        self.assertEqual(
            _sorted_modules(modules),
            [("A", "B", "C"), ("D", "E", "F")],
        )

    def test_link_value_records_use_stv_mean_as_weight(self):
        modules = get_dynamic_modules(
            [],
            [
                [["ASYMMETRIC_HEBBIAN_LINK", "insect", "spider"], ["STV", 0.9, 0.9]],
                [["ASYMMETRIC_HEBBIAN_LINK", "spider", "moth"], ["STV", 0.8, 0.9]],
                [["ASYMMETRIC_HEBBIAN_LINK", "insect", "moth"], ["STV", 0.85, 0.9]],
                [["ASYMMETRIC_HEBBIAN_LINK", "poison", "toxin"], ["STV", 0.9, 0.9]],
                [["ASYMMETRIC_HEBBIAN_LINK", "toxin", "caffeine"], ["STV", 0.8, 0.9]],
                [["ASYMMETRIC_HEBBIAN_LINK", "poison", "caffeine"], ["STV", 0.85, 0.9]],
                [["ASYMMETRIC_HEBBIAN_LINK", "moth", "poison"], ["STV", 0.01, 0.9]],
            ],
        )

        self.assertEqual(
            _sorted_modules(modules),
            [("caffeine", "poison", "toxin"), ("insect", "moth", "spider")],
        )

    def test_zero_weight_link_does_not_connect_modules(self):
        modules = get_dynamic_modules(
            ["A", "B", "C", "D"],
            [
                [["ASYMMETRIC_HEBBIAN_LINK", "A", "B"], ["STV", 1.0, 0.9]],
                [["ASYMMETRIC_HEBBIAN_LINK", "C", "D"], ["STV", 1.0, 0.9]],
                [["ASYMMETRIC_HEBBIAN_LINK", "B", "C"], ["STV", 0.0, 0.9]],
            ],
        )

        self.assertEqual(
            _sorted_modules(modules),
            [("A", "B"), ("C", "D")],
        )

    def test_hebbian_modules_cluster_all_supplied_typespace_links(self):
        modules = get_dynamic_hebbian_modules(
            [
                [["ASYMMETRIC_HEBBIAN_LINK", "A", "B"], ["STV", 0.8, 0.5]],
                [["ASYMMETRIC_HEBBIAN_LINK", "B", "C"], ["STV", 0.8, 0.5]],
                [["ASYMMETRIC_HEBBIAN_LINK", "X", "Y"], ["STV", 0.8, 0.5]],
                [["ASYMMETRIC_HEBBIAN_LINK", "Y", "Z"], ["STV", 0.8, 0.5]],
            ],
        )

        self.assertEqual(
            _sorted_modules(modules),
            [("A", "B", "C"), ("X", "Y", "Z")],
        )


if __name__ == "__main__":
    unittest.main()
