#!/usr/bin/env python3
"""Plot AFRentFrequency/elapsed-time behavior for AFRentCollectionAgent.

This mirrors the formula in AFRentCollectionAgent.metta for one AF atom with:
STI=100, FUNDS_STI=900, TARGET_STI=1000, STI_FUNDS_BUFFER=1000,
StartingAtomStiRent=1.
"""

from __future__ import annotations

import argparse
import csv
import os
from textwrap import fill
from pathlib import Path


MPL_CONFIG_DIR = Path("/tmp/metta-attention-matplotlib")
MPL_CONFIG_DIR.mkdir(parents=True, exist_ok=True)
os.environ.setdefault("MPLCONFIGDIR", str(MPL_CONFIG_DIR))

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt


DEFAULT_FREQUENCIES = (1.0, 2.0, 5.0, 10.0, 20.0, 50.0)
DEFAULT_ELAPSED_SECONDS = (0.02, 0.05, 0.10, 0.11, 0.15, 0.20, 0.25, 0.30, 0.50, 1.00)


def fmt(value: float) -> str:
    return f"{value:g}"


def calculate_sti_rent(
    starting_atom_sti_rent: float,
    funds_sti: float,
    target_sti: float,
    sti_funds_buffer: float,
) -> float:
    diff = target_sti - funds_sti
    if diff <= 0:
        return 0.0

    ndiff = diff / sti_funds_buffer
    clamped = max(min(ndiff, 1.0), -0.99)
    return starting_atom_sti_rent + (starting_atom_sti_rent * clamped)


def rent_case(
    frequency: float,
    elapsed_seconds: float,
    *,
    starting_sti: float,
    starting_funds_sti: float,
    target_sti: float,
    sti_funds_buffer: float,
    starting_atom_sti_rent: float,
) -> dict[str, float | bool]:
    threshold_seconds = 1.0 / frequency
    passes_threshold = elapsed_seconds >= threshold_seconds
    base_rent = calculate_sti_rent(
        starting_atom_sti_rent,
        starting_funds_sti,
        target_sti,
        sti_funds_buffer,
    )
    weight = elapsed_seconds * frequency if passes_threshold else 0.0
    collected = min(base_rent * weight, starting_sti) if passes_threshold else 0.0

    return {
        "AFRentFrequency": frequency,
        "elapsed_seconds": elapsed_seconds,
        "threshold_seconds": threshold_seconds,
        "passes_threshold": passes_threshold,
        "weight": weight,
        "calculated_sti_rent": base_rent,
        "sti_rent_collected": collected,
        "ending_sti": starting_sti - collected,
        "ending_FUNDS_STI": starting_funds_sti + collected,
    }


def write_csv(path: Path, rows: list[dict[str, float | bool]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = list(rows[0].keys())
    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def write_plot(
    path: Path,
    rows: list[dict[str, float | bool]],
    frequencies: tuple[float, ...],
    elapsed_seconds: tuple[float, ...],
    *,
    starting_sti: float,
    starting_funds_sti: float,
    target_sti: float,
    sti_funds_buffer: float,
    starting_atom_sti_rent: float,
) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)

    fig, (line_ax, heat_ax) = plt.subplots(1, 2, figsize=(15, 5.8), constrained_layout=True)

    base_rent = calculate_sti_rent(
        starting_atom_sti_rent,
        starting_funds_sti,
        target_sti,
        sti_funds_buffer,
    )
    constants = (
        f"fixed: atom STI={fmt(starting_sti)}, FUNDS_STI={fmt(starting_funds_sti)}, "
        f"TARGET_STI={fmt(target_sti)}, buffer={fmt(sti_funds_buffer)}, "
        f"start rent={fmt(starting_atom_sti_rent)}, base rent={fmt(base_rent)}"
    )

    for frequency in frequencies:
        series = [row for row in rows if row["AFRentFrequency"] == frequency]
        line_ax.plot(
            [float(row["elapsed_seconds"]) for row in series],
            [float(row["sti_rent_collected"]) for row in series],
            marker="o",
            linewidth=1.8,
            label=f"{frequency:g} Hz",
        )

    line_ax.set_title("Rent Collected Per AF Atom")
    line_ax.set_xlabel("Elapsed seconds")
    line_ax.set_ylabel("STI rent collected")
    line_ax.grid(True, alpha=0.25)
    line_ax.legend(title="AFRentFrequency", fontsize=8)

    heat = []
    for frequency in frequencies:
        heat.append(
            [
                float(
                    next(
                        row["sti_rent_collected"]
                        for row in rows
                        if row["AFRentFrequency"] == frequency and row["elapsed_seconds"] == elapsed
                    )
                )
                for elapsed in elapsed_seconds
            ]
        )

    image = heat_ax.imshow(heat, aspect="auto", cmap="viridis")
    heat_ax.set_title("Threshold Gate And Rent Weight")
    heat_ax.set_xlabel("Elapsed seconds")
    heat_ax.set_ylabel("AFRentFrequency")
    heat_ax.set_xticks(range(len(elapsed_seconds)), [f"{value:g}" for value in elapsed_seconds], rotation=45)
    heat_ax.set_yticks(range(len(frequencies)), [f"{value:g}" for value in frequencies])
    fig.colorbar(image, ax=heat_ax, label="STI rent collected")

    fig.suptitle(
        "AFRentCollectionAgent: elapsedTime x AFRentFrequency\n"
        f"{fill(constants, width=115)}",
        fontsize=13,
    )
    fig.savefig(path, dpi=160, bbox_inches="tight")
    plt.close(fig)


def parse_float_tuple(raw: str) -> tuple[float, ...]:
    return tuple(float(item.strip()) for item in raw.split(",") if item.strip())


def main() -> None:
    repo_root = Path(__file__).resolve().parents[4]
    default_output = repo_root / "experiments" / "output" / "af_rent_frequency_elapsed_sweep"

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--frequencies", type=parse_float_tuple, default=DEFAULT_FREQUENCIES)
    parser.add_argument("--elapsed-seconds", type=parse_float_tuple, default=DEFAULT_ELAPSED_SECONDS)
    parser.add_argument("--starting-sti", type=float, default=100.0)
    parser.add_argument("--starting-funds-sti", type=float, default=900.0)
    parser.add_argument("--target-sti", type=float, default=1000.0)
    parser.add_argument("--sti-funds-buffer", type=float, default=1000.0)
    parser.add_argument("--starting-atom-sti-rent", type=float, default=1.0)
    parser.add_argument("--output-prefix", type=Path, default=default_output)
    args = parser.parse_args()

    rows = [
        rent_case(
            frequency,
            elapsed,
            starting_sti=args.starting_sti,
            starting_funds_sti=args.starting_funds_sti,
            target_sti=args.target_sti,
            sti_funds_buffer=args.sti_funds_buffer,
            starting_atom_sti_rent=args.starting_atom_sti_rent,
        )
        for frequency in args.frequencies
        for elapsed in args.elapsed_seconds
    ]

    csv_path = args.output_prefix.with_suffix(".csv")
    png_path = args.output_prefix.with_suffix(".png")
    write_csv(csv_path, rows)
    write_plot(
        png_path,
        rows,
        args.frequencies,
        args.elapsed_seconds,
        starting_sti=args.starting_sti,
        starting_funds_sti=args.starting_funds_sti,
        target_sti=args.target_sti,
        sti_funds_buffer=args.sti_funds_buffer,
        starting_atom_sti_rent=args.starting_atom_sti_rent,
    )

    print(f"Wrote {csv_path}")
    print(f"Wrote {png_path}")


if __name__ == "__main__":
    main()
