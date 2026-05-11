import re
import argparse
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
MATPLOTLIB_AVAILABLE = True

grid_size = 36
N = grid_size * grid_size

STATIC_STI = {
    'diazinon': 747,
    'alachlor': 131,
    'bactericide': 187,
    'beanleafrollers': 178,
    'dicofol': 178,
    'beanleafroller': 157,
    'caterpillar': 107,
    'dilan': 117,
    'borer': 121,
    'caterpillars': 121,
}

DEFAULT_STI = 100


def normalize_sti(sti_dict):
    """Normalize STI values to sum to 1.0."""
    total = sum(sti_dict.values())
    if total == 0:
        return sti_dict
    return {k: v/total for k, v in sti_dict.items()}


def parse_metta(filepath):
    pattern = r"\(\(\w+ (\w+) (\w+)\) \((\S+) (\S+)\)\)"
    with open(filepath) as f:
        content = f.read()

    matches = re.findall(pattern, content)
    edges = [(m[0], m[1], float(m[2]), float(m[3])) for m in matches]
    return edges


def build_adjacency_matrix(edges, make_symmetric=True):
    nodes = sorted(set([e[0] for e in edges] + [e[1] for e in edges]))
    node_to_idx = {n: i for i, n in enumerate(nodes)}
    n = len(nodes)

    matrix = [[0.0] * n for _ in range(n)]
    for src, dst, s1, s2 in edges:
        i, j = node_to_idx[src], node_to_idx[dst]
        matrix[i][j] = s1
        if make_symmetric:
            existing = matrix[j][i]
            matrix[j][i] = (s1 + existing) / 2

    return np.array(matrix, dtype=np.float64), nodes, node_to_idx


def get_spectral_coordinates_fft(matrix, nodes):
    """Get spectral coordinates using eigendecomposition for better spread."""
    A = matrix
    n = len(nodes)
    
    try:
        eigenvalues, eigenvectors = np.linalg.eig(A)
        
        eigenvalues = np.real(eigenvalues)
        eigenvectors = np.real(eigenvectors)
        
        idx = np.argsort(np.abs(eigenvalues))[::-1]
        
        if len(idx) >= 3:
            psi2 = eigenvectors[:, idx[1]]
            psi3 = eigenvectors[:, idx[2]]
        else:
            psi2 = np.zeros(n)
            psi3 = np.zeros(n)
    except Exception:
        psi2 = np.linspace(0, 2*np.pi, n)
        psi3 = np.linspace(0, 2*np.pi, n)
    
    coords = {}
    for i, node in enumerate(nodes):
        x = float(psi2[i]) if i < len(psi2) else 0.0
        y = float(psi3[i]) if i < len(psi3) else 0.0
        
        coords[node] = (float(x), float(y))
    
    return coords


def map_density_to_atoms(rho, spectral_coords, grid_size, radius=2):
    """Aggregates density in a local neighborhood for more robust node weights."""
    discrete_weights = {}
    
    coord_arr = np.array(list(spectral_coords.values()))
    if len(coord_arr) == 0:
        return discrete_weights
    
    coord_min = coord_arr.min()
    coord_max = coord_arr.max()
    coord_range = coord_max - coord_min + 1e-10
    
    for node, (x, y) in spectral_coords.items():
        gx = int(((x - coord_min) / coord_range) * grid_size) % grid_size
        gy = int(((y - coord_min) / coord_range) * grid_size) % grid_size
        
        local_density = 0.0
        for dy in range(-radius, radius + 1):
            for dx in range(-radius, radius + 1):
                px = (gx + dx) % grid_size
                py = (gy + dy) % grid_size
                local_density += rho[py, px]
        
        discrete_weights[node] = local_density
    
    return discrete_weights


def print_atom_mapping(spectral_coords, sti_values, node_densities, grid_size, radius=2):
    """Print detailed mapping of all atoms to manifold regions."""
    if not spectral_coords:
        print("No spectral coordinates available")
        return
    
    coords_arr = np.array(list(spectral_coords.values()))
    coord_min = coords_arr.min()
    coord_max = coords_arr.max()
    coord_range = coord_max - coord_min + 1e-10
    
    print("\n" + "="*80)
    print(f"{'Atom':<25} {'Grid':<10} {'Eigenvector':<25} {'Initial STI':<12} {'Final Density'}")
    print("="*80)
    
    for node in sorted(spectral_coords.keys()):
        x, y = spectral_coords[node]
        
        gx = int(((x - coord_min) / coord_range) * grid_size) % grid_size
        gy = int(((y - coord_min) / coord_range) * grid_size) % grid_size
        
        initial_sti = sti_values.get(node, DEFAULT_STI) if sti_values else DEFAULT_STI
        final_density = node_densities.get(node, 0.0)
        
        print(f"{node:<25} ({gx:2d},{gy:2d})    ({x:>10.4f}, {y:>10.4f})    {initial_sti:<12} {final_density:.6f}")
    
    print("="*80)


def nodes_to_distributed_mass(edges, nodes, grid_size=36, spread_sigma=1.0, sti_values=None):
    """Map nodes to rho field via spectral embedding + Gaussian spread."""
    matrix, nodes_list, node_to_idx = build_adjacency_matrix(edges)
    
    spectral_coords = get_spectral_coordinates_fft(matrix, nodes_list)
    
    if sti_values:
        node_sti = sti_values
    else:
        node_sti = {}
        for node in nodes_list:
            idx = node_to_idx.get(node, 0)
            weight = np.mean(matrix[idx, :]) if idx < len(matrix) else DEFAULT_STI
            node_sti[node] = weight
    
    if not spectral_coords:
        rho = np.zeros((grid_size, grid_size))
        return rho, spectral_coords, nodes_list, node_to_idx
    
    coord_arr = np.array(list(spectral_coords.values()))
    coord_min = coord_arr.min()
    coord_max = coord_arr.max()
    coord_range = coord_max - coord_min + 1e-10
    
    rho = np.zeros((grid_size, grid_size))
    
    for node, (x, y) in spectral_coords.items():
        gx = int(((x - coord_min) / coord_range) * grid_size) % grid_size
        gy = int(((y - coord_min) / coord_range) * grid_size) % grid_size
        
        weight = node_sti.get(node, DEFAULT_STI)
        
        for dy in range(-3, 4):
            for dx in range(-3, 4):
                dist_sq = dx * dx + dy * dy
                if dist_sq <= spread_sigma * spread_sigma * 9:
                    gauss = np.exp(-dist_sq / (2 * spread_sigma**2))
                    px = (gx + dx) % grid_size
                    py = (gy + dy) % grid_size
                    rho[py, px] += weight * gauss
    
    rho = rho / (np.sum(rho) + 1e-10)
    
    return rho, spectral_coords, nodes_list, node_to_idx


def get_center_seed(grid_size, n_seeds=4):
    """Get center of grid as seed(s)."""
    cx, cy = grid_size // 2, grid_size // 2
    if n_seeds == 1:
        return [(cy, cx)]
    offsets = [(0, 0), (-4, 0), (4, 0), (0, -4), (0, 4)][:n_seeds]
    return [(cy + dy, cx + dx) for dy, dx in offsets]


def compute_torus_distance(grid_size):
    """Precompute torus distance factor."""
    freqs = np.fft.fftfreq(grid_size)
    kx, ky = np.meshgrid(freqs, freqs)
    laplacian_op = -4 * (np.sin(np.pi * kx)**2 + np.sin(np.pi * ky)**2)
    laplacian_op[0, 0] = 1.0
    return laplacian_op


def run_fluid_simulation(rho_initial, af_seeds=None, num_steps=100, dt=0.1, viscosity=None, 
                       grid_size=36, track_history=False, target_cfl=0.8):
    """Run Navier-Stokes on torus T² grid."""
    
    if af_seeds is None:
        af_seeds = get_center_seed(grid_size, n_seeds=4)
    elif isinstance(af_seeds, str):
        if af_seeds.lower() == "center":
            af_seeds = get_center_seed(grid_size, n_seeds=1)
        else:
            af_seeds = [tuple(map(int, s.split(','))) for s in af_seeds.split()]
    
    print(f"advecting to seeds {af_seeds}")
    rho = rho_initial.copy()
    rho_history = [] if track_history else None
    
    if viscosity is None:
        viscosity = np.full((grid_size, grid_size), 0.9)
    
    laplacian_op = compute_torus_distance(grid_size)
    
    u_x = np.zeros((grid_size, grid_size))
    u_y = np.zeros((grid_size, grid_size))
    
    for t in range(num_steps):
        if t % 1 == 0 and len(af_seeds) > 0:
            D = np.full((grid_size, grid_size), np.inf)
            y_coords, x_coords = np.mgrid[0:grid_size, 0:grid_size]
            
            for seed_y, seed_x in af_seeds:
                dy = np.abs(seed_y - y_coords)
                dy = np.minimum(dy, grid_size - dy)
                dx = np.abs(seed_x - x_coords)
                dx = np.minimum(dx, grid_size - dx)
                D = np.minimum(D, np.sqrt(dy**2 + dx**2))
            
            grad_D_y = (np.roll(D, -1, axis=0) - np.roll(D, 1, axis=0)) / 2.0
            grad_D_x = (np.roll(D, -1, axis=1) - np.roll(D, 1, axis=1)) / 2.0
            
            raw_v_y = -rho * grad_D_y
            raw_v_x = -rho * grad_D_x
            
            div_raw = (raw_v_y - np.roll(raw_v_y, 1, axis=0)) + (raw_v_x - np.roll(raw_v_x, 1, axis=1))
            div_raw_fft = np.fft.fft2(div_raw)
            p_fft = div_raw_fft / laplacian_op
            p = np.real(np.fft.ifft2(p_fft))
            
            f_v_y = raw_v_y - (np.roll(p, -1, axis=0) - p)
            f_v_x = raw_v_x - (np.roll(p, -1, axis=1) - p)
            
            force_mag = np.max(np.sqrt(f_v_x**2 + f_v_y**2))
            if force_mag > 0:
                f_v_x /= force_mag
                f_v_y /= force_mag
        else:
            f_v_x = np.zeros((grid_size, grid_size))
            f_v_y = np.zeros((grid_size, grid_size))
        
        lap_u_x = np.roll(u_x, 1, axis=1) + np.roll(u_x, -1, axis=1) + \
                  np.roll(u_x, 1, axis=0) + np.roll(u_x, -1, axis=0) - 4 * u_x
        lap_u_y = np.roll(u_y, 1, axis=1) + np.roll(u_y, -1, axis=1) + \
                  np.roll(u_y, 1, axis=0) + np.roll(u_y, -1, axis=0) - 4 * u_y
        
        u_x_star = u_x + dt * (f_v_x + viscosity * lap_u_x)
        u_y_star = u_y + dt * (f_v_y + viscosity * lap_u_y)
        
        div_u = (u_y_star - np.roll(u_y_star, 1, axis=0)) + (u_x_star - np.roll(u_x_star, 1, axis=1))
        div_u_fft = np.fft.fft2(div_u)
        p_u_fft = div_u_fft / laplacian_op
        p_u = np.real(np.fft.ifft2(p_u_fft))
        u_y = u_y_star - (np.roll(p_u, -1, axis=0) - p_u)
        u_x = u_x_star - (np.roll(p_u, -1, axis=1) - p_u)
        
        max_speed = np.max(np.sqrt(u_x**2 + u_y**2))
        
        if max_speed > 1e-5:
            scaling_factor = target_cfl / max_speed
            u_x *= scaling_factor
            u_y *= scaling_factor
        else:
            u_x.fill(0)
            u_y.fill(0)
        
        if track_history:
            rho_history.append(rho.copy())
        
        flux_x_right = np.where(u_x > 0, rho * u_x, np.roll(rho, -1, axis=1) * u_x)
        flux_x_left = np.roll(flux_x_right, 1, axis=1)
        flux_y_down = np.where(u_y > 0, rho * u_y, np.roll(rho, -1, axis=0) * u_y)
        flux_y_up = np.roll(flux_y_down, 1, axis=0)
        rho_new = rho - dt * ((flux_x_right - flux_x_left) + (flux_y_down - flux_y_up))
        
        rho = np.maximum(rho_new, 0)
        rho = rho / np.sum(rho)
    
    if track_history:
        return rho, (u_x, u_y), rho_history
    return rho, (u_x, u_y)


def compute_coordinates(metta_path="experiments/data/adagram.metta", mode="fluid", grid_size=36, 
                       num_steps=100, dt=0.1, af_seeds=None, spread_sigma=1.0,
                       track_history=False, target_cfl=0.8, sti_values=None):
    """Main entry point - replaces old function with fluid dynamics on torus."""
    
    edges = parse_metta(metta_path)
    
    nodes = sorted(set([e[0] for e in edges] + [e[1] for e in edges]))
    
    rho, spectral_coords, nodes_list, node_to_idx = nodes_to_distributed_mass(
        edges, nodes, grid_size=grid_size, spread_sigma=spread_sigma, sti_values=sti_values
    )
    
    if track_history:
        rho_final, velocity_field, rho_history = run_fluid_simulation(
            rho, 
            af_seeds=af_seeds,
            num_steps=num_steps,
            dt=dt,
            grid_size=grid_size,
            track_history=True,
            target_cfl=target_cfl
        )
        node_densities = map_density_to_atoms(rho_final, spectral_coords, grid_size)
        return rho_final, velocity_field, spectral_coords, rho_history, node_densities
    
    rho_final, velocity_field = run_fluid_simulation(
        rho, 
        af_seeds=af_seeds,
        num_steps=num_steps,
        dt=dt,
        grid_size=grid_size,
        target_cfl=target_cfl
    )
    
    node_densities = map_density_to_atoms(rho_final, spectral_coords, grid_size)
    return rho_final, velocity_field, spectral_coords, node_densities


def create_flow_animation(rho_history, node_coords, grid_size, output_path="flow_evolution.gif"):
    """Generate animation GIF with node overlay."""
    if not MATPLOTLIB_AVAILABLE:
        print("Warning: matplotlib not available. Skipping animation.")
        return
    
    fig, ax = plt.subplots(figsize=(7, 6))
    vmax = np.max(rho_history)
    
    def update(frame):
        ax.clear()
        ax.imshow(rho_history[frame], vmin=0, vmax=vmax, cmap='hot', origin='lower')
        
        for node, (x, y) in node_coords.items():
            grid_x = int((x / (2*np.pi)) * grid_size) % grid_size
            grid_y = int((y / (2*np.pi)) * grid_size) % grid_size
            ax.plot(grid_x, grid_y, 'o', color='cyan', markersize=4, markeredgecolor='white', markeredgewidth=0.5)
        
        ax.set_title(f'Flow Evolution (Timestep {frame})')
        ax.set_xlabel('X')
        ax.set_ylabel('Y')
        return ax.images,
    
    ani = FuncAnimation(fig, update, frames=len(rho_history), interval=50, blit=False)
    
    try:
        ani.save(output_path, writer='pillow')
        print(f"Animation saved to {output_path}")
    except Exception as e:
        print(f"Error saving animation: {e}")
    
    plt.close(fig)


def _build_arg_parser():
    parser = argparse.ArgumentParser(description="Fluid dynamics on torus manifold")
    parser.add_argument("input", nargs="?", default="experiments/data/adagram.metta",
                       help="Input MeTTa file path")
    parser.add_argument("--animate", action="store_true",
                       help="Generate animation GIF")
    parser.add_argument("--output", default="flow_evolution.gif",
                       help="Output animation file (default: flow_evolution.gif)")
    parser.add_argument("--steps", type=int, default=100,
                       help="Number of simulation timesteps (default: 100)")
    parser.add_argument("--grid", type=int, default=36,
                       help="Grid size NxN (default: 36)")
    parser.add_argument("--dt", type=float, default=0.1,
                       help="Timestep size (default: 0.1)")
    parser.add_argument("--cfl", type=float, default=0.8,
                       help="CFL target (default: 0.8)")
    parser.add_argument("--sigma", type=float, default=1.0,
                       help="Gaussian spread sigma (default: 1.0)")
    parser.add_argument("--seeds", type=str, default=None,
                       help="AF seed positions as 'x1,y1 x2,y2' or 'center' for grid center")
    parser.add_argument("--top", type=int, default=10,
                       help="Number of top atoms to display (default: 10)")
    parser.add_argument("--use-static", action="store_true", default=True,
                       help="Use hardcoded STI values (default: ON)")
    parser.add_argument("--no-static", action="store_true",
                       help="Disable hardcoded STI, use matrix-based density")
    parser.add_argument("--debug", action="store_true",
                       help="Print detailed atom-to-region mapping")
    return parser


if __name__ == "__main__":
    args = _build_arg_parser().parse_args()
    
    use_static_sti = args.use_static and not args.no_static
    
    if use_static_sti:
        raw_sti = STATIC_STI
        print(f"Using static STI values (raw, {len(STATIC_STI)} nodes)")
    else:
        raw_sti = None
        print("Using matrix-based density")
    
    print(f"Running fluid simulation on torus manifold...")
    print(f"Input: {args.input}")
    print(f"Grid: {args.grid}x{args.grid}, Steps: {args.steps}")
    
    if args.animate and MATPLOTLIB_AVAILABLE:
        print("Running with history tracking for animation...")
        
        rho_final, (u_x, u_y), coords, rho_history, node_densities = compute_coordinates(
            metta_path=args.input,
            grid_size=args.grid,
            num_steps=args.steps,
            dt=args.dt,
            spread_sigma=args.sigma,
            af_seeds=args.seeds,
            track_history=True,
            target_cfl=args.cfl,
            sti_values=raw_sti
        )
        
        print(f"Generated {len(rho_history)} frames")
        print(f"Creating animation: {args.output}")
        
        create_flow_animation(rho_history, coords, args.grid, args.output)
        
        print(f"Final rho sum: {np.sum(rho_final):.6f}")
        print(f"Max velocity: {np.max(np.sqrt(u_x**2 + u_y**2)):.4f}")
        
        if args.debug:
            print_atom_mapping(coords, raw_sti, node_densities, args.grid)
        else:
            print(f"\nTop {args.top} atoms by density:")
            sorted_atoms = sorted(node_densities.items(), key=lambda x: x[1], reverse=True)[:args.top]
            for atom, density in sorted_atoms:
                print(f"  {atom}: {density:.4f}")
    else:
        rho_final, (u_x, u_y), coords, node_densities = compute_coordinates(
            metta_path=args.input,
            grid_size=args.grid,
            num_steps=args.steps,
            dt=args.dt,
            spread_sigma=args.sigma,
            af_seeds=args.seeds,
            target_cfl=args.cfl,
            sti_values=raw_sti
        )
        
        print(f"Final rho sum: {np.sum(rho_final):.6f}")
        print(f"Max velocity: {np.max(np.sqrt(u_x**2 + u_y**2)):.4f}")
        print(f"Rho max: {np.max(rho_final):.6f}")
        print(f"Rho min: {np.min(rho_final):.6f}")
        
        if args.debug:
            print_atom_mapping(coords, raw_sti, node_densities, args.grid)
        else:
            print(f"\nTop {args.top} atoms by density:")
            sorted_atoms = sorted(node_densities.items(), key=lambda x: x[1], reverse=True)[:args.top]
            for atom, density in sorted_atoms:
                print(f"  {atom}: {density:.4f}")

