#!/usr/bin/env python3
"""Sweep FUNDS_STI, AFRentFrequency, and elapsed time for AF rent.

Only these three variables change:
  - FUNDS_STI
  - AFRentFrequency
  - elapsed seconds

Fixed values:
  - atom STI = 100
  - TARGET_STI = 1000
  - STI_FUNDS_BUFFER = 1000
  - StartingAtomStiRent = 1
  - atom count = 1
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


DEFAULT_FUNDS = (500.0, 750.0, 900.0, 990.0, 1000.0, 1100.0)
DEFAULT_FREQUENCIES = (2.0, 5.0, 10.0, 20.0, 50.0)
DEFAULT_ELAPSED_SECONDS = (0.02, 0.05, 0.10, 0.15, 0.25, 0.50, 1.00)


def fmt(value: float | int) -> str:
    return f"{value:g}"


def parse_float_tuple(raw: str) -> tuple[float, ...]:
    return tuple(float(item.strip()) for item in raw.split(",") if item.strip())


def calculate_base_rent(
    funds_sti: float,
    *,
    target_sti: float,
    sti_funds_buffer: float,
    starting_atom_sti_rent: float,
) -> float:
    diff = target_sti - funds_sti
    if diff <= 0:
        return 0.0

    normalized_diff = diff / sti_funds_buffer
    clamped = min(normalized_diff, 1.0)
    return starting_atom_sti_rent * (1.0 + clamped)


def rent_case(
    *,
    funds_sti: float,
    frequency: float,
    elapsed_seconds: float,
    target_sti: float,
    sti_funds_buffer: float,
    starting_atom_sti_rent: float,
    atom_sti: float,
) -> dict[str, float | bool]:
    threshold_seconds = 1.0 / frequency
    passes_threshold = elapsed_seconds >= threshold_seconds
    base_rent = calculate_base_rent(
        funds_sti,
        target_sti=target_sti,
        sti_funds_buffer=sti_funds_buffer,
        starting_atom_sti_rent=starting_atom_sti_rent,
    )
    timer_weight = elapsed_seconds * frequency if passes_threshold else 0.0
    collected = min(atom_sti, base_rent * timer_weight) if passes_threshold else 0.0

    return {
        "FUNDS_STI": funds_sti,
        "AFRentFrequency": frequency,
        "elapsed_seconds": elapsed_seconds,
        "threshold_seconds": threshold_seconds,
        "passes_threshold": passes_threshold,
        "base_rent_before_timer": base_rent,
        "timer_weight": timer_weight,
        "sti_rent_collected": collected,
        "ending_atom_sti": atom_sti - collected,
        "ending_FUNDS_STI": funds_sti + collected,
    }


def validate_examples(
    *,
    target_sti: float,
    sti_funds_buffer: float,
    starting_atom_sti_rent: float,
    atom_sti: float,
) -> None:
    def collected(funds: float, frequency: float, elapsed: float) -> float:
        return float(
            rent_case(
                funds_sti=funds,
                frequency=frequency,
                elapsed_seconds=elapsed,
                target_sti=target_sti,
                sti_funds_buffer=sti_funds_buffer,
                starting_atom_sti_rent=starting_atom_sti_rent,
                atom_sti=atom_sti,
            )["sti_rent_collected"]
        )

    assert collected(900.0, 10.0, 0.05) == 0.0
    assert abs(collected(900.0, 10.0, 0.10) - 1.1) < 1e-9
    assert abs(collected(900.0, 10.0, 0.25) - 2.75) < 1e-9
    assert abs(collected(500.0, 10.0, 0.25) - 3.75) < 1e-9
    assert collected(1000.0, 10.0, 0.25) == 0.0
    assert collected(1100.0, 10.0, 0.25) == 0.0
    assert collected(500.0, 5.0, 0.10) == 0.0
    assert abs(collected(500.0, 20.0, 0.10) - 3.0) < 1e-9


def write_csv(path: Path, rows: list[dict[str, float | bool]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)


def get_row(
    rows: list[dict[str, float | bool]],
    *,
    fund: float,
    frequency: float,
    elapsed_seconds: float,
) -> dict[str, float | bool]:
    return next(
        row
        for row in rows
        if row["FUNDS_STI"] == fund
        and row["AFRentFrequency"] == frequency
        and row["elapsed_seconds"] == elapsed_seconds
    )


def write_plot(
    path: Path,
    rows: list[dict[str, float | bool]],
    *,
    funds: tuple[float, ...],
    frequencies: tuple[float, ...],
    elapsed_seconds: tuple[float, ...],
    target_sti: float,
    sti_funds_buffer: float,
    starting_atom_sti_rent: float,
    atom_sti: float,
) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)

    fig, axes = plt.subplots(len(funds), 2, figsize=(16, 3.9 * len(funds)), constrained_layout=True)
    axes_by_row = [axes] if len(funds) == 1 else axes

    for row_index, fund in enumerate(funds):
        rent_ax = axes_by_row[row_index][0]
        fund_ax = axes_by_row[row_index][1]
        base_rent = calculate_base_rent(
            fund,
            target_sti=target_sti,
            sti_funds_buffer=sti_funds_buffer,
            starting_atom_sti_rent=starting_atom_sti_rent,
        )

        max_collected = 0.0
        max_ending_fund = fund
        max_case = None
        for frequency in frequencies:
            series = [
                get_row(
                    rows,
                    fund=fund,
                    frequency=frequency,
                    elapsed_seconds=elapsed,
                )
                for elapsed in elapsed_seconds
            ]
            collected_values = [float(item["sti_rent_collected"]) for item in series]
            ending_fund_values = [float(item["ending_FUNDS_STI"]) for item in series]

            rent_ax.plot(
                elapsed_seconds,
                collected_values,
                marker="o",
                linewidth=1.8,
                label=f"{fmt(frequency)}Hz",
            )
            fund_ax.plot(
                elapsed_seconds,
                ending_fund_values,
                marker="o",
                linewidth=1.8,
                label=f"{fmt(frequency)}Hz",
            )

            for elapsed, collected, ending_fund in zip(elapsed_seconds, collected_values, ending_fund_values):
                if collected > max_collected:
                    max_collected = collected
                    max_ending_fund = ending_fund
                    max_case = (frequency, elapsed)

        rent_ax.axhline(0.0, color="black", linestyle="--", linewidth=1, alpha=0.45)
        fund_ax.axhline(fund, color="black", linestyle="--", linewidth=1, alpha=0.45)
        if target_sti >= min(float(row["ending_FUNDS_STI"]) for row in rows):
            fund_ax.axhline(target_sti, color="tab:red", linestyle=":", linewidth=1, alpha=0.5)

        title = (
            f"FUNDS_STI={fmt(fund)} | fund-pressure rent rate={fmt(base_rent)}\n"
            "rate = 0 when fund >= target; final rent still needs elapsed >= 1/frequency"
        )
        rent_ax.set_title(
            title,
            fontsize=10,
        )
        fund_ax.set_title(
            f"Ending fund from FUNDS_STI={fmt(fund)}\n"
            "dashed = unchanged fund, dotted red = TARGET_STI",
            fontsize=10,
        )

        rent_ax.set_xlabel("elapsed seconds")
        rent_ax.set_ylabel("STI rent collected")
        rent_ax.grid(True, alpha=0.25)

        fund_ax.set_xlabel("elapsed seconds")
        fund_ax.set_ylabel("ending FUNDS_STI")
        fund_ax.grid(True, alpha=0.25)

        if max_case is not None:
            frequency, elapsed = max_case
            rent_ax.annotate(
                f"max {fmt(max_collected)}\n{fmt(frequency)}Hz, {fmt(elapsed)}s",
                xy=(elapsed, max_collected),
                xytext=(6, 8),
                textcoords="offset points",
                fontsize=8,
            )
            fund_ax.annotate(
                f"max fund {fmt(max_ending_fund)}",
                xy=(elapsed, max_ending_fund),
                xytext=(6, 8),
                textcoords="offset points",
                fontsize=8,
            )

        if row_index == 0:
            rent_ax.legend(title="frequency", fontsize=8)
            fund_ax.legend(title="frequency", fontsize=8)

    constants = (
        f"varies: FUNDS_STI, AFRentFrequency, elapsed seconds | fixed: atom STI={fmt(atom_sti)}, "
        f"TARGET_STI={fmt(target_sti)}, STI_FUNDS_BUFFER={fmt(sti_funds_buffer)}, "
        f"StartingAtomStiRent={fmt(starting_atom_sti_rent)}, atom count=1"
    )
    fig.suptitle(
        "AFRentCollectionAgent: FUNDS_STI x AFRentFrequency x elapsedTime\n"
        f"{fill(constants, width=120)}",
        fontsize=14,
    )
    fig.savefig(path, dpi=160, bbox_inches="tight")
    plt.close(fig)


def main() -> None:
    repo_root = Path(__file__).resolve().parents[4]
    default_output = repo_root / "experiments" / "output" / "af_rent_fund_frequency_elapsed_correlation"

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--funds", type=parse_float_tuple, default=DEFAULT_FUNDS)
    parser.add_argument("--frequencies", type=parse_float_tuple, default=DEFAULT_FREQUENCIES)
    parser.add_argument("--elapsed-seconds", type=parse_float_tuple, default=DEFAULT_ELAPSED_SECONDS)
    parser.add_argument("--target-sti", type=float, default=1000.0)
    parser.add_argument("--sti-funds-buffer", type=float, default=1000.0)
    parser.add_argument("--starting-atom-sti-rent", type=float, default=1.0)
    parser.add_argument("--atom-sti", type=float, default=100.0)
    parser.add_argument("--output-prefix", type=Path, default=default_output)
    args = parser.parse_args()

    validate_examples(
        target_sti=args.target_sti,
        sti_funds_buffer=args.sti_funds_buffer,
        starting_atom_sti_rent=args.starting_atom_sti_rent,
        atom_sti=args.atom_sti,
    )

    rows = [
        rent_case(
            funds_sti=fund,
            frequency=frequency,
            elapsed_seconds=elapsed,
            target_sti=args.target_sti,
            sti_funds_buffer=args.sti_funds_buffer,
            starting_atom_sti_rent=args.starting_atom_sti_rent,
            atom_sti=args.atom_sti,
        )
        for fund in args.funds
        for frequency in args.frequencies
        for elapsed in args.elapsed_seconds
    ]

    csv_path = args.output_prefix.with_suffix(".csv")
    png_path = args.output_prefix.with_suffix(".png")
    write_csv(csv_path, rows)
    write_plot(
        png_path,
        rows,
        funds=args.funds,
        frequencies=args.frequencies,
        elapsed_seconds=args.elapsed_seconds,
        target_sti=args.target_sti,
        sti_funds_buffer=args.sti_funds_buffer,
        starting_atom_sti_rent=args.starting_atom_sti_rent,
        atom_sti=args.atom_sti,
    )

    print("Python validation examples passed")
    print(f"Wrote {csv_path}")
    print(f"Wrote {png_path}")


if __name__ == "__main__":
    main()

    