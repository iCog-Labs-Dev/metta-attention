#!/usr/bin/env python3
"""Compare AFRentCollectionAgent rent against fund, target, buffer, and AF size.

The model follows the STI side of the MeTTa implementation:

threshold_seconds = 1 / AFRentFrequency
weight = elapsed_seconds * AFRentFrequency
base_rent = StartingAtomStiRent * (1 + clamp((TARGET_STI - FUNDS_STI) / STI_FUNDS_BUFFER, 0, 1))

If FUNDS_STI >= TARGET_STI, base_rent is zero.
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


DEFAULT_FREQUENCIES = (2.0, 5.0, 10.0, 20.0, 50.0)
DEFAULT_ELAPSED_SECONDS = (0.02, 0.05, 0.10, 0.15, 0.25, 0.50, 1.00)
DEFAULT_STARTING_FUNDS = (0.0, 250.0, 500.0, 750.0, 900.0, 990.0, 1000.0, 1100.0)
DEFAULT_TARGET_STIS = (500.0, 1000.0, 2000.0)
DEFAULT_BUFFERS = (100.0, 500.0, 1000.0, 5000.0)
DEFAULT_ATOM_COUNTS = (1, 5, 10, 20, 50, 100)


def fmt(value: float | int) -> str:
    return f"{value:g}"


def parse_float_tuple(raw: str) -> tuple[float, ...]:
    return tuple(float(item.strip()) for item in raw.split(",") if item.strip())


def parse_int_tuple(raw: str) -> tuple[int, ...]:
    return tuple(int(item.strip()) for item in raw.split(",") if item.strip())


def base_sti_rent(
    funds_sti: float,
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


def simulate_one_rent_call(
    *,
    frequency: float,
    elapsed_seconds: float,
    starting_funds_sti: float,
    target_sti: float,
    sti_funds_buffer: float,
    atom_count: int,
    atom_sti: float,
    starting_atom_sti_rent: float,
) -> dict[str, float | int | bool]:
    threshold_seconds = 1.0 / frequency
    passes_threshold = elapsed_seconds >= threshold_seconds
    weight = elapsed_seconds * frequency if passes_threshold else 0.0

    funds = starting_funds_sti
    total_collected = 0.0
    atoms_charged = 0
    first_atom_base_rent = base_sti_rent(
        funds,
        target_sti,
        sti_funds_buffer,
        starting_atom_sti_rent,
    )

    if passes_threshold:
        for _ in range(atom_count):
            rent_before_weight = base_sti_rent(
                funds,
                target_sti,
                sti_funds_buffer,
                starting_atom_sti_rent,
            )
            if rent_before_weight <= 0.0:
                break

            rent = min(atom_sti, rent_before_weight * weight)
            funds += rent
            total_collected += rent
            atoms_charged += 1

    return {
        "AFRentFrequency": frequency,
        "elapsed_seconds": elapsed_seconds,
        "threshold_seconds": threshold_seconds,
        "passes_threshold": passes_threshold,
        "weight": weight,
        "starting_FUNDS_STI": starting_funds_sti,
        "TARGET_STI": target_sti,
        "STI_FUNDS_BUFFER": sti_funds_buffer,
        "atom_count": atom_count,
        "atom_sti": atom_sti,
        "first_atom_base_rent": first_atom_base_rent,
        "total_sti_collected": total_collected,
        "avg_sti_collected_per_atom": total_collected / atom_count if atom_count else 0.0,
        "atoms_charged": atoms_charged,
        "ending_FUNDS_STI": funds,
        "target_gap_before": target_sti - starting_funds_sti,
        "target_gap_after": target_sti - funds,
    }


def write_csv(path: Path, rows: list[dict[str, float | int | bool]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)


def rows_for(
    rows: list[dict[str, float | int | bool]],
    **filters: float | int | bool,
) -> list[dict[str, float | int | bool]]:
    return [
        row
        for row in rows
        if all(row[key] == value for key, value in filters.items())
    ]


def plot_base_rent_by_fund(
    ax: plt.Axes,
    target_sti: float,
    starting_atom_sti_rent: float,
    buffers: tuple[float, ...],
) -> None:
    fund_values = [value for value in range(0, int(target_sti * 1.2) + 1, 25)]
    for buffer in buffers:
        ax.plot(
            fund_values,
            [
                base_sti_rent(fund, target_sti, buffer, starting_atom_sti_rent)
                for fund in fund_values
            ],
            label=f"buffer={buffer:g}",
            linewidth=2,
        )

    ax.axvline(target_sti, color="black", linestyle="--", linewidth=1, alpha=0.6)
    ax.set_title(
        "Fund Gap Controls Base Rent\n"
        + fill(
            f"varies: FUNDS_STI, buffer | fixed: TARGET_STI={fmt(target_sti)}, "
            f"start rent={fmt(starting_atom_sti_rent)}, timer not applied",
            width=78,
        ),
        fontsize=10,
    )
    ax.set_xlabel("FUNDS_STI")
    ax.set_ylabel("base STI rent before timer")
    ax.grid(True, alpha=0.25)
    ax.legend(fontsize=8)


def plot_atom_count_effect(
    ax: plt.Axes,
    rows: list[dict[str, float | int | bool]],
    *,
    frequency: float,
    elapsed_seconds: float,
    target_sti: float,
    buffer: float,
    starting_funds: tuple[float, ...],
    atom_counts: tuple[int, ...],
    atom_sti: float,
) -> None:
    for fund in starting_funds:
        series = [
            next(
                row
                for row in rows
                if row["AFRentFrequency"] == frequency
                and row["elapsed_seconds"] == elapsed_seconds
                and row["starting_FUNDS_STI"] == fund
                and row["TARGET_STI"] == target_sti
                and row["STI_FUNDS_BUFFER"] == buffer
                and row["atom_count"] == count
            )
            for count in atom_counts
        ]
        ax.plot(
            atom_counts,
            [float(row["total_sti_collected"]) for row in series],
            marker="o",
            label=f"fund={fund:g}",
        )

    ax.set_title(
        "Atom Count Effect\n"
        + fill(
            f"varies: AF atom count, FUNDS_STI | fixed: freq={fmt(frequency)}Hz, "
            f"elapsed={fmt(elapsed_seconds)}s, TARGET_STI={fmt(target_sti)}, "
            f"buffer={fmt(buffer)}, atom STI={fmt(atom_sti)}",
            width=78,
        ),
        fontsize=10,
    )
    ax.set_xlabel("AF atom count")
    ax.set_ylabel("total STI collected")
    ax.grid(True, alpha=0.25)
    ax.legend(fontsize=8)


def plot_timer_heatmap(
    ax: plt.Axes,
    rows: list[dict[str, float | int | bool]],
    *,
    frequencies: tuple[float, ...],
    elapsed_seconds: tuple[float, ...],
    starting_fund: float,
    target_sti: float,
    buffer: float,
    atom_count: int,
    atom_sti: float,
) -> None:
    heat = []
    for frequency in frequencies:
        heat.append(
            [
                float(
                    next(
                        row["total_sti_collected"]
                        for row in rows
                        if row["AFRentFrequency"] == frequency
                        and row["elapsed_seconds"] == elapsed
                        and row["starting_FUNDS_STI"] == starting_fund
                        and row["TARGET_STI"] == target_sti
                        and row["STI_FUNDS_BUFFER"] == buffer
                        and row["atom_count"] == atom_count
                    )
                )
                for elapsed in elapsed_seconds
            ]
        )

    image = ax.imshow(heat, aspect="auto", cmap="viridis")
    ax.set_title(
        "Timer Dominates Total Rent\n"
        + fill(
            f"varies: elapsed, freq | fixed: FUNDS_STI={fmt(starting_fund)}, "
            f"TARGET_STI={fmt(target_sti)}, buffer={fmt(buffer)}, "
            f"atoms={atom_count}, atom STI={fmt(atom_sti)}",
            width=78,
        ),
        fontsize=10,
    )
    ax.set_xlabel("elapsed seconds")
    ax.set_ylabel("AFRentFrequency")
    ax.set_xticks(range(len(elapsed_seconds)), [f"{value:g}" for value in elapsed_seconds], rotation=45)
    ax.set_yticks(range(len(frequencies)), [f"{value:g}" for value in frequencies])
    plt.colorbar(image, ax=ax, label="total STI collected")


def plot_buffer_effect(
    ax: plt.Axes,
    rows: list[dict[str, float | int | bool]],
    *,
    frequency: float,
    elapsed_seconds: float,
    target_sti: float,
    starting_fund: float,
    buffers: tuple[float, ...],
    atom_counts: tuple[int, ...],
    atom_sti: float,
) -> None:
    for buffer in buffers:
        series = [
            next(
                row
                for row in rows
                if row["AFRentFrequency"] == frequency
                and row["elapsed_seconds"] == elapsed_seconds
                and row["starting_FUNDS_STI"] == starting_fund
                and row["TARGET_STI"] == target_sti
                and row["STI_FUNDS_BUFFER"] == buffer
                and row["atom_count"] == count
            )
            for count in atom_counts
        ]
        ax.plot(
            atom_counts,
            [float(row["ending_FUNDS_STI"]) for row in series],
            marker="o",
            label=f"buffer={buffer:g}",
        )

    ax.axhline(target_sti, color="black", linestyle="--", linewidth=1, alpha=0.6)
    ax.set_title(
        "Ending Fund By Buffer\n"
        + fill(
            f"varies: buffer, AF atom count | fixed: FUNDS_STI={fmt(starting_fund)}, "
            f"TARGET_STI={fmt(target_sti)}, freq={fmt(frequency)}Hz, "
            f"elapsed={fmt(elapsed_seconds)}s, atom STI={fmt(atom_sti)}",
            width=78,
        ),
        fontsize=10,
    )
    ax.set_xlabel("AF atom count")
    ax.set_ylabel("ending FUNDS_STI")
    ax.grid(True, alpha=0.25)
    ax.legend(fontsize=8)


def write_plot(
    path: Path,
    rows: list[dict[str, float | int | bool]],
    *,
    frequencies: tuple[float, ...],
    elapsed_seconds: tuple[float, ...],
    starting_funds: tuple[float, ...],
    target_sti: float,
    buffers: tuple[float, ...],
    atom_counts: tuple[int, ...],
    atom_sti: float,
    starting_atom_sti_rent: float,
) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fig, axes = plt.subplots(2, 2, figsize=(17, 11), constrained_layout=True)

    plot_base_rent_by_fund(axes[0][0], target_sti, starting_atom_sti_rent, buffers)
    plot_atom_count_effect(
        axes[0][1],
        rows,
        frequency=10.0,
        elapsed_seconds=0.25,
        target_sti=target_sti,
        buffer=1000.0,
        starting_funds=tuple(fund for fund in (0.0, 500.0, 900.0, 990.0) if fund in starting_funds),
        atom_counts=atom_counts,
        atom_sti=atom_sti,
    )
    plot_timer_heatmap(
        axes[1][0],
        rows,
        frequencies=frequencies,
        elapsed_seconds=elapsed_seconds,
        starting_fund=900.0,
        target_sti=target_sti,
        buffer=1000.0,
        atom_count=20,
        atom_sti=atom_sti,
    )
    plot_buffer_effect(
        axes[1][1],
        rows,
        frequency=10.0,
        elapsed_seconds=0.25,
        target_sti=target_sti,
        starting_fund=900.0,
        buffers=buffers,
        atom_counts=atom_counts,
        atom_sti=atom_sti,
    )

    fig.suptitle(
        "AFRentCollectionAgent Fund Sensitivity\n"
        f"plot target={fmt(target_sti)}, start rent={fmt(starting_atom_sti_rent)}",
        fontsize=14,
    )
    fig.savefig(path, dpi=160, bbox_inches="tight")
    plt.close(fig)


def main() -> None:
    repo_root = Path(__file__).resolve().parents[4]
    default_output = repo_root / "experiments" / "output" / "af_rent_fund_sensitivity"

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--frequencies", type=parse_float_tuple, default=DEFAULT_FREQUENCIES)
    parser.add_argument("--elapsed-seconds", type=parse_float_tuple, default=DEFAULT_ELAPSED_SECONDS)
    parser.add_argument("--starting-funds", type=parse_float_tuple, default=DEFAULT_STARTING_FUNDS)
    parser.add_argument("--target-stis", type=parse_float_tuple, default=DEFAULT_TARGET_STIS)
    parser.add_argument("--plot-target-sti", type=float, default=1000.0)
    parser.add_argument("--buffers", type=parse_float_tuple, default=DEFAULT_BUFFERS)
    parser.add_argument("--atom-counts", type=parse_int_tuple, default=DEFAULT_ATOM_COUNTS)
    parser.add_argument("--atom-sti", type=float, default=100.0)
    parser.add_argument("--starting-atom-sti-rent", type=float, default=1.0)
    parser.add_argument("--output-prefix", type=Path, default=default_output)
    args = parser.parse_args()

    rows = [
        simulate_one_rent_call(
            frequency=frequency,
            elapsed_seconds=elapsed,
            starting_funds_sti=fund,
            target_sti=target_sti,
            sti_funds_buffer=buffer,
            atom_count=count,
            atom_sti=args.atom_sti,
            starting_atom_sti_rent=args.starting_atom_sti_rent,
        )
        for frequency in args.frequencies
        for elapsed in args.elapsed_seconds
        for fund in args.starting_funds
        for target_sti in args.target_stis
        for buffer in args.buffers
        for count in args.atom_counts
    ]

    csv_path = args.output_prefix.with_suffix(".csv")
    png_path = args.output_prefix.with_suffix(".png")
    write_csv(csv_path, rows)
    write_plot(
        png_path,
        rows,
        frequencies=args.frequencies,
        elapsed_seconds=args.elapsed_seconds,
        starting_funds=args.starting_funds,
        target_sti=args.plot_target_sti,
        buffers=args.buffers,
        atom_counts=args.atom_counts,
        atom_sti=args.atom_sti,
        starting_atom_sti_rent=args.starting_atom_sti_rent,
    )

    print(f"Wrote {csv_path}")
    print(f"Wrote {png_path}")


if __name__ == "__main__":
    main()
