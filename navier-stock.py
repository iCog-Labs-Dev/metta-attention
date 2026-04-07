import numpy as np
import networkx as nx
import matplotlib.pyplot as plt

# -----------------------------
# 1. Build a simple graph
# -----------------------------
G = nx.Graph()

edges = [
    ("A", "B"), ("A", "C"),
    ("B", "D"), ("C", "D"),
    ("D", "E"), ("E", "F")
]
G.add_edges_from(edges)

nodes = list(G.nodes)
n = len(nodes)

# Map node index
idx = {node: i for i, node in enumerate(nodes)}

# -----------------------------
# 2. Initialize attention & value
# -----------------------------
attention = np.zeros(n)
value = np.zeros(n)

# Stimulate node A
attention[idx["A"]] = 1.0
value[idx["A"]] = 1.0

# Hyperparameters
diffusion_rate = 0.3
gamma = 0.9
steps = 10

# -----------------------------
# 3. Simulation loop
# -----------------------------
history_attention = []
history_value = []

for t in range(steps):
    new_attention = attention.copy()
    new_value = value.copy()

    for node in nodes:
        i = idx[node]
        neighbors = list(G.neighbors(node))
        
        if neighbors:
            neighbor_indices = [idx[n] for n in neighbors]
            
            # ---- Attention diffusion (Navier–Stokes-like)
            neighbor_mean = np.mean(attention[neighbor_indices])
            new_attention[i] += diffusion_rate * (neighbor_mean - attention[i])
            
            # ---- Value update (HJB/Bellman-like)
            max_neighbor_value = np.max(value[neighbor_indices])
            reward = attention[i]  # attention drives reward
            new_value[i] = reward + gamma * max_neighbor_value

    attention = new_attention
    value = new_value

    history_attention.append(attention.copy())
    history_value.append(value.copy())

# -----------------------------
# 4. Visualization
# -----------------------------
def plot_state(attention, value, title):
    pos = nx.spring_layout(G, seed=42)
    
    node_colors = attention
    node_sizes = 1000 * (value + 0.1)
    
    plt.figure()
    nx.draw(
        G, pos,
        with_labels=True,
        node_color=node_colors,
        node_size=node_sizes,
        cmap=plt.cm.viridis
    )
    plt.title(title)
    plt.show()

# Show initial and final state
plot_state(history_attention[0], history_value[0], "Step 1")
plot_state(history_attention[-1], history_value[-1], "Final Step")