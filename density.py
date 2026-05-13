import numpy as np
import networkx as nx
import matplotlib.pyplot as plt

# ==========================================
# 1. TORUS GRAPH & DATA SETUP
# ==========================================
W, H = 4, 4
G_undirected = nx.grid_2d_graph(W, H, periodic=True)
G = G_undirected.to_directed()

for src, dst in G.edges():
    G[src][dst]['capacity'] = 1.0

nodes = list(G.nodes())
edges = list(G.edges())
N, E = len(nodes), len(edges)

# Initial attention budgets
STATIC_STI = {
    'diazinon': 747, 'alachlor': 131, 'bactericide': 187,
    'beanleafrollers': 178, 'dicofol': 178, 'beanleafroller': 157,
    'caterpillar': 107, 'dilan': 117, 'borer': 121, 'caterpillars': 121
}
zero_sti_terms = ['ants', 'grasshopper', 'chlorine', 'unable', 'peaweevil']
all_terms = list(STATIC_STI.keys()) + zero_sti_terms

# Map terms to specific (x, y) coordinates
term_to_coord = {term: nodes[i % N] for i, term in enumerate(all_terms)}
coord_to_term = {coord: term for term, coord in term_to_coord.items()}

# Pour the fluid
rho = np.zeros(N)
for i, coord in enumerate(nodes):
    if coord in coord_to_term:
        term = coord_to_term[coord]
        rho[i] = STATIC_STI.get(term, 0.0)

# ==========================================
# 2. INCOMPRESSIBLE TRANSPORT STEP 
# ==========================================
def fluid_transport_step(G, rho, raw_gradient, dt=0.4):
    B = nx.incidence_matrix(G, oriented=True).toarray()
    W_e = np.diag([data['capacity'] for _, _, data in G.edges(data=True)])
    L = B @ W_e @ B.T 
    
    p = np.linalg.pinv(L) @ (B @ raw_gradient)
    u = raw_gradient - (W_e @ B.T @ p)
    
    J = np.zeros(E)
    for e_idx, (src, dst) in enumerate(edges):
        src_idx = nodes.index(src)
        J[e_idx] = rho[src_idx] * u[e_idx] 
        
    rho_new = rho - dt * (B @ J)
    rho_new = np.clip(rho_new, 0, None)
    
    if np.sum(rho_new) > 0:
        rho_new = rho_new * (np.sum(rho) / np.sum(rho_new))
        
    return rho_new, u

# ==========================================
# 3. VISUALIZATION FUNCTION
# ==========================================
def plot_fluid_state(rho_before, rho_after, W, H, nodes, coord_to_term):
    """Plots a side-by-side heatmap of the attention fluid on the Torus."""
    grid_before = np.zeros((H, W))
    grid_after = np.zeros((H, W))
    
    # Map the 1D arrays back to 2D grid coordinates
    for idx, (x, y) in enumerate(nodes):
        grid_before[y, x] = rho_before[idx]
        grid_after[y, x] = rho_after[idx]

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Attention Fluid (STI) Transport on a Torus', fontsize=16)

    # Plot Before
    im1 = axes[0].imshow(grid_before, origin='lower', cmap='plasma', vmin=0, vmax=800)
    axes[0].set_title(f'Initial State (Total Mass: {np.sum(rho_before):.0f})')
    
    # Plot After
    im2 = axes[1].imshow(grid_after, origin='lower', cmap='plasma', vmin=0, vmax=800)
    axes[1].set_title(f'After 1 Step (Total Mass: {np.sum(rho_after):.0f})')

    # Add text labels and grid formatting for both plots
    for ax, grid in zip(axes, [grid_before, grid_after]):
        ax.set_xticks(np.arange(-0.5, W, 1), minor=True)
        ax.set_yticks(np.arange(-0.5, H, 1), minor=True)
        ax.grid(which='minor', color='w', linestyle='-', linewidth=2)
        ax.set_xticks([])
        ax.set_yticks([])
        
        # Overlay the vocabulary terms and their fluid amounts
        for (x, y), term in coord_to_term.items():
            val = grid[y, x]
            # Choose text color based on background darkness for readability
            color = 'black' if val > 400 else 'white'
            ax.text(x, y, f"{term}\n{val:.1f}", ha='center', va='center', 
                    color=color, fontsize=9, fontweight='bold')

    # Add a shared colorbar
    cbar = fig.colorbar(im2, ax=axes, orientation='vertical', fraction=0.02, pad=0.04)
    cbar.set_label('Attention Density (STI units)')

    plt.savefig('fluid_state.png', dpi=150, bbox_inches='tight')
    plt.close()

# ==========================================
# 4. RUN AND VISUALIZE
# ==========================================

# Create a "Diagonal Wind" goal pushing East (+x) and North (+y)
diagonal_wind = np.zeros(E)
for i, (src, dst) in enumerate(edges):
    src_x, src_y = src
    dst_x, dst_y = dst
    if dst_x == (src_x + 1) % W:
        diagonal_wind[i] = 1.0  
    elif dst_y == (src_y + 1) % H:
        diagonal_wind[i] = 1.0  

# Run the transport step
new_rho, velocity_u = fluid_transport_step(G, rho, diagonal_wind, dt=0.4)

# Trigger the visualization
plot_fluid_state(rho, new_rho, W, H, nodes, coord_to_term)
