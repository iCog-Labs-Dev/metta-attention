# `connection.py` Process Flow

This document explains how
`attention/ImportanceDiffusionAgent/fluidDiffusion/connection.py` moves
attention values through a fluid-transport layer.

The short version: MeTTa/PeTTa owns ECAN state and passes the current STI
values into Python. Python treats those STI values as conserved mass, moves
that mass across a graph-derived grid using incompressible transport, maps the
final density back to atom-level values, and returns proposed STI pairs to
MeTTa.

## Boundary

`connection.py` is a transport adapter. It does not implement the ECAN
economic system.

It does:

- Parse a MeTTa graph file into weighted directed edges.
- Convert atom STI values from MeTTa into a normalized density field `rho`.
- Embed graph atoms into a 2D grid.
- Compute a goal/value/control field.
- Build a divergence-free velocity field from stream-function modes.
- Advect density while preserving mass.
- Convert final density back into atom/value pairs.

It does not:

- Call `setSti`.
- Own atom STI/LTI state.
- Apply ECAN wages, rent, tax, welfare, AF updates, LTI updates, or forgetting.
- Decide final ECAN economics after fluid transport.

That separation matters because the Python layer should only return a proposed
transport redistribution. The MeTTa side decides how to apply it.

## Top-Level Flow

```text
fluid_integration.metta
  -> extractStiPairs(getAfAtoms)
  -> py-call(connection.fluid_from_af graphFile pairs ...)
  -> parse graph edges
  -> split STI into graph atoms and pass-through atoms
  -> embed graph atoms into a 2D grid
  -> push STI mass into rho
  -> transport rho over num_steps
       -> compute goal cells
       -> compute distance/cost/value
       -> compute control direction
       -> build divergence-free velocity
       -> CFL-scale velocity
       -> advect density
  -> pull final rho back to atom STI values
  -> merge pass-through atoms
  -> return [[atom, value], ...] to MeTTa
  -> MeTTa applyNewStis(...) writes values through ECAN-side functions
```

There are two practical entry points:

- `fluid_from_af(...)`: the integration entry point used by MeTTa.
- `main()`: a CLI/smoke-test entry point for manually running the same
  transport pipeline on a graph file.

## Data Shapes

The main intermediate data structures are:

```text
edges:
  list[tuple[source: str, target: str, mean: float, confidence: float]]

nodes:
  list[str]

sti_values:
  dict[str, float]

spectral_coords:
  dict[str, tuple[x: float, y: float]]

grid positions:
  dict[str, tuple[grid_x: int, grid_y: int]]

rho:
  np.ndarray with shape (grid_size, grid_size)

velocity:
  tuple[u_x: np.ndarray, u_y: np.ndarray]

diagnostics:
  dict[str, float | list[tuple[int, int]]]

returned STI pairs:
  list[list[atom: str, value: float]]
```

The grid arrays use NumPy row/column indexing. In most functions, cell access
is `rho[grid_y, grid_x]`.

## Call Graph

```text
fluid_from_af
  -> read_sti_pairs
  -> parse_metta_edges
  -> extract_atoms
  -> push_sti_to_density
       -> build_adjacency_matrix
       -> get_spectral_coordinates_magnetic
       -> spectral_to_grid_coords
  -> transport_density
       -> parse_goal_cells
            -> get_center_seed
       -> compute_goal_mask
       -> compute_distance_to_goals
       -> compute_cost_field
       -> solve_value_field
       -> compute_control_from_value
       -> precompute_fourier_velocity_modes
       -> combine_modes_alignment
       -> apply_cfl_scaling
       -> advect_density_upwind
       -> compute_diagnostics
            -> compute_divergence
  -> pull_density_to_sti
       -> map_density_to_atoms
            -> spectral_to_grid_coords
  -> print_diagnostics
```

The CLI follows the same lower-level path, but starts from `main()` instead of
`fluid_from_af(...)`.

## Configuration: `FluidParams`

`FluidParams` collects the transport parameters:

```python
grid_size: int = 36
num_steps: int = 100
dt: float = 0.1
target_cfl: float = 0.4
k_max: int = 4
spread_sigma: float = 1.0
control_mode: str = "value_alignment"
value_iterations: int = 100
gamma: float = 0.95
lambda_penalty: float = 0.01
density_radius: int = 1
diagnostics: bool = True
```

Important parameters:

- `grid_size`: side length of the square transport grid.
- `num_steps`: number of advection iterations.
- `dt`: timestep used by the advection update and CFL calculation.
- `target_cfl`: desired CFL value after velocity scaling.
- `k_max`: maximum Fourier frequency used to build velocity modes.
- `spread_sigma`: Gaussian spread radius used when pushing atom STI to the
  grid.
- `control_mode`: either `distance` or `value_alignment`.
- `value_iterations`: number of Bellman value-iteration passes.
- `gamma`: discount factor in the value update.
- `lambda_penalty`: dampens each mode's alignment score.
- `density_radius`: local radius used when pulling grid density back to atoms.

## Input Parsing and Graph Setup

### `parse_metta_edges(filepath)`

Reads a graph file and extracts weighted directed edges matching this shape:

```text
((link source target) (mean confidence))
```

Each parsed edge becomes:

```python
(source, target, mean, confidence)
```

The code multiplies `mean * confidence` later to get a single edge weight.

### `extract_atoms(edges)`

Collects every source and target atom from the edge list and returns a sorted
unique atom list. This list defines the atom order for matrix construction and
embedding.

### `read_sti_pairs(atom_sti_pairs)`

Converts MeTTa `py-call` input into a Python dictionary:

```python
[["atom_a", 100.0], ["atom_b", 40.0]]
```

becomes:

```python
{"atom_a": 100.0, "atom_b": 40.0}
```

### `build_adjacency_matrix(edges, nodes, make_symmetric=False)`

Builds a dense NumPy adjacency matrix. For every edge:

```python
matrix[source_index, target_index] = mean * confidence
```

By default, direction is preserved. If `make_symmetric=True`, the reverse cell
also receives the same weight. The current fluid pipeline uses the directed
matrix.

## Embedding Atoms Onto the Grid

The fluid simulation runs on a regular 2D grid, so graph atoms must first be
assigned locations on that grid.

### `get_spectral_coordinates_magnetic(matrix, nodes, q=0.25)`

This function embeds directed graph structure into 2D coordinates using a
magnetic Laplacian:

1. Build symmetric weights:
   ```python
   weights = 0.5 * (matrix + matrix.T)
   ```
2. Encode direction with a complex phase:
   ```python
   theta = 2 * pi * q * (matrix - matrix.T)
   hermitian = weights * exp(1j * theta)
   ```
3. Build the Laplacian:
   ```python
   laplacian = degree - hermitian
   ```
4. Compute eigenvectors with `scipy.linalg.eigh`.
5. Use the real and imaginary parts of the second eigenvector as `(x, y)`.

If eigendecomposition fails, atoms fall back to a circle layout.

The embedding does not change STI. It only decides where atoms live on the
fluid grid.

### `spectral_to_grid_coords(spectral_coords, grid_size)`

Normalizes spectral `x` and `y` coordinates separately into integer grid
coordinates:

```text
spectral (x, y) -> grid (grid_x, grid_y)
```

The result is used both when pushing STI into `rho` and when reading final
density back out of `rho`.

## Pushing STI Into Fluid Density

### `push_sti_to_density(edges, nodes, params, sti_values=None, spectral_coords=None)`

This function creates the initial fluid density field.

Steps:

1. Build the adjacency matrix.
2. Compute spectral coordinates if not supplied.
3. Decide atom weights:
   - If `sti_values` is provided, use those MeTTa STI values.
   - Otherwise, use mean outgoing adjacency weight as a fallback. This fallback
     mainly supports CLI/manual runs.
4. Convert atom coordinates to grid cells.
5. For each atom with positive weight, spread its weight onto nearby cells with
   a Gaussian kernel.
6. Normalize the final grid so:
   ```python
   np.sum(rho) == 1.0
   ```

The important design point is that `rho` represents normalized attention mass,
not raw STI. Raw STI total is preserved separately and restored during pullback.

## Goals, Costs, and Value Fields

The transport does not move mass randomly. It builds a goal-oriented value
field and pushes density along `-grad(value)`.

### `get_center_seed(grid_size, n_seeds=4)`

Returns one or more goal cells near the grid center. This is used when no
explicit `af_seeds` are provided.

### `parse_goal_cells(af_seeds, grid_size)`

Converts seed input into grid cells.

Supported inputs:

- `None`: use default center seeds.
- `"center"`: use a single center seed.
- `"y,x"` or `"y1,x1 y2,x2"`: parse explicit cells.
- `list[tuple[int, int]]`: use already-parsed cells.

The code treats seed tuples as `(seed_y, seed_x)` and wraps them modulo
`grid_size`.

### `compute_distance_to_goals(grid_size, goal_cells)`

Computes toroidal distance from every grid cell to the nearest goal cell. The
grid wraps around at boundaries, so a cell near the right edge can be close to a
goal near the left edge.

### `compute_goal_mask(grid_size, goal_cells, radius=1)`

Builds a boolean mask around goal cells. Diagnostics use this mask to report
how much final density is in the goal region.

### `compute_cost_field(distance)`

Builds the cost field used by value iteration as normalized toroidal distance
to the nearest goal cell:

```python
cost = distance / max(distance)
```

The cost is static — it depends only on geometry, not on the evolving density.

### `solve_value_field(cost, gamma=0.95, iterations=100, goal_mask=None)`

Runs a discrete Bellman-style value iteration:

```text
value = immediate cost + gamma * cheapest neighboring future value
```

Each iteration uses the minimum of the four grid neighbors. Goal-mask cells are
forced to zero when a mask is provided.

The result is a smoothed value field. The flow later follows the negative
gradient of this field.

### `compute_control_from_value(value)`

Computes centered finite-difference gradients and returns:

```python
control_x = -grad_x(value)
control_y = -grad_y(value)
```

This is the desired direction of movement before projecting into the
divergence-free velocity basis.

## Velocity and Incompressible Transport

The velocity field is not arbitrary. It is built from stream-function modes,
which are divergence-free under the same finite-difference operator used by
diagnostics.

### `precompute_fourier_velocity_modes(grid_size, k_max=4)`

Creates a list of divergence-free velocity modes. For each Fourier wave:

```python
psi = sin(theta) or cos(theta)
u_x = dpsi/dy
u_y = -dpsi/dx
```

The stream-function curl construction gives:

```text
div(u) = 0
```

Each mode is normalized before being added to the mode list.

### `compute_divergence(u_x, u_y)`

Computes finite-difference divergence:

```python
div_x = d(u_x)/dx
div_y = d(u_y)/dy
div = div_x + div_y
```

This is used for diagnostics and tests.

### `combine_modes_alignment(modes, rho, control_x, control_y, lambda_penalty)`

Builds the actual velocity field as a weighted sum of precomputed modes.

For each mode:

1. Compare the mode direction to the desired control direction.
2. Weight that alignment by current density `rho`.
3. Divide by `1.0 + lambda_penalty`.
4. Add the weighted mode into `(u_x, u_y)`.

This means modes are preferred when they point in the desired direction where
attention mass currently exists.

### `apply_cfl_scaling(u_x, u_y, dt, target_cfl)`

Scales velocity so the timestep is numerically stable:

```python
current_cfl = dt * max_speed
scale = target_cfl / current_cfl
```

If velocity is effectively zero, this returns zero velocity and CFL `0.0`.

### `advect_density_upwind(rho, u_x, u_y, dt, preserve_mass=True)`

Moves density according to the velocity field with an upwind flux scheme.

Key properties:

- Uses periodic wrapping through `np.roll`.
- Clips negative density to zero.
- Renormalizes to preserve the initial mass if `preserve_mass=True`.

This is the core density update:

```text
rho_next = rho - dt * divergence(flux)
```

## The Transport Loop

### `transport_density(rho_initial, params, af_seeds=None, track_history=False)`

This is the main simulation loop.

Setup:

1. Parse goal cells.
2. Build `goal_mask`.
3. Compute distance-to-goal field.
4. Compute static distance cost.
5. Precompute Fourier velocity modes.
6. Copy `rho_initial` into mutable `rho`.

Each timestep:

1. The value field is computed once before the loop (static, since cost depends
   only on distance, not on the evolving density).
2. Compute control direction from `-grad(value)`.
4. Combine divergence-free velocity modes according to control alignment.
5. Apply CFL scaling.
6. Optionally record `rho` in `history`.
7. Advect density.

After the loop:

1. Compute diagnostics.
2. Add `goal_cells` to diagnostics.
3. Return:

```python
rho_final, (u_x, u_y), diagnostics, history
```

## Pulling Density Back to STI

After transport, the normalized grid density must be converted back to atom
values.

### `map_density_to_atoms(rho, spectral_coords, grid_size, radius=1)`

Converts atom spectral coordinates to grid coordinates again, then sums density
in a local square neighborhood around each atom.

The result is:

```python
{atom: local_density}
```

### `pull_density_to_sti(rho, spectral_coords, params, total_sti)`

Converts local atom densities back into STI values:

```python
new_sti[atom] = total_sti * atom_density / total_density
```

This preserves the total transported STI mass. If 240 STI entered the transport
portion, the returned transported atoms sum to 240, aside from floating-point
roundoff.

## MeTTa Integration Entry Point

### `fluid_from_af(...)`

Signature:

```python
fluid_from_af(
    metta_path: str,
    atom_sti_pairs: list[list[Any]],
    grid_size: int = 36,
    num_steps: int = 100,
    dt: float = 0.1,
    af_seeds: str | list[tuple[int, int]] | None = None,
    spread_sigma: float = 1.0,
    target_cfl: float = 0.8,
    control_mode: str = "value_alignment",
) -> list[list[Any]]
```

The current MeTTa integration calls this from `fluid_integration.metta`:

```metta
(py-call (connection.fluid_from_af $graphFile $pairs 70 70 0.9 "69,12"))
```

Those positional arguments mean:

```text
graph file:  $graphFile
STI pairs:   $pairs
grid_size:   70
num_steps:   70
dt:          0.9
af_seeds:    "69,12"
```

`spread_sigma`, `target_cfl`, and `control_mode` use Python defaults unless
passed explicitly.

`fluid_from_af` flow:

1. Convert MeTTa STI pairs to a Python dictionary.
2. Parse graph edges from `metta_path`.
3. Extract graph atoms.
4. Split STI values into:
   - `transport_sti`: atoms present in the graph.
   - `passthrough_sti`: atoms not present in the graph.
5. If no graph atom has positive STI, return only positive pass-through atoms.
6. Build `FluidParams`.
7. Push graph STI values into `rho`.
8. Run `transport_density`.
9. Pull final density back into transported atom STI values.
10. Merge pass-through atoms unchanged.
11. Print diagnostics if enabled.
12. Return positive atom/value pairs.

The pass-through behavior prevents Python from silently dropping STI for AF
atoms that are not represented in the graph file.

## CLI Entry Point

### `main()`

The CLI exists for manual inspection and smoke testing:

```bash
python attention/ImportanceDiffusionAgent/fluidDiffusion/connection.py \
  experiments/data/adagram_sparse_random.metta \
  --grid 24 \
  --steps 5 \
  --seeds center \
  --top 3 \
  --control-mode value_alignment
```

The CLI path:

1. Loads optional STI values from `--sti-json`.
2. Builds `FluidParams`.
3. Parses graph edges.
4. Extracts nodes.
5. Pushes STI or fallback edge-derived weights into `rho`.
6. Runs `transport_density`.
7. Prints diagnostics, final mass, max velocity, and top atoms by final local
   density.

When no `--sti-json` is supplied, initial node weights are derived from mean
outgoing adjacency weights. This makes the CLI usable without MeTTa, but it is
not the normal integration path.

## Diagnostics

### `compute_diagnostics(...)`

Returns:

- `mass_error`: absolute difference between final and initial total density.
- `max_abs_divergence`: maximum absolute divergence in the final velocity.
- `l2_divergence`: L2 norm of final velocity divergence.
- `cfl`: final timestep CFL value.
- `goal_mass`: final density inside the goal mask.
- `expected_distance`: density-weighted distance to goal.
- `expected_value_cost`: density-weighted value cost.

### `print_diagnostics(diagnostics)`

Prints a compact diagnostic line. It skips keys that are missing, so callers can
pass partial diagnostic dictionaries without crashing.

Example:

```text
fluid diagnostics: mass_error=0, max_abs_divergence=1e-15, l2_divergence=4e-15, cfl=0.4, goal_mass=0.52, expected_value_cost=0.1
```

## Control Modes

### `distance`

Uses the raw distance-to-goal field as the value field. This is the simplest
goal-seeking behavior.

### `value_alignment`

Uses `solve_value_field` to compute a Bellman-smoothed value field, then moves
density along `-grad(value)`. The cost is static (distance-based), so the value
field is computed once before the timestep loop.

## Mass Preservation

There are two levels of mass preservation:

1. `rho` is normalized when STI is pushed into the grid.
2. `advect_density_upwind` preserves the total `rho` mass after every timestep.
3. `pull_density_to_sti` scales final atom densities by the original transported
   STI total.

This means the transport layer redistributes STI; it does not mint or destroy
STI for graph atoms. Pass-through atoms keep their original values.

## Why Results Can Look Smoothed

Several pieces intentionally smooth the output:

- Gaussian spreading in `push_sti_to_density`.
- Bellman value iteration in `solve_value_field`.
- Upwind advection in `advect_density_upwind`.
- Local density aggregation in `map_density_to_atoms`.

If many atoms are embedded close together, or if many atoms share similar graph
structure, several atoms may read back similar local density and receive similar
final STI.

Parameters that affect smoothing:

- Lower `spread_sigma` for less initial spread.
- Lower `density_radius` for tighter pullback around each atom.
- Fewer `num_steps` for less transport time.
- Different graph data or randomized/sparser graph structure for more diverse
  embeddings.

## Current Limitations

- The MeTTa parser expects a narrow edge format:
  `((link source target) (mean confidence))`.
- The graph embedding is spectral and may place structurally similar atoms very
  close together.
- `value_alignment` is an approximate grid value-control method, not a full
  continuous HJB/Navier-Stokes solver.
- Velocity is recomputed from control each step rather than evolved through a
  full Navier-Stokes momentum equation.
- ECAN economics happen outside this file.

## Mental Model

Think of each atom as a point on a graph-derived map. STI is poured onto that
map as fluid density. The code creates a wind field that points density toward
goal regions while staying divergence-free. The density moves for several
timesteps. Finally, atoms read how much fluid ended up near their positions,
and that local density is converted back into STI values.

The graph determines the map. The current STI determines where the fluid starts.
The goal/value field determines where the fluid wants to go. The velocity modes
determine how the fluid is allowed to move. MeTTa receives the final proposed
STI redistribution and applies it on the ECAN side.
