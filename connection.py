import re
import argparse
import numpy as np
import scipy.linalg
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
MATPLOTLIB_AVAILABLE = True


STATIC_STI = {
    'dichloropropene' : 300,
    'beanleafroller': 360,
    'dobsonfly': 292,
    'grasshopper': 352,
    'hemlock': 522,
    'leafhopper': 135,
    'moth': 421,
    'diazinon': 747,
    'alachlor': 131,
    'bactericide': 187,
    'beanleafrollers': 178,
    'dicofol': 178,
    'caterpillar': 107,
    'dilan': 117,
    'borer': 121,
    'caterpillars': 121,
    'zelatrix': 300
}

DEFAULT_STI = 0



def parse_metta(filepath):
    pattern = r"\(\(\w+ (\w+) (\w+)\) \((\S+) (\S+)\)\)"
    with open(filepath) as f:
        content = f.read()

    matches = re.findall(pattern, content)
    edges = [(m[0], m[1], float(m[2]), float(m[3])) for m in matches]
    return edges


def build_adjacency_matrix(edges, nodes, make_symmetric=False):
    node_to_idx = {n: i for i, n in enumerate(nodes)}
    n = len(nodes)

    matrix = [[0.0] * n for _ in range(n)]
    for src, dst, s1, s2 in edges:
        i, j = node_to_idx[src], node_to_idx[dst]
        matrix[i][j] = s1 * s2
        if make_symmetric:
            matrix[j][i] = matrix[i][j]

    return np.array(matrix, dtype=np.float64), node_to_idx


def get_spectral_coordinates_magnetic(matrix, nodes, q=0.25):
    """
    Get 2D spectral coordinates using the Magnetic Laplacian for directed graphs.
    q: The 'magnetic charge' parameter (typically 0.1 to 0.25) controlling directional flow.
    """
    A = np.array(matrix, dtype=np.float64)
    n = len(nodes)
    
    # 1. Construct the Symmetric Weight and Phase Matrices
    W = 0.5 * (A + A.T)                           # Symmetric connection strength
    Theta = 2 * np.pi * q * (A - A.T)             # Phase encoding directionality
    
    # 2. Construct the Complex Hermitian Matrix (H)
    # Using 1j for the imaginary unit in Python
    H = W * np.exp(1j * Theta) 
    
    # 3. Construct the Degree Matrix (D) and Magnetic Laplacian (L)
    D = np.diag(np.sum(W, axis=1))
    L = D - H
    
    try:
        # 4. Eigendecomposition
        # scipy.linalg.eigh is explicitly for Hermitian matrices. 
        # It is faster, more stable, and guarantees real eigenvalues.
        # It automatically sorts eigenvalues in ascending order.
        eigenvalues, eigenvectors = scipy.linalg.eigh(L)
        
        # 5. Extract Coordinates
        # The 0th eigenvector corresponds to eigenvalue ~0 (trivial).
        # We take the 1st eigenvector. Because it is complex, a single 
        # eigenvector provides BOTH X (real) and Y (imaginary) coordinates!
        v1 = eigenvectors[:, 1]
        
        coords = {}
        for i, node in enumerate(nodes):
            # Extract real and imaginary parts for X and Y
            x = float(np.real(v1[i]))
            y = float(np.imag(v1[i]))
            coords[node] = (x, y)
            
    except Exception as e:
        print(f"Eigendecomposition failed: {e}")
        # Fallback to circle layout
        coords = {node: (float(np.cos(2 * np.pi * i / n)), float(np.sin(2 * np.pi * i / n))) 
                  for i, node in enumerate(nodes)}
        
    return coords

def map_density_to_atoms(rho, spectral_coords, grid_size, radius=3):
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
    
    print(f"discrete_weights {discrete_weights}")
    return discrete_weights


def print_atom_mapping(spectral_coords, sti_values, node_densities, grid_size, radius=2):
    """Print detailed mapping of all atoms to manifold regions."""
    if not spectral_coords:
        print("No spectral coordinates available")
        return

    total_sti = sum(sti_values.values()) if sti_values else 0
    total_density = sum(node_densities.values()) if node_densities else 1.0

    coords_arr = np.array(list(spectral_coords.values()))
    coord_min = coords_arr.min()
    coord_max = coords_arr.max()
    coord_range = coord_max - coord_min + 1e-10

    rows = []
    for node in spectral_coords.keys():
        x, y = spectral_coords[node]

        gx = int(((x - coord_min) / coord_range) * grid_size) % grid_size
        gy = int(((y - coord_min) / coord_range) * grid_size) % grid_size

        initial_sti = sti_values.get(node, DEFAULT_STI) if sti_values else DEFAULT_STI
        final_density = node_densities.get(node, 0.0) / total_density
        final_sti = total_sti * final_density

        rows.append((node, gx, gy, x, y, initial_sti, final_density, final_sti))

    rows.sort(key=lambda r: r[7], reverse=True)

    print("\n" + "="*80)
    print(f"{'Atom':<25} {'Grid':<10} {'Eigenvector':<25} {'Initial STI':<12} {'Final Density':<14} {'Final STI'}")
    print("="*80)

    for row in rows:
        node, gx, gy, x, y, initial_sti, final_density, final_sti = row
        print(f"{node:<25} ({gx:2d},{gy:2d})    ({x:>10.4f}, {y:>10.4f})    {initial_sti:<12} {final_density:.6f}    {final_sti:.6f}")

    print("="*80)


def spectral_to_grid_coords(spectral_coords, grid_size):
    """Convert spectral (eigenvector) coordinates to grid positions."""
    if not spectral_coords:
        return {}

    coord_arr = np.array(list(spectral_coords.values()))
    coord_min = coord_arr.min()
    coord_max = coord_arr.max()
    coord_range = coord_max - coord_min + 1e-10

    grid_positions = {}
    for node, (x, y) in spectral_coords.items():
        gx = int(((x - coord_min) / coord_range) * grid_size) % grid_size
        gy = int(((y - coord_min) / coord_range) * grid_size) % grid_size
        grid_positions[node] = (gx, gy)
    return grid_positions


def nodes_to_distributed_mass(edges, nodes, grid_size=36, spread_sigma=1.0, sti_values=None):
    """Map nodes to rho field via spectral embedding + Gaussian spread."""
    matrix, node_to_idx = build_adjacency_matrix(edges, nodes)

    spectral_coords = get_spectral_coordinates_magnetic(matrix, nodes)
    
    if sti_values:
        node_sti = sti_values
    else:
        node_sti = {}
        for node in nodes:
            idx = node_to_idx.get(node, 0)
            weight = np.mean(matrix[idx, :]) if idx < len(matrix) else DEFAULT_STI
            node_sti[node] = weight
    
    if not spectral_coords:
        rho = np.zeros((grid_size, grid_size))
        return rho, spectral_coords, nodes, node_to_idx
    
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
    
    return rho, spectral_coords, nodes, node_to_idx


def get_center_seed(grid_size, n_seeds=4):
    """Get center of grid as seed(s)."""
    cx, cy = grid_size // 2, grid_size // 2
    if n_seeds == 1:
        return [(cy, cx)]
    offsets = [(0, 0), (-4, 0), (4, 0), (0, -4), (0, 4)][:n_seeds]
    return [(cy + dy, cx + dx) for dy, dx in offsets]


def precompute_fourier_velocity_modes(grid_size, k_max=12):
    """
    Precomputes a divergence-free velocity basis using Fourier stream functions.
    k_max controls how many frequencies we use. Higher = more detailed wind patterns.
    """
    modes = []
    y_coords, x_coords = np.mgrid[0:grid_size, 0:grid_size]
    
    # Iterate through wave frequencies (k_x, k_y)
    for kx in range(-k_max, k_max + 1):
        for ky in range(-k_max, k_max + 1):
            if kx == 0 and ky == 0:
                continue # Skip the zero-frequency (flat plane) mode
            
            # The base wave phase: 2 * pi * (kx * x + ky * y) / N
            theta = 2 * np.pi * (kx * x_coords + ky * y_coords) / grid_size
            
            # --- Mode A: Derived from Stream Function psi = sin(theta) ---
            # Velocity is perpendicular gradient: (d_psi/dy, -d_psi/dx)
            u_x_A = ky * np.cos(theta)
            u_y_A = -kx * np.cos(theta)
            
            # Normalize the mode's energy so our greedy scores stay balanced
            norm_A = np.sum(u_x_A**2 + u_y_A**2) + 1e-8
            u_x_A /= np.sqrt(norm_A)
            u_y_A /= np.sqrt(norm_A)
            
            # --- Mode B: Derived from Stream Function psi = cos(theta) ---
            u_x_B = -ky * np.sin(theta)
            u_y_B = kx * np.sin(theta)
            
            norm_B = np.sum(u_x_B**2 + u_y_B**2) + 1e-8
            u_x_B /= np.sqrt(norm_B)
            u_y_B /= np.sqrt(norm_B)
            
            modes.append((u_x_A, u_y_A))
            modes.append((u_x_B, u_y_B))
            
    return modes

def run_fluid_simulation_greedy(rho_initial, velocity_modes, af_seeds=None, num_steps=100, 
                                dt=0.1, grid_size=36, track_history=False, target_cfl=0.8, 
                                lambda_penalty=0.01):
    """
    Runs incompressible advection using a greedy stream-function basis.
    Guarantees div(u) = 0 without any pressure projection step.
    """
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
    
    for t in range(num_steps):
        # --- 1. Define the Goal / Target ---
        D = np.full((grid_size, grid_size), np.inf)
        y_coords, x_coords = np.mgrid[0:grid_size, 0:grid_size]
        
        for seed_y, seed_x in af_seeds:
            # Toroidal distance calculation
            dy = np.abs(seed_y - y_coords)
            dy = np.minimum(dy, grid_size - dy)
            dx = np.abs(seed_x - x_coords)
            dx = np.minimum(dx, grid_size - dx)
            D = np.minimum(D, np.sqrt(dy**2 + dx**2))
        
        # Calculate the downhill direction to the seed (g = -nabla D)
        grad_D_y = (np.roll(D, -1, axis=0) - np.roll(D, 1, axis=0)) / 2.0
        grad_D_x = (np.roll(D, -1, axis=1) - np.roll(D, 1, axis=1)) / 2.0
        g_y = -grad_D_y
        g_x = -grad_D_x
        
        # --- 2. The Greedy Score Update (Replaces FFT Projection) ---
        u_x = np.zeros((grid_size, grid_size))
        u_y = np.zeros((grid_size, grid_size))
        
        # Score each precomputed wave mode
        for mode_ux, mode_uy in velocity_modes:
            # How well does this wave align with the downhill direction?
            alignment = (mode_ux * g_x) + (mode_uy * g_y)
            
            # Weight alignment by where the fluid actually is right now
            weighted_alignment = alignment * rho
            
            # Calculate alpha score (sum of helpfulness / (energy + lambda))
            # Since we normalized modes in precomputation, energy is 1.0
            score = np.sum(weighted_alignment) / (1.0 + lambda_penalty)
            
            # Add this wave to our total wind, scaled by its score
            u_x += score * mode_ux
            u_y += score * mode_uy
            
        # Because every mode was built from a stream function, 
        # u_x and u_y are now mathematically guaranteed to be divergence-free!
        
        # --- 3. CFL Clamp (Stability) ---
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
            
        # --- 4. Conservative Upwind Advection ---
        flux_x_right = np.where(u_x > 0, rho * u_x, np.roll(rho, -1, axis=1) * u_x)
        flux_x_left = np.roll(flux_x_right, 1, axis=1)
        
        flux_y_down = np.where(u_y > 0, rho * u_y, np.roll(rho, -1, axis=0) * u_y)
        flux_y_up = np.roll(flux_y_down, 1, axis=0)
        
        # We can drop the explicit viscosity term (diffusion) from Navier-Stokes 
        # because the upwind advection naturally provides a stable numerical diffusion.
        rho_new = rho - dt * ((flux_x_right - flux_x_left) + (flux_y_down - flux_y_up))
        
        rho = np.maximum(rho_new, 0)
        rho = rho / np.sum(rho) # Strict mass conservation
        
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
    
    velocity_modes = precompute_fourier_velocity_modes(grid_size=grid_size, k_max=4)


    if track_history:

        rho_final, velocity_field, rho_history = run_fluid_simulation_greedy(
            rho, 
            velocity_modes=velocity_modes,
            af_seeds=af_seeds,
            num_steps=num_steps,
            dt=dt,
            grid_size=grid_size,
            track_history=True,
            target_cfl=target_cfl
        )

        node_densities = map_density_to_atoms(rho_final, spectral_coords, grid_size)
        return rho_final, velocity_field, spectral_coords, rho_history, node_densities

    rho_final, velocity_field = run_fluid_simulation_greedy(
        rho, 
        velocity_modes=velocity_modes,
        af_seeds=af_seeds,
        num_steps=num_steps,
        dt=dt,
        grid_size=grid_size,
        target_cfl=target_cfl
    )

    node_densities = map_density_to_atoms(rho_final, spectral_coords, grid_size)
    return rho_final, velocity_field, spectral_coords, node_densities


def create_flow_animation(rho_history, node_grid_positions, grid_size, output_path="flow_evolution.gif"):
    """Generate animation GIF with node overlay."""
    if not MATPLOTLIB_AVAILABLE:
        print("Warning: matplotlib not available. Skipping animation.")
        return

    fig, ax = plt.subplots(figsize=(7, 6))
    vmax = np.max(rho_history)

    def update(frame):
        ax.clear()
        ax.imshow(rho_history[frame], vmin=0, vmax=vmax, cmap='hot', origin='lower')

        for node, (grid_x, grid_y) in node_grid_positions.items():
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
        
        if args.debug:
            print_atom_mapping(coords, raw_sti, node_densities, args.grid)
        else:
            print(f"\nTop {args.top} atoms by density:")
            sorted_atoms = sorted(node_densities.items(), key=lambda x: x[1], reverse=True)[:args.top]
            for atom, density in sorted_atoms:
                print(f"  {atom}: {density:.4f}")

        grid_positions = spectral_to_grid_coords(coords, args.grid)
        create_flow_animation(rho_history, grid_positions, args.grid, args.output)
        
        print(f"Final rho sum: {np.sum(rho_final):.6f}")
        print(f"Max velocity: {np.max(np.sqrt(u_x**2 + u_y**2)):.4f}")
        
    else:
        rho_final, (u_x, u_y), coords, node_densities, initial_node_densities = compute_coordinates(
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
            print_atom_mapping(coords, raw_sti, node_densities, args.grid, initial_node_densities)
        else:
            print(f"\nTop {args.top} atoms by density:")
            sorted_atoms = sorted(node_densities.items(), key=lambda x: x[1], reverse=True)[:args.top]
            for atom, density in sorted_atoms:
                print(f"  {atom}: {density:.4f}")

