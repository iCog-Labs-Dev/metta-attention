from __future__ import annotations

import io
import os

import matplotlib

matplotlib.use("Agg")
import matplotlib.patheffects
import matplotlib.pyplot as plt
import numpy as np
from PIL import Image

from graph import spectral_to_grid_coords


SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
GIF_OUTPUT = os.path.join(SCRIPT_DIR, "fluid_animation.gif")


def _resolve_output_path(path: str, overwrite: bool) -> str:
    if overwrite:
        return path
    base, ext = os.path.splitext(path)
    i = 1
    while os.path.exists(f"{base}_{i}{ext}"):
        i += 1
    return f"{base}_{i}{ext}"


def render_animation(
    history: list[np.ndarray],
    grid_size: int,
    spectral_coords: dict[str, tuple[float, float]],
    output_path: str = GIF_OUTPUT,
    frame_step: int = 1,
    fps: int = 10,
    sti_values: dict[str, float] | None = None,
    overwrite: bool = True,
    goal_cells: list[tuple[int, int]] | None = None,
) -> None:
    frames: list[Image.Image] = []
    positions = spectral_to_grid_coords(spectral_coords, grid_size)
    total_steps = len(history)
    resolved = _resolve_output_path(output_path, overwrite)

    for idx in range(0, total_steps, frame_step):
        rho = history[idx]

        fig, ax = plt.subplots(figsize=(8, 8))
        im = ax.imshow(rho, cmap="turbo", origin="lower")
        ax.set_title(f"Fluid Transport — step {idx} / {total_steps}")
        ax.set_xlabel("grid x")
        ax.set_ylabel("grid y")
        plt.colorbar(im, ax=ax, shrink=0.8, label="density")

        for atom, (gx, gy) in positions.items():
            weight = sti_values.get(atom, 0) if sti_values else 1
            size = max(6, min(14, weight * 0.5))
            ax.plot(
                gx,
                gy,
                "o",
                color="white",
                markersize=size * 0.6,
                markerfacecolor="none",
                markeredgewidth=0.5,
            )
            ax.text(
                gx,
                gy,
                atom,
                color="white",
                fontsize=5,
                ha="center",
                va="center",
                path_effects=[
                    matplotlib.patheffects.withStroke(linewidth=0.8, foreground="black")
                ],
            )

        if goal_cells:
            for gy, gx in goal_cells:
                ax.plot(gx, gy, "X", color="cyan", markersize=10, markeredgewidth=2)

        buf = io.BytesIO()
        fig.savefig(buf, format="png", dpi=100, bbox_inches="tight")
        plt.close(fig)
        buf.seek(0)
        frames.append(Image.open(buf))

    if frames:
        duration = int(1000 / fps)
        frames[0].save(
            resolved,
            save_all=True,
            append_images=frames[1:],
            loop=0,
            duration=duration,
        )
        print(f"Animation saved to {resolved}")
    else:
        print("No frames to animate.")
