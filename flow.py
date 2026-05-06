import numpy as np
try:
    import matplotlib.pyplot as plt
    from matplotlib.animation import FuncAnimation
    MATPLOTLIB_AVAILABLE = True
except ImportError:
    print("Warning: matplotlib not installed. Animation will be skipped.")
    MATPLOTLIB_AVAILABLE = False

# --- STEP 1: Embed on a Torus (T^2) ---
# We represent the manifold M as a 24x24 grid (as used in their toy experiment).
# A torus means we use periodic boundary conditions (edges wrap around).
grid_size = 36
N = grid_size * grid_size

# Create random initial states for the AI's "Atoms" (nodes)
# In reality, this would come from the OpenCog/MORK database.
# raw_sti = np.random.rand(grid_size, grid_size)
raw_lti = np.random.rand(grid_size, grid_size)

# --- REPLACING STEP 1 & 2: The "Seed" Initial Condition ---

# Start with zero mass everywhere
raw_sti = np.zeros((grid_size, grid_size))

# Create a concentrated "blob" (seed) of attention in the top-left
raw_sti[2:5, 2:5] = 10.0
raw_sti[8:9, 18:9] = 10.0
raw_sti[12:14, 2:5] = 10.0
raw_sti[18:18, 18:18] = 10.0
raw_sti[22:23, 22:23] = 10.0
raw_sti[28:17, 28:17] = 10.0
raw_sti[20:23, 28:19] = 10.0

# Force the AF Seeds to be in the bottom-right (Target Band)
af_seeds = [(2, 18), (18, 6), (6, 18), (18, 18)]

# The Attention Mass (rho)
rho = raw_sti / np.sum(raw_sti)

# Viscosity (nu): Let's use a constant base for this test to observe pure routing
nu = np.full((grid_size, grid_size), 0.1)

# 1. The Attention Mass (rho):
# The fluid density is just the STI, normalized so the total budget equals 1.
rho = raw_sti / np.sum(raw_sti)

# 2. The Viscosity (nu):
# LTI determines how "sticky" or persistent a memory is.
# High LTI = Low Viscosity (sticks around, less diffusion).
# Low LTI = High Viscosity (explores more, diffuses away).
base_viscosity = 0.9
epsilon = 0.9 # Prevent division by zero
nu = base_viscosity / (raw_lti + epsilon)

# --- Laplacian Operator (static, computed once) ---
freqs = np.fft.fftfreq(grid_size)
kx, ky = np.meshgrid(freqs, freqs)
laplacian_op = -4 * (np.sin(np.pi * kx)**2 + np.sin(np.pi * ky)**2)
laplacian_op[0, 0] = 1.0 # Prevent division by zero at zero-frequency

# --- STEP 3: AF seeds and f_V computation moved inside loop (every 10 steps) ---


# --- Simulation Parameters ---
num_steps = 100
dt = 100.9

# Initialize velocity field (before loop)
u_x = np.zeros((grid_size, grid_size))
u_y = np.zeros((grid_size, grid_size))

# Initialize rho history for animation
rho_history = []

# --- Main Timestep Loop ---
for t in range(num_steps):
    print(f"\n=== Timestep {t} ===")
    
    # # Add new seed at t==200
    if t == 30:
        # base_viscosity = 0.09
        # epsilon = 0.01 # Prevent division by zero
        # nu = base_viscosity / (raw_lti + epsilon)
        af_seeds = [(18, 18)] # , (18, 6), (6, 18), (18, 18)]

    if t == 60:
        # base_viscosity = 0.09
        # epsilon = 0.01 # Prevent division by zero
        # nu = base_viscosity / (raw_lti + epsilon)
        af_seeds = [(30, 30)] # , (18, 6), (6, 18), (18, 18)]

    #     print(f"=== Adding new attention seed at t={t} ===")
    #     # Add a 3x3 blob at a new location (e.g., center of grid)
    #     rho[11:14, 11:14] += 1.0  # New blob (larger than existing)
    #     # Renormalize to maintain budget
    #     rho = rho / np.sum(rho)
    #     rho_history.append(rho.copy()) 

    # Recompute f_v once every 10 steps
    if t % 1 == 0:
        # # 1. Find the AF Seeds (Target locations) from current rho
        # flat_indices = np.argsort(rho.flatten())[-3:]
        # af_seeds = [np.unravel_index(idx, (grid_size, grid_size)) for idx in flat_indices]
        
        # 2. Compute the Distance Map (D) on the Torus
        D = np.full((grid_size, grid_size), np.inf)
        y_coords, x_coords = np.mgrid[0:grid_size, 0:grid_size]
        for seed_y, seed_x in af_seeds:
            dy = np.abs(seed_y - y_coords)
            dy = np.minimum(dy, grid_size - dy)
            dx = np.abs(seed_x - x_coords)
            dx = np.minimum(dx, grid_size - dx)
            D = np.minimum(D, np.sqrt(dy**2 + dx**2))
        
        # 3. Calculate the Gradient of the Distance Map
        grad_D_y = (np.roll(D, -1, axis=0) - np.roll(D, 1, axis=0)) / 2.0
        grad_D_x = (np.roll(D, -1, axis=1) - np.roll(D, 1, axis=1)) / 2.0
        
        # 4. Apply Mass-Weighting (The Ideal Routing)
        raw_v_y = -rho * grad_D_y
        raw_v_x = -rho * grad_D_x
        
        # 5. Fourier/Leray Projection (Extracting Divergence-Free Highways)
        div_raw = (raw_v_y - np.roll(raw_v_y, 1, axis=0)) + (raw_v_x - np.roll(raw_v_x, 1, axis=1))
        div_raw_fft = np.fft.fft2(div_raw)
        p_fft = div_raw_fft / laplacian_op
        p = np.real(np.fft.ifft2(p_fft))
        
        # The final, budget-safe force
        f_v_y = raw_v_y - (np.roll(p, -1, axis=0) - p)
        f_v_x = raw_v_x - (np.roll(p, -1, axis=1) - p)
        
        # Normalize the force to prevent wild scaling
        force_mag = np.max(np.sqrt(f_v_x**2 + f_v_y**2))
        if force_mag > 0:
            f_v_x /= force_mag
            f_v_y /= force_mag
        
        print(f"Recomputed f_v at step {t}, AF seeds: {af_seeds}")
    
    # Calculate the discrete Laplacian of the velocity field
    lap_u_x = np.roll(u_x, 1, axis=1) + np.roll(u_x, -1, axis=1) + \
              np.roll(u_x, 1, axis=0) + np.roll(u_x, -1, axis=0) - 4 * u_x
              
    lap_u_y = np.roll(u_y, 1, axis=1) + np.roll(u_y, -1, axis=1) + \
              np.roll(u_y, 1, axis=0) + np.roll(u_y, -1, axis=0) - 4 * u_y

    # 1. Navier-Stokes Momentum Update (Applying Force + Viscosity)
    u_x_star = u_x + dt * (f_v_x + nu * lap_u_x)
    u_y_star = u_y + dt * (f_v_y + nu * lap_u_y)
    
    div_u_check = (u_y - np.roll(u_y, 1, axis=0)) + (u_x - np.roll(u_x, 1, axis=1))
    print(f"Max velocity divergence: {np.max(np.abs(div_u_check)):.1e}")

    # 2. Velocity Projection (Safety Net, enforce divergence-free)
    div_u = (u_y_star - np.roll(u_y_star, 1, axis=0)) + (u_x_star - np.roll(u_x_star, 1, axis=1))
    div_u_fft = np.fft.fft2(div_u)
    p_u_fft = div_u_fft / laplacian_op  # Reuse Laplacian from f_v projection
    p_u = np.real(np.fft.ifft2(p_u_fft))
    u_y = u_y_star - (np.roll(p_u, -1, axis=0) - p_u)
    u_x = u_x_star - (np.roll(p_u, -1, axis=1) - p_u)
    
    # 3. CFL Targeting (Speed Control)
    max_speed = np.max(np.sqrt(u_x**2 + u_y**2))
    target_cfl = 0.8
    

    # Only scale if the wind is actually blowing (above numerical noise)
    if max_speed > 1e-5:
        scaling_factor = (target_cfl / dt) / max_speed
        u_x *= scaling_factor
        u_y *= scaling_factor
    else:
        # The wind has died; stop moving.
        u_x.fill(0)
        u_y.fill(0)
    
    # 4. Save pre-advection rho for diagnostics
    rho_old = rho.copy()
    
    # 5. Conservative Upwind Advection
    flux_x_right = np.where(u_x > 0, rho * u_x, np.roll(rho, -1, axis=1) * u_x)
    flux_x_left = np.roll(flux_x_right, 1, axis=1)
    flux_y_down = np.where(u_y > 0, rho * u_y, np.roll(rho, -1, axis=0) * u_y)
    flux_y_up = np.roll(flux_y_down, 1, axis=0)
    rho_new = rho - dt * ((flux_x_right - flux_x_left) + (flux_y_down - flux_y_up))
    pre_renorm_sum = np.sum(rho_new)  # Capture before post-processing
    
    # 6. Post-process rho (clamp + renormalize)
    rho = np.maximum(rho_new, 0)
    rho = rho / np.sum(rho)
    rho_history.append(rho.copy())  # Save snapshot for animation
    
    # 7. Diagnostics - Full Conservation Audit
    # Mass conservation
    rho_sum = np.sum(rho)
    print(f"Rho sum: {rho_sum:.10f} (pre-renorm: {pre_renorm_sum:.10f})")
    
    # Velocity magnitude check
    vel_mag = np.max(np.sqrt(u_x**2 + u_y**2))
    print(f"Max velocity: {vel_mag:.4f}")
    
    # Rho change
    print(f"Max rho change: {np.max(np.abs(rho_old - rho)):.6f}")
    
    # Divergence check (velocity field)
    div_u_check = (u_y - np.roll(u_y, 1, axis=0)) + (u_x - np.roll(u_x, 1, axis=1))
    print(f"Max velocity divergence: {np.max(np.abs(div_u_check)):.1e}")

if MATPLOTLIB_AVAILABLE:
    print("\nGenerating rho evolution animation...")

    # Set up figure for rho heatmap
    fig, ax = plt.subplots(figsize=(7, 6))
    vmax = np.max(rho_history)  # Fixed color scale
    im = ax.imshow(rho_history[0], vmin=0, vmax=vmax, cmap='hot')
    plt.colorbar(im, ax=ax, label='Attention Mass (rho)')
    ax.set_title('Rho Evolution (Timestep 0)')

    def update(frame):
        ax.clear()
        im = ax.imshow(rho_history[frame], vmin=0, vmax=vmax, cmap='hot')
        ax.set_title(f'Rho Evolution (Timestep {frame})')
        return im,

    # Animate: 50ms per frame, total frames = num_steps
    ani = FuncAnimation(fig, update, frames=len(rho_history), interval=50, blit=False)

    # Save as GIF (no ffmpeg required)
    gif_path = 'rho_evolution.gif'
    ani.save(gif_path, writer='pillow')
    print(f"Animation saved as {gif_path}")

    # Optional: Display interactively (comment out if GUI unavailable)
    # plt.show()
else:
    print("\nSkipping animation: matplotlib not installed.")
