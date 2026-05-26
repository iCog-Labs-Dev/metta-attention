#!/usr/bin/env python3
"""Plot the proposed liquidity-style rent equation.

The equation is cycle-based, not wall-clock-based:

requiredFund = max(TARGET_STI, coverageRatio * expectedOutflow)
deficit = max(0, requiredFund - FUNDS_STI)
capacity_i = max(0, STI_i - STI_floor)
rentBudget = min(deficit, maxCollectionRate * totalCapacity)
rent_i = rentBudget * capacity_i / totalCapacity
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
DEFAULT_COVERAGE_RATIOS = (1.0, 1.2, 1.5)
DEFAULT_EXPECTED_OUTFLOWS = (250.0, 500.0, 750.0, 1000.0, 1250.0)
DEFAULT_STI_FLOORS = (0.0, 25.0, 50.0, 75.0, 90.0)
DEFAULT_MAX_COLLECTION_RATES = (0.1, 0.25, 0.5, 1.0)
DEFAULT_ATOM_STIS = (100.0, 100.0, 200.0)


def fmt(value: float | int) -> str:
    return f"{value:g}"


def parse_float_tuple(raw: str) -> tuple[float, ...]:
    return tuple(float(item.strip()) for item in raw.split(",") if item.strip())


def required_fund(target_sti: float, coverage_ratio: float, expected_outflow: float) -> float:
    return max(target_sti, coverage_ratio * expected_outflow)


def capacity(atom_sti: float, sti_floor: float) -> float:
    return max(0.0, atom_sti - sti_floor)


def liquidity_case(
    *,
    funds_sti: float,
    target_sti: float,
    coverage_ratio: float,
    expected_outflow: float,
    atom_stis: tuple[float, ...],
    sti_floor: float,
    max_collection_rate: float,
) -> dict[str, float | str]:
    required = required_fund(target_sti, coverage_ratio, expected_outflow)
    deficit = max(0.0, required - funds_sti)
    capacities = tuple(capacity(sti, sti_floor) for sti in atom_stis)
    total_capacity = sum(capacities)
    max_collectible = max_collection_rate * total_capacity
    rent_budget = min(deficit, max_collectible)
    rents = tuple(
        0.0 if total_capacity <= 0.0 else rent_budget * cap / total_capacity
        for cap in capacities
    )

    return {
        "FUNDS_STI": funds_sti,
        "TARGET_STI": target_sti,
        "coverage_ratio": coverage_ratio,
        "expected_outflow": expected_outflow,
        "required_fund": required,
        "deficit": deficit,
        "atom_stis": " ".join(fmt(value) for value in atom_stis),
        "STI_floor": sti_floor,
        "total_capacity": total_capacity,
        "max_collection_rate": max_collection_rate,
        "max_collectible": max_collectible,
        "rent_budget": rent_budget,
        "atom_rents": " ".join(fmt(value) for value in rents),
        "ending_FUNDS_STI": funds_sti + rent_budget,
    }


def validate_examples() -> None:
    assert required_fund(1000.0, 1.2, 500.0) == 1000.0
    assert required_fund(1000.0, 1.2, 1000.0) == 1200.0

    repaired = liquidity_case(
        funds_sti=900.0,
        target_sti=1000.0,
        coverage_ratio=1.0,
        expected_outflow=500.0,
        atom_stis=(100.0, 100.0, 200.0),
        sti_floor=50.0,
        max_collection_rate=0.5,
    )
    assert abs(float(repaired["rent_budget"]) - 100.0) < 1e-9
    assert abs(float(repaired["ending_FUNDS_STI"]) - 1000.0) < 1e-9
    assert repaired["atom_rents"] == "20 20 60"

    protected = liquidity_case(
        funds_sti=900.0,
        target_sti=1000.0,
        coverage_ratio=1.0,
        expected_outflow=500.0,
        atom_stis=(55.0, 55.0, 55.0),
        sti_floor=50.0,
        max_collection_rate=0.5,
    )
    assert abs(float(protected["rent_budget"]) - 7.5) < 1e-9
    assert protected["atom_rents"] == "2.5 2.5 2.5"

    no_deficit = liquidity_case(
        funds_sti=1000.0,
        target_sti=1000.0,
        coverage_ratio=1.0,
        expected_outflow=500.0,
        atom_stis=(100.0, 100.0, 200.0),
        sti_floor=50.0,
        max_collection_rate=0.5,
    )
    assert float(no_deficit["rent_budget"]) == 0.0


def write_csv(path: Path, rows: list[dict[str, float | str]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)


def case_value(
    *,
    funds_sti: float,
    target_sti: float,
    coverage_ratio: float,
    expected_outflow: float,
    atom_stis: tuple[float, ...],
    sti_floor: float,
    max_collection_rate: float,
    key: str,
) -> float:
    return float(
        liquidity_case(
            funds_sti=funds_sti,
            target_sti=target_sti,
            coverage_ratio=coverage_ratio,
            expected_outflow=expected_outflow,
            atom_stis=atom_stis,
            sti_floor=sti_floor,
            max_collection_rate=max_collection_rate,
        )[key]
    )


def write_plot(
    path: Path,
    *,
    funds: tuple[float, ...],
    coverage_ratios: tuple[float, ...],
    expected_outflows: tuple[float, ...],
    sti_floors: tuple[float, ...],
    max_collection_rates: tuple[float, ...],
    atom_stis: tuple[float, ...],
    target_sti: float,
    fixed_expected_outflow: float,
    fixed_coverage_ratio: float,
    fixed_sti_floor: float,
    fixed_funds_sti: float,
) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fig, axes = plt.subplots(2, 2, figsize=(15, 10), constrained_layout=True)

    required_ax = axes[0][0]
    for coverage_ratio in coverage_ratios:
        required_ax.plot(
            expected_outflows,
            [
                required_fund(target_sti, coverage_ratio, outflow)
                for outflow in expected_outflows
            ],
            marker="o",
            label=f"coverage={fmt(coverage_ratio)}",
        )
    required_ax.axhline(target_sti, color="black", linestyle="--", linewidth=1, alpha=0.55)
    required_ax.set_title(
        "Required Fund From Expected Outflow\n"
        "requiredFund=max(TARGET_STI, coverageRatio * expectedOutflow)",
        fontsize=10,
    )
    required_ax.set_xlabel("expected outflow")
    required_ax.set_ylabel("required fund")
    required_ax.grid(True, alpha=0.25)
    required_ax.legend(fontsize=8)

    budget_ax = axes[0][1]
    required = required_fund(target_sti, fixed_coverage_ratio, fixed_expected_outflow)
    for max_rate in max_collection_rates:
        budget_ax.plot(
            funds,
            [
                case_value(
                    funds_sti=fund,
                    target_sti=target_sti,
                    coverage_ratio=fixed_coverage_ratio,
                    expected_outflow=fixed_expected_outflow,
                    atom_stis=atom_stis,
                    sti_floor=fixed_sti_floor,
                    max_collection_rate=max_rate,
                    key="rent_budget",
                )
                for fund in funds
            ],
            marker="o",
            label=f"maxRate={fmt(max_rate)}",
        )
    budget_ax.axvline(required, color="tab:red", linestyle=":", linewidth=1, alpha=0.65)
    budget_ax.set_title(
        "Rent Budget By Starting Fund\n"
        f"fixed: requiredFund={fmt(required)}, floor={fmt(fixed_sti_floor)}, atoms={atom_stis}",
        fontsize=10,
    )
    budget_ax.set_xlabel("starting FUNDS_STI")
    budget_ax.set_ylabel("rent budget collected this cycle")
    budget_ax.grid(True, alpha=0.25)
    budget_ax.legend(fontsize=8)

    floor_ax = axes[1][0]
    for max_rate in max_collection_rates:
        floor_ax.plot(
            sti_floors,
            [
                case_value(
                    funds_sti=fixed_funds_sti,
                    target_sti=target_sti,
                    coverage_ratio=fixed_coverage_ratio,
                    expected_outflow=fixed_expected_outflow,
                    atom_stis=atom_stis,
                    sti_floor=floor,
                    max_collection_rate=max_rate,
                    key="rent_budget",
                )
                for floor in sti_floors
            ],
            marker="o",
            label=f"maxRate={fmt(max_rate)}",
        )
    floor_ax.set_title(
        "Atom Protection Through STI Floor\n"
        f"fixed: FUNDS_STI={fmt(fixed_funds_sti)}, requiredFund={fmt(required)}, atoms={atom_stis}",
        fontsize=10,
    )
    floor_ax.set_xlabel("STI floor")
    floor_ax.set_ylabel("rent budget collected this cycle")
    floor_ax.grid(True, alpha=0.25)
    floor_ax.legend(fontsize=8)

    ending_ax = axes[1][1]
    for max_rate in max_collection_rates:
        ending_ax.plot(
            funds,
            [
                case_value(
                    funds_sti=fund,
                    target_sti=target_sti,
                    coverage_ratio=fixed_coverage_ratio,
                    expected_outflow=fixed_expected_outflow,
                    atom_stis=atom_stis,
                    sti_floor=fixed_sti_floor,
                    max_collection_rate=max_rate,
                    key="ending_FUNDS_STI",
                )
                for fund in funds
            ],
            marker="o",
            label=f"maxRate={fmt(max_rate)}",
        )
    ending_ax.plot(funds, funds, color="black", linestyle="--", linewidth=1, alpha=0.45, label="unchanged")
    ending_ax.axhline(required, color="tab:red", linestyle=":", linewidth=1, alpha=0.65, label="required")
    ending_ax.set_title(
        "Ending Fund After One Rent Cycle\n"
        "ending fund never exceeds required fund through rent budget",
        fontsize=10,
    )
    ending_ax.set_xlabel("starting FUNDS_STI")
    ending_ax.set_ylabel("ending FUNDS_STI")
    ending_ax.grid(True, alpha=0.25)
    ending_ax.legend(fontsize=8)

    constants = (
        f"fixed defaults: TARGET_STI={fmt(target_sti)}, expectedOutflow={fmt(fixed_expected_outflow)}, "
        f"coverageRatio={fmt(fixed_coverage_ratio)}, STI_floor={fmt(fixed_sti_floor)}, "
        f"atom STIs={' '.join(fmt(value) for value in atom_stis)}"
    )
    fig.suptitle(
        "Proposed Liquidity Rent Equation: Major Parameter Correlations\n"
        f"{fill(constants, width=115)}",
        fontsize=14,
    )
    fig.savefig(path, dpi=160, bbox_inches="tight")
    plt.close(fig)


def main() -> None:
    repo_root = Path(__file__).resolve().parents[4]
    default_output = repo_root / "experiments" / "output" / "af_rent_liquidity_equation_correlation"

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--funds", type=parse_float_tuple, default=DEFAULT_FUNDS)
    parser.add_argument("--coverage-ratios", type=parse_float_tuple, default=DEFAULT_COVERAGE_RATIOS)
    parser.add_argument("--expected-outflows", type=parse_float_tuple, default=DEFAULT_EXPECTED_OUTFLOWS)
    parser.add_argument("--sti-floors", type=parse_float_tuple, default=DEFAULT_STI_FLOORS)
    parser.add_argument("--max-collection-rates", type=parse_float_tuple, default=DEFAULT_MAX_COLLECTION_RATES)
    parser.add_argument("--atom-stis", type=parse_float_tuple, default=DEFAULT_ATOM_STIS)
    parser.add_argument("--target-sti", type=float, default=1000.0)
    parser.add_argument("--fixed-expected-outflow", type=float, default=500.0)
    parser.add_argument("--fixed-coverage-ratio", type=float, default=1.0)
    parser.add_argument("--fixed-sti-floor", type=float, default=50.0)
    parser.add_argument("--fixed-funds-sti", type=float, default=900.0)
    parser.add_argument("--output-prefix", type=Path, default=default_output)
    args = parser.parse_args()

    validate_examples()

    rows = [
        liquidity_case(
            funds_sti=fund,
            target_sti=args.target_sti,
            coverage_ratio=coverage,
            expected_outflow=outflow,
            atom_stis=args.atom_stis,
            sti_floor=floor,
            max_collection_rate=max_rate,
        )
        for fund in args.funds
        for coverage in args.coverage_ratios
        for outflow in args.expected_outflows
        for floor in args.sti_floors
        for max_rate in args.max_collection_rates
    ]

    csv_path = args.output_prefix.with_suffix(".csv")
    png_path = args.output_prefix.with_suffix(".png")
    write_csv(csv_path, rows)
    write_plot(
        png_path,
        funds=args.funds,
        coverage_ratios=args.coverage_ratios,
        expected_outflows=args.expected_outflows,
        sti_floors=args.sti_floors,
        max_collection_rates=args.max_collection_rates,
        atom_stis=args.atom_stis,
        target_sti=args.target_sti,
        fixed_expected_outflow=args.fixed_expected_outflow,
        fixed_coverage_ratio=args.fixed_coverage_ratio,
        fixed_sti_floor=args.fixed_sti_floor,
        fixed_funds_sti=args.fixed_funds_sti,
    )

    print("Python validation examples passed")
    print(f"Wrote {csv_path}")
    print(f"Wrote {png_path}")


if __name__ == "__main__":
    main()
