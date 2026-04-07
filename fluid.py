import numpy as np

# ----------------------------
# 1. Define Graph
# ----------------------------
graph = {
    "A": ["B", "C"],
    "B": ["D", "E", "K"],
    "C": ["F", "K"],
    "K": ["G"],
    "D": ["G"],
    "E": ["Z"],
    "F": [],
    "G": [],
    "Z": [],
}

nodes = list(graph.keys())

# ----------------------------
# 2. Bellman Value Iteration
# ----------------------------
def compute_value(graph, reward, gamma=0.9, iterations=20):
    W = {node: 0.0 for node in graph}

    for _ in range(iterations):
        new_W = {}
        for node in graph:
            print("length of node ", node , " ", len(graph[node]))
            if len(graph[node]) == 0:
                new_W[node] = reward[node]
            else:
                best_next = max([W[n] for n in graph[node]])
                print("what is best next for node ", node , " ", best_next)
                new_W[node] = reward[node] + gamma * best_next
                print("node update for node ", node , " ", new_W[node])

        W = new_W

    return W


# ----------------------------
# 3. Flow (Directed instead of uniform)
# ----------------------------
def compute_flow_probs(node, graph, W):
    neighbors = graph[node]
    if not neighbors:
        return {}

    # Only move toward higher-value nodes
    scores = []
    for n in neighbors:
        score = max(0, W[n] - W[node])
        scores.append(score)

    total = sum(scores)
    if total == 0:
        # fallback to uniform (like diffusion)
        probs = [1 / len(neighbors)] * len(neighbors)
    else:
        probs = [s / total for s in scores]

    return dict(zip(neighbors, probs))


# ----------------------------
# 4. Simulate Attention Flow
# ----------------------------
def simulate_flow(start_node, graph, W, steps=5):
    current = start_node
    path = [current]

    for _ in range(steps):
        probs = compute_flow_probs(current, graph, W)
        print("probs ", probs)
        if not probs:
            break

        next_nodes = list(probs.keys())
        probabilities = list(probs.values())

        current = np.random.choice(next_nodes, p=probabilities)
        path.append(current)

    return path


# ----------------------------
# 5. Define Two Different Goals
# ----------------------------

# Goal 1: Reach G
reward_goal1 = {node: 0 for node in nodes}
reward_goal1["G"] = 10

# Goal 2: Reach E instead
reward_goal2 = {node: 0 for node in nodes}
reward_goal2["E"] = 10


# ----------------------------
# 6. Compute Values
# ----------------------------
W1 = compute_value(graph, reward_goal1)
# W2 = compute_value(graph, reward_goal2)

print("Value Function (Goal = G):")
for k, v in W1.items():
    print(f"{k}: {round(v,2)}")

# print("\nValue Function (Goal = E):")
# for k, v in W2.items():
#     print(f"{k}: {round(v,2)}")


# ----------------------------
# 7. Simulate Paths
# ----------------------------
print("\n--- Paths toward Goal G ---")
for _ in range(5):
    print(simulate_flow("A", graph, W1))

# print("\n--- Paths toward Goal E ---")
# for _ in range(5):
#     print(simulate_flow("A", graph, W2))


