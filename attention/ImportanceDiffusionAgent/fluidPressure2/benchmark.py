"""
Benchmark: fluidDiffusion  vs  fluidPressure2  vs  FP2+FD-kernel

Three systems on the same inputs lets you isolate *what* drives quality:
  FD               Fourier-mode transport, FD scatter/gather
  FP2              Navier-Stokes + HJB,    FP2 native kernel
  FP2+FD-kernel    Navier-Stokes + HJB,    FD-style scatter/gather
                    (same NS physics as FP2 but FD embedding/push/pull)

If FP2 ≈ FP2+FD-kernel  → the NS/HJB physics drives quality, not the kernel.
If FP2 >> FP2+FD-kernel → the native kernel's partition-of-unity matters.

Usage (from repo root):
    python -m attention.ImportanceDiffusionAgent.fluidPressure2.benchmark
    python -m attention.ImportanceDiffusionAgent.fluidPressure2.benchmark --repeats 3
    python -m attention.ImportanceDiffusionAgent.fluidPressure2.benchmark --goals aphid beetle moth

Flags:
    --graph     PATH        override graph file   (default: adagram.metta)
    --goals     ATOM ...    goal atoms
    --repeats   N           runs per system; report mean ± σ  (default 1)
    --fd-grid   INT         FD grid size          (default 36)
    --fp2-grid  INT         FP2 / FP2+FD grid size (default 64)
"""
from __future__ import annotations

import os, sys, time, tracemalloc, argparse
from pathlib import Path
from typing import Any

import numpy as np

# path setup
_HERE   = Path(__file__).resolve().parent                   # fluidPressure2/
_REPO   = _HERE.parent.parent.parent                        # metta-attention/
_FD_DIR = _HERE.parent / "fluidDiffusion"

if str(_FD_DIR) not in sys.path:
    sys.path.insert(0, str(_FD_DIR))

_DEFAULT_GRAPH = str(_REPO / "experiments" / "data" / "adagram.metta")

# fluidDiffusion imports
from graph     import parse_metta_edges as fd_parse, extract_atoms as fd_atoms
from graph     import build_adjacency_matrix as fd_adj
from graph     import get_spectral_coordinates_magnetic as fd_embed
from density   import push_sti_to_density, pull_density_to_sti
from transport import precompute_fourier_velocity_modes, transport_density
from params    import FluidParams

# fluidPressure2 imports
from .graph    import parse_metta_edges as fp2_parse, extract_atoms as fp2_atoms
from .graph    import build_adjacency_matrix as fp2_adj
from .graph    import get_magnetic_coordinates as fp2_embed
from .kernel   import kernel_matrix, push_sti, pull_sti, positions_to_grid
from .pipeline import run_cycle
from .params   import FluidPressure2Params

# FD-kernel adapter
from .fd_kernel_adapter import (
    fd_get_magnetic_coordinates,
    fd_positions_to_grid,
    fd_kernel_matrix,
    fd_push_sti,
    fd_pull_sti,
)


class _T:
    def __init__(self, d: dict, k: str): self._d, self._k = d, k
    def __enter__(self):  self._s = time.perf_counter()
    def __exit__(self, *_): self._d[self._k] = time.perf_counter() - self._s

def _mem_start():
    tracemalloc.stop(); tracemalloc.clear_traces(); tracemalloc.start()

def _mem_stop() -> float:
    _, peak = tracemalloc.get_traced_memory(); tracemalloc.stop(); return peak / 1e6

def _rank(vals: list[float]) -> np.ndarray:
    a = np.argsort(vals); r = np.empty(len(vals), float); r[a] = np.arange(1, len(vals)+1)
    return r


def _quality(new_sti: dict, goals: list[str], orig_sti: dict) -> dict:
    total  = sum(new_sti.values()) or 1.0
    g_sum  = sum(new_sti.get(g, 0.0) for g in goals)
    vals   = sorted(new_sti.values())
    n, s   = len(vals), sum(vals) or 1.0

    gini = (2*sum((i+1)*v for i,v in enumerate(vals))/(n*s) - (n+1)/n) if n else 0.0

    p = np.array(vals, float) / s; p = p[p > 0]
    entropy = float(-np.sum(p * np.log2(p))) if len(p) else 0.0

    shared = sorted(set(orig_sti) & set(new_sti))
    rs: float = float("nan")
    if len(shared) >= 3:
        d2 = float(np.sum((_rank([orig_sti[k] for k in shared])
                          - _rank([new_sti[k]  for k in shared])) ** 2))
        nn = len(shared)
        rs = 1.0 - 6.0*d2 / (nn*(nn*nn-1))

    starved = 100.0 * sum(1 for v in new_sti.values() if v <= 0) / max(n, 1)

    return {
        "goal_share_%":  100.0 * g_sum / total,
        "gini":          gini,
        "entropy_bits":  entropy,
        "rank_corr":     rs,
        "starvation_%":  starved,
        "mass_error":    abs(total - sum(orig_sti.values())),
    }


def _bench_fd(graph: str, sti: dict, goals: list[str], p: FluidParams) -> dict:
    """fluidDiffusion: Fourier-mode transport with FD scatter/gather."""
    t: dict[str, float] = {}
    _mem_start()

    with _T(t, "embed"):
        edges = fd_parse(graph); nodes = fd_atoms(edges)
        mat, _ = fd_adj(edges, nodes)
        coords = fd_embed(mat, nodes)

    with _T(t, "modes"):
        modes = precompute_fourier_velocity_modes(p.grid_size, p.k_max)

    with _T(t, "push"):
        rho0, _ = push_sti_to_density(edges, nodes, p, sti, spectral_coords=coords)

    with _T(t, "transport"):
        rho1, (ux, uy), diag, _ = transport_density(
            rho0, p, af_seeds=goals, track_history=False,
            modes=modes, spectral_coords=coords,
        )

    with _T(t, "pull"):
        new_sti = pull_density_to_sti(
            rho1, coords, p, sum(v for v in sti.values() if v > 0)
        )

    return dict(times=t, total_s=sum(t.values()), peak_mb=_mem_stop(),
                diag=diag, new_sti=new_sti, lti_used=False,
                label="fluidDiffusion")


def _bench_fp2(graph: str, sti: dict, lti: dict, goals: list[str],
               p: FluidPressure2Params) -> dict:
    """fluidPressure2: Navier-Stokes + HJB with FP2 native kernel."""
    t: dict[str, float] = {}
    _mem_start()

    with _T(t, "embed"):
        edges = fp2_parse(graph); nodes = fp2_atoms(edges)
        mat   = fp2_adj(edges, nodes)
        coords = fp2_embed(mat, nodes)

    with _T(t, "kernel"):
        names, K = kernel_matrix(coords, p)

    with _T(t, "push"):
        rho0    = push_sti(sti, names, K, p.grid_size)
        lti_rho = push_sti(lti, names, K, p.grid_size)

    with _T(t, "goals"):
        pos    = positions_to_grid(coords, p.grid_size)
        gcells = [pos[g] for g in goals if g in pos]

    with _T(t, "run_cycle"):
        rho1, _, _, diag = run_cycle(rho0, lti_rho, gcells, p)

    with _T(t, "pull"):
        new_sti = pull_sti(rho1, names, K)

    return dict(times=t, total_s=sum(t.values()), peak_mb=_mem_stop(),
                diag=diag, new_sti=new_sti, lti_used=any(v > 0 for v in lti.values()),
                label="FP2")


def _bench_fp2_fd_kernel(graph: str, sti: dict, lti: dict, goals: list[str],
                          p: FluidPressure2Params) -> dict:
    t: dict[str, float] = {}
    _mem_start()

    with _T(t, "embed"):
        # Use FD's unnormalized magnetic Laplacian for the embedding
        edges = fd_parse(graph); nodes = fd_atoms(edges)
        mat, _ = fd_adj(edges, nodes)
        coords = fd_get_magnetic_coordinates(mat, nodes)   # FD-style coords

    with _T(t, "kernel"):
        names, K_raw = fd_kernel_matrix(coords, p)         # FD 7×7 truncated kernel

    with _T(t, "push"):
        rho0    = fd_push_sti(sti, names, K_raw, p.grid_size)
        lti_rho = fd_push_sti(lti, names, K_raw, p.grid_size)

    with _T(t, "goals"):
        pos    = fd_positions_to_grid(coords, p.grid_size)  # FD rank-based grid map
        gcells = [pos[g] for g in goals if g in pos]

    with _T(t, "run_cycle"):
        rho1, _, _, diag = run_cycle(rho0, lti_rho, gcells, p)

    with _T(t, "pull"):
        total_sti = sum(v for v in sti.values() if v > 0)
        new_sti = fd_pull_sti(rho1, names, coords, p, total_sti)

    return dict(times=t, total_s=sum(t.values()), peak_mb=_mem_stop(),
                diag=diag, new_sti=new_sti, lti_used=any(v > 0 for v in lti.values()),
                label="FP2+FD-kernel")



def _agg(runs: list[dict]) -> dict:
    last = runs[-1]
    if len(runs) == 1:
        return last
    all_stages = sorted(set().union(*(r["times"] for r in runs)))
    stats: dict[str, tuple[float, float]] = {}
    for s in all_stages:
        v = [r["times"].get(s, 0.0) for r in runs]
        stats[s] = (float(np.mean(v)), float(np.std(v)))
    totals = [r["total_s"] for r in runs]
    last["time_stats"] = stats
    last["total_mean"] = float(np.mean(totals))
    last["total_std"]  = float(np.std(totals))
    return last



def _print_report(fd: dict, fp2: dict, fp2fd: dict,
                  goals: list[str], repeats: int) -> None:
    W = 16   # column width

    def _f(v, prec=4):
        if v is None or (isinstance(v, float) and np.isnan(v)):
            return f"{'N/A':>{W}}"
        return f"{v:>{W}.{prec}f}"

    def _row(label, a, b, c):
        print(f"  {label:<24}  {_f(a)}  {_f(b)}  {_f(c)}")

    def _time_row(label, sys_a, sys_b, sys_c, stage, repeats):
        def _ts(sys, s):
            if repeats > 1 and "time_stats" in sys:
                m, sd = sys["time_stats"].get(s, (sys["times"].get(s,0.), 0.))
                return f"{m:>7.4f}±{sd:.4f}"
            v = sys["times"].get(s, 0.)
            return f"{v:>{W}.4f}s"
        print(f"  {label:<24}  {_ts(sys_a,stage):>{W}}  {_ts(sys_b,stage):>{W}}  {_ts(sys_c,stage):>{W}}")

    HDR = f"  {'Metric':<24}  {'fluidDiffusion':>{W}}  {'FP2':>{W}}  {'FP2+FD-kernel':>{W}}"
    SEP = "=" * (len(HDR) + 2)

    print("\n" + SEP)
    print(HDR)
    print(SEP)

    # LTI notice
    if fp2["lti_used"]:
        print(
            "  NOTE  FP2 and FP2+FD-kernel use LTI-modulated viscosity.\n"
            "        FD ignores LTI.  goal_share/concentration not symmetric."
        )
        print("-" * len(SEP))

    # timing
    all_stages = sorted(set(fd["times"]) | set(fp2["times"]) | set(fp2fd["times"]))
    for s in all_stages:
        _time_row(f"time/{s}", fd, fp2, fp2fd, s, repeats)

    # TOTAL row
    if repeats > 1:
        def _tot(sys):
            return f"{sys.get('total_mean', sys['total_s']):>7.4f}±{sys.get('total_std', 0.):.4f}"
        print(f"  {'time/TOTAL':<24}  {_tot(fd):>{W}}  {_tot(fp2):>{W}}  {_tot(fp2fd):>{W}}")
    else:
        _row("time/TOTAL", fd["total_s"], fp2["total_s"], fp2fd["total_s"])

    print(f"  {'memory_peak_MB':<24}  {_f(fd['peak_mb'],2)}  {_f(fp2['peak_mb'],2)}  {_f(fp2fd['peak_mb'],2)}")

    # quality
    print("-" * len(SEP))
    for k in ["goal_share_%", "gini", "entropy_bits", "rank_corr", "starvation_%", "mass_error"]:
        _row(k, fd["quality"].get(k), fp2["quality"].get(k), fp2fd["quality"].get(k))

    # shared diagnostics
    print("-" * len(SEP))
    for k in ["mass_error", "max_abs_divergence", "goal_mass",
              "expected_distance", "l2_divergence"]:
        a = fd["diag"].get(k);  b = fp2["diag"].get(k);  c = fp2fd["diag"].get(k)
        if any(x is not None for x in (a, b, c)):
            def _ds(v):
                return f"{v:.4e}" if isinstance(v, float) else "N/A"
            print(f"  diag/{k:<20}  {_ds(a):>{W}}  {_ds(b):>{W}}  {_ds(c):>{W}}")

    # FP2-exclusive diagnostics
    fp2_keys = [k for k in ("pressure_rms", "pressure_max", "enstrophy")
                if k in fp2["diag"] or k in fp2fd["diag"]]
    if fp2_keys:
        print("-" * len(SEP))
        print("  [FP2-only diagnostics]")
        for k in fp2_keys:
            b = fp2["diag"].get(k);  c = fp2fd["diag"].get(k)
            def _ds(v): return f"{v:.4e}" if isinstance(v, float) else "N/A"
            print(f"  diag/{k:<20}  {'N/A':>{W}}  {_ds(b):>{W}}  {_ds(c):>{W}}")

    # per-goal STI
    print("-" * len(SEP))
    print(f"  {'goal atom STI':<24}  {'FD':>{W}}  {'FP2':>{W}}  {'FP2+FD-kernel':>{W}}")
    for g in goals:
        a = fd["new_sti"].get(g, 0.0)
        b = fp2["new_sti"].get(g, 0.0)
        c = fp2fd["new_sti"].get(g, 0.0)
        print(f"    {g:<22}  {a:>{W}.2f}  {b:>{W}.2f}  {c:>{W}.2f}")

    # top-5 atoms
    print("-" * len(SEP))
    print("  Top-5 atoms by final STI:")
    for label, sti_map in [("FD", fd["new_sti"]),
                            ("FP2", fp2["new_sti"]),
                            ("FP2+FD-kernel", fp2fd["new_sti"])]:
        top5 = sorted(sti_map.items(), key=lambda x: x[1], reverse=True)[:5]
        print(f"    {label}: " + ", ".join(f"{n}({v:.0f})" for n, v in top5))

    print(SEP)

    # interpretation guide 
    print("\n  INTERPRETATION GUIDE")
    print("  If FP2 ≈ FP2+FD-kernel : NS/HJB physics drives goal routing, kernel is secondary")
    print("  If FP2 >> FP2+FD-kernel : FP2's partition-of-unity kernel matters")
    print("  goal_share_%   higher → attention concentrated at goal atoms")
    print("  gini           0=uniform, 1=all mass on one atom")
    print("  entropy_bits   higher=spread, lower=focused")
    print("  rank_corr      ~1=preserves importance order; ~0=significant reranking")
    print("  starvation_%   % atoms at zero — keep low for healthy ECAN")
    print("  mass_error     should be ~0; large = STI conservation bug")
    print("  goal_mass      absolute STI delivered to goal cells — key routing signal")
    print("  pressure_rms   HJB driving force — higher = stronger goal-directed flow")
    print("  enstrophy      vorticity intensity — high = turbulent, less directed flow")


def run_benchmark(
    graph_path  : str                    = _DEFAULT_GRAPH,
    sti         : dict[str, float]      | None = None,
    lti         : dict[str, float]      | None = None,
    goals       : list[str]             | None = None,
    params_fd   : FluidParams           | None = None,
    params_fp2  : FluidPressure2Params  | None = None,
    repeats     : int = 1,
) -> dict[str, Any]:

    params_fd  = params_fd  or FluidParams()
    params_fp2 = params_fp2 or FluidPressure2Params(grid_size=64)

    if sti is None:
        edges = fd_parse(graph_path); nodes = fd_atoms(edges)
        rng   = np.random.default_rng(42)
        sti   = {n: float(rng.uniform(100, 900)) for n in nodes}
        lti   = {n: float(rng.uniform(0,   500)) for n in nodes}
    lti = lti or {}

    if not goals:
        goals = [k for k, _ in sorted(sti.items(), key=lambda x: x[1], reverse=True)[:3]]

    fd_runs, fp2_runs, fp2fd_runs = [], [], []
    for _ in range(repeats):
        fd_runs.append(   _bench_fd(         graph_path, sti,      goals, params_fd))
        fp2_runs.append(  _bench_fp2(        graph_path, sti, lti, goals, params_fp2))
        fp2fd_runs.append(_bench_fp2_fd_kernel(graph_path, sti, lti, goals, params_fp2))

    fd    = _agg(fd_runs)
    fp2   = _agg(fp2_runs)
    fp2fd = _agg(fp2fd_runs)

    for r, label in [(fd, "fd"), (fp2, "fp2"), (fp2fd, "fp2fd")]:
        r["quality"] = _quality(r["new_sti"], goals, sti)

    _print_report(fd, fp2, fp2fd, goals, repeats)
    return {"fd": fd, "fp2": fp2, "fp2_fd_kernel": fp2fd, "goals": goals}


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--graph",    default=_DEFAULT_GRAPH)
    ap.add_argument("--goals",    nargs="+", default=None)
    ap.add_argument("--repeats",  type=int,  default=1)
    ap.add_argument("--fd-grid",  type=int,  default=36)
    ap.add_argument("--fp2-grid", type=int,  default=64)
    args = ap.parse_args()

    run_benchmark(
        graph_path = args.graph,
        goals      = args.goals,
        params_fd  = FluidParams(grid_size=args.fd_grid),
        params_fp2 = FluidPressure2Params(grid_size=args.fp2_grid),
        repeats    = args.repeats,
    )
