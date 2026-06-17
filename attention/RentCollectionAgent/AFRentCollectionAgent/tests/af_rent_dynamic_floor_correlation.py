#!/usr/bin/env python3
"""Plot the final AFRentCollectionAgent2 dynamic-floor formula.

This mirrors the current equation in AFRentCollectionAgent2.metta:

fundGap = max(0, TARGET_STI - FUNDS_STI)
desiredCollection = AFRentCoverageRatio * fundGap
floorSti = min(STI_i for i in AF)
capacity_i = max(0, STI_i - floorSti)
collectionBudget = min(desiredCollection,
                       AFRentMaxCollectionRate * sum(capacity_i))
rent_i = collectionBudget * capacity_i / sum(capacity_i)
"""

from __future__ import annotations

import argparse
import csv
import os
from pathlib import Path
from textwrap import fill


MPL_CONFIG_DIR = Path("/tmp/metta-attention-matplotlib")
MPL_CONFIG_DIR.mkdir(parents=True, exist_ok=True)
os.environ.setdefault("MPLCONFIGDIR", str(MPL_CONFIG_DIR))

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt


DEFAULT_FUNDS = (500.0, 750.0, 900.0, 950.0, 990.0, 1000.0, 1100.0)
DEFAULT_COVERAGE_RATIOS = (0.5, 1.0, 1.2)
DEFAULT_MAX_COLLECTION_RATES = (0.1, 0.25, 0.5, 1.0)
DEFAULT_ATOM_PROFILES = (
    (20.0, 100.0, 200.0),
    (20.0, 20.0, 100.0),
    (80.0, 100.0, 200.0),
    (20.0, 20.0, 20.0),
)


def fmt(value: float | int) -> str:
    return f"{value:g}"


def parse_float_tuple(raw: str) -> tuple[float, ...]:
    return tuple(float(item.strip()) for item in raw.split(",") if item.strip())


def parse_profiles(raw: str) -> tuple[tuple[float, ...], ...]:
    profiles = []
    for profile in raw.split(";"):
        values = tuple(float(item.strip()) for item in profile.split(",") if item.strip())
        if values:
            profiles.append(values)
    return tuple(profiles)


def dynamic_floor_case(
    *,
    funds_sti: float,
    target_sti: float,
    coverage_ratio: float,
    max_collection_rate: float,
    atom_stis: tuple[float, ...],
) -> dict[str, float | str]:
    fund_gap = max(0.0, target_sti - funds_sti)
    desired_collection = coverage_ratio * fund_gap
    floor_sti = min(atom_stis) if atom_stis else 0.0
    capacities = tuple(max(0.0, sti - floor_sti) for sti in atom_stis)
    total_capacity = sum(capacities)
    max_collectible = max_collection_rate * total_capacity
    collection_budget = min(desired_collection, max_collectible)
    rents = tuple(
        0.0 if total_capacity <= 0.0 else collection_budget * cap / total_capacity
        for cap in capacities
    )
    ending_stis = tuple(sti - rent for sti, rent in zip(atom_stis, rents))

    return {
        "FUNDS_STI": funds_sti,
        "TARGET_STI": target_sti,
        "AFRentCoverageRatio": coverage_ratio,
        "AFRentMaxCollectionRate": max_collection_rate,
        "atom_stis": " ".join(fmt(value) for value in atom_stis),
        "fundGap": fund_gap,
        "desiredCollection": desired_collection,
        "floorSti": floor_sti,
        "capacities": " ".join(fmt(value) for value in capacities),
        "totalCapacity": total_capacity,
        "maxCollectible": max_collectible,
        "collectionBudget": collection_budget,
        "atom_rents": " ".join(fmt(value) for value in rents),
        "ending_atom_stis": " ".join(fmt(value) for value in ending_stis),
        "ending_FUNDS_STI": funds_sti + collection_budget,
    }


def validate_examples() -> None:
    repaired = dynamic_floor_case(
        funds_sti=900.0,
        target_sti=1000.0,
        coverage_ratio=1.0,
        max_collection_rate=1.0,
        atom_stis=(20.0, 100.0, 200.0),
    )
    assert repaired["fundGap"] == 100.0
    assert repaired["desiredCollection"] == 100.0
    assert repaired["floorSti"] == 20.0
    assert repaired["totalCapacity"] == 260.0
    assert repaired["collectionBudget"] == 100.0
    assert abs(float(repaired["ending_FUNDS_STI"]) - 1000.0) < 1e-9

    capped = dynamic_floor_case(
        funds_sti=900.0,
        target_sti=1000.0,
        coverage_ratio=1.0,
        max_collection_rate=0.25,
        atom_stis=(20.0, 100.0, 200.0),
    )
    assert capped["collectionBudget"] == 65.0
    assert abs(float(capped["ending_FUNDS_STI"]) - 965.0) < 1e-9

    no_capacity = dynamic_floor_case(
        funds_sti=900.0,
        target_sti=1000.0,
        coverage_ratio=1.0,
        max_collection_rate=1.0,
        atom_stis=(20.0, 20.0, 20.0),
    )
    assert no_capacity["totalCapacity"] == 0.0
    assert no_capacity["collectionBudget"] == 0.0
    assert no_capacity["ending_FUNDS_STI"] == 900.0

    over_repair = dynamic_floor_case(
        funds_sti=900.0,
        target_sti=1000.0,
        coverage_ratio=1.2,
        max_collection_rate=1.0,
        atom_stis=(20.0, 100.0, 200.0),
    )
    assert over_repair["collectionBudget"] == 120.0
    assert over_repair["ending_FUNDS_STI"] == 1020.0


def write_csv(path: Path, rows: list[dict[str, float | str]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)


def budget_value(
    *,
    funds_sti: float,
    target_sti: float,
    coverage_ratio: float,
    max_collection_rate: float,
    atom_stis: tuple[float, ...],
    key: str,
) -> float:
    return float(
        dynamic_floor_case(
            funds_sti=funds_sti,
            target_sti=target_sti,
            coverage_ratio=coverage_ratio,
            max_collection_rate=max_collection_rate,
            atom_stis=atom_stis,
        )[key]
    )


def profile_label(atom_stis: tuple[float, ...]) -> str:
    return "[" + ",".join(fmt(value) for value in atom_stis) + "]"


def write_plot(
    path: Path,
    *,
    funds: tuple[float, ...],
    coverage_ratios: tuple[float, ...],
    max_collection_rates: tuple[float, ...],
    atom_profiles: tuple[tuple[float, ...], ...],
    target_sti: float,
    fixed_funds_sti: float,
    fixed_coverage_ratio: float,
    fixed_max_collection_rate: float,
    fixed_atom_stis: tuple[float, ...],
) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fig, axes = plt.subplots(2, 2, figsize=(15.5, 10.5), constrained_layout=True)

    budget_ax = axes[0][0]
    for coverage_ratio in coverage_ratios:
        budget_ax.plot(
            funds,
            [
                budget_value(
                    funds_sti=fund,
                    target_sti=target_sti,
                    coverage_ratio=coverage_ratio,
                    max_collection_rate=fixed_max_collection_rate,
                    atom_stis=fixed_atom_stis,
                    key="collectionBudget",
                )
                for fund in funds
            ],
            marker="o",
            label=f"coverage={fmt(coverage_ratio)}",
        )
    budget_ax.axvline(target_sti, color="black", linestyle="--", linewidth=1, alpha=0.55)
    budget_ax.set_title(
        "Collection Budget vs Starting Fund\n"
        f"fixed atoms={profile_label(fixed_atom_stis)}, maxRate={fmt(fixed_max_collection_rate)}",
        fontsize=10,
    )
    budget_ax.set_xlabel("starting FUNDS_STI")
    budget_ax.set_ylabel("collectionBudget")
    budget_ax.grid(True, alpha=0.25)
    budget_ax.legend(fontsize=8)

    ending_ax = axes[0][1]
    for coverage_ratio in coverage_ratios:
        ending_ax.plot(
            funds,
            [
                budget_value(
                    funds_sti=fund,
                    target_sti=target_sti,
                    coverage_ratio=coverage_ratio,
                    max_collection_rate=fixed_max_collection_rate,
                    atom_stis=fixed_atom_stis,
                    key="ending_FUNDS_STI",
                )
                for fund in funds
            ],
            marker="o",
            label=f"coverage={fmt(coverage_ratio)}",
        )
    ending_ax.axhline(target_sti, color="black", linestyle="--", linewidth=1, alpha=0.55)
    ending_ax.set_title(
        "Ending Fund vs Starting Fund\n"
        f"fixed atoms={profile_label(fixed_atom_stis)}, maxRate={fmt(fixed_max_collection_rate)}",
        fontsize=10,
    )
    ending_ax.set_xlabel("starting FUNDS_STI")
    ending_ax.set_ylabel("ending FUNDS_STI")
    ending_ax.grid(True, alpha=0.25)
    ending_ax.legend(fontsize=8)

    rate_ax = axes[1][0]
    for atom_stis in atom_profiles:
        rate_ax.plot(
            max_collection_rates,
            [
                budget_value(
                    funds_sti=fixed_funds_sti,
                    target_sti=target_sti,
                    coverage_ratio=fixed_coverage_ratio,
                    max_collection_rate=max_rate,
                    atom_stis=atom_stis,
                    key="collectionBudget",
                )
                for max_rate in max_collection_rates
            ],
            marker="o",
            label=f"atoms={profile_label(atom_stis)}",
        )
    rate_ax.set_title(
        "Collection Budget vs Max Collection Rate\n"
        f"fixed FUNDS_STI={fmt(fixed_funds_sti)}, coverage={fmt(fixed_coverage_ratio)}",
        fontsize=10,
    )
    rate_ax.set_xlabel("AFRentMaxCollectionRate")
    rate_ax.set_ylabel("collectionBudget")
    rate_ax.grid(True, alpha=0.25)
    rate_ax.legend(fontsize=8)

    rent_ax = axes[1][1]
    example = dynamic_floor_case(
        funds_sti=fixed_funds_sti,
        target_sti=target_sti,
        coverage_ratio=fixed_coverage_ratio,
        max_collection_rate=fixed_max_collection_rate,
        atom_stis=fixed_atom_stis,
    )
    rents = [float(value) for value in str(example["atom_rents"]).split()]
    capacities = [float(value) for value in str(example["capacities"]).split()]
    labels = [fmt(value) for value in fixed_atom_stis]
    x_positions = list(range(len(labels)))
    width = 0.36
    rent_ax.bar([x - width / 2 for x in x_positions], capacities, width=width, label="capacity")
    rent_ax.bar([x + width / 2 for x in x_positions], rents, width=width, label="rent")
    rent_ax.set_xticks(x_positions, labels)
    rent_ax.set_title(
        "Dynamic Floor Capacity and Rent Distribution\n"
        f"floor={fmt(float(example['floorSti']))}, budget={fmt(float(example['collectionBudget']))}",
        fontsize=10,
    )
    rent_ax.set_xlabel("atom starting STI")
    rent_ax.set_ylabel("STI")
    rent_ax.grid(True, axis="y", alpha=0.25)
    rent_ax.legend(fontsize=8)

    constants = (
        f"Final formula. TARGET_STI={fmt(target_sti)}; fixed FUNDS_STI={fmt(fixed_funds_sti)}; "
        f"fixed coverage={fmt(fixed_coverage_ratio)}; fixed maxRate={fmt(fixed_max_collection_rate)}; "
        f"fixed atoms={profile_label(fixed_atom_stis)}. No elapsed time, AFRentFrequency, or expectedOutflow."
    )
    fig.suptitle(
        "AFRentCollectionAgent2: Fund Deficit x Dynamic Floor Capacity\n"
        f"{fill(constants, width=125)}",
        fontsize=13,
    )
    fig.savefig(path, dpi=160, bbox_inches="tight")
    plt.close(fig)


def main() -> None:
    repo_root = Path(__file__).resolve().parents[4]
    default_output = repo_root / "experiments" / "output" / "af_rent_dynamic_floor_correlation"

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--funds", type=parse_float_tuple, default=DEFAULT_FUNDS)
    parser.add_argument("--coverage-ratios", type=parse_float_tuple, default=DEFAULT_COVERAGE_RATIOS)
    parser.add_argument("--max-collection-rates", type=parse_float_tuple, default=DEFAULT_MAX_COLLECTION_RATES)
    parser.add_argument("--atom-profiles", type=parse_profiles, default=DEFAULT_ATOM_PROFILES)
    parser.add_argument("--target-sti", type=float, default=1000.0)
    parser.add_argument("--fixed-funds-sti", type=float, default=900.0)
    parser.add_argument("--fixed-coverage-ratio", type=float, default=1.2)
    parser.add_argument("--fixed-max-collection-rate", type=float, default=1.0)
    parser.add_argument("--fixed-atom-stis", type=parse_float_tuple, default=(20.0, 100.0, 200.0))
    parser.add_argument("--output-prefix", type=Path, default=default_output)
    args = parser.parse_args()

    validate_examples()

    rows = [
        dynamic_floor_case(
            funds_sti=funds_sti,
            target_sti=args.target_sti,
            coverage_ratio=coverage_ratio,
            max_collection_rate=max_collection_rate,
            atom_stis=atom_stis,
        )
        for funds_sti in args.funds
        for coverage_ratio in args.coverage_ratios
        for max_collection_rate in args.max_collection_rates
        for atom_stis in args.atom_profiles
    ]

    csv_path = args.output_prefix.with_suffix(".csv")
    png_path = args.output_prefix.with_suffix(".png")
    write_csv(csv_path, rows)
    write_plot(
        png_path,
        funds=args.funds,
        coverage_ratios=args.coverage_ratios,
        max_collection_rates=args.max_collection_rates,
        atom_profiles=args.atom_profiles,
        target_sti=args.target_sti,
        fixed_funds_sti=args.fixed_funds_sti,
        fixed_coverage_ratio=args.fixed_coverage_ratio,
        fixed_max_collection_rate=args.fixed_max_collection_rate,
        fixed_atom_stis=args.fixed_atom_stis,
    )

    print(f"Wrote {csv_path}")
    print(f"Wrote {png_path}")


if __name__ == "__main__":
    main()