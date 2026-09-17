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
    
    # Pre-extract coordinate arrays for fast scatter plotting
    atoms = list(positions.keys())
    x_coords = [positions[a][0] for a in atoms]
    y_coords = [positions[a][1] for a in atoms]
    
    if sti_values:
        weights = [sti_values.get(a, 0) for a in atoms]
    else:
        weights = [1] * len(atoms)
        
    sizes = [max(6, min(14, w * 0.5)) * 0.6 for w in weights]
    
    # Identify top nodes to render  (mathplot lib crashes for concept net)
    MAX_NODES_TO_RENDER = 2000
    if len(atoms) > MAX_NODES_TO_RENDER:
        render_indices = sorted(range(len(weights)), key=lambda i: weights[i], reverse=True)[:MAX_NODES_TO_RENDER]
    else:
        render_indices = list(range(len(atoms)))
        
    x_coords_render = [x_coords[i] for i in render_indices]
    y_coords_render = [y_coords[i] for i in render_indices]
    sizes_render = [sizes[i] for i in render_indices]
    
    # Identify top nodes to label so it's not a cluttered mess (nodes with 0 weight are not labeled unless they are seeds)
    top_label_indices = sorted(range(len(weights)), key=lambda i: weights[i], reverse=True)[:30]
    top_label_indices = [i for i in top_label_indices if weights[i] > 0] # only label if they have some STI

    for idx in range(0, total_steps, frame_step):
        rho = history[idx]

        fig, ax = plt.subplots(figsize=(8, 8))
        im = ax.imshow(rho, cmap="turbo", origin="lower")
        ax.set_title(f"Fluid Transport — step {idx} / {total_steps}")
        ax.set_xlabel("grid x")
        ax.set_ylabel("grid y")
        plt.colorbar(im, ax=ax, shrink=0.8, label="density")

        # Vectorized scatter plot for the top salient nodes (extremely fast)
        ax.scatter(x_coords_render, y_coords_render, s=sizes_render, facecolors="none", edgecolors="white", linewidths=0.5)

        for i in top_label_indices:
            ax.text(
                x_coords[i],
                y_coords[i],
                atoms[i],
                color="white",
                fontsize=7,
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
