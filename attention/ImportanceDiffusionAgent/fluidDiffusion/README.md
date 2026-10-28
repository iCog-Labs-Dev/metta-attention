# Fluid-attention diffusion guide

This directory implements a bridge between ECAN's atom-level short-term
importance (STI) and a two-dimensional fluid transport model. MeTTa remains
the owner of atom state. Python temporarily interprets positive STI as fluid
mass, transports that mass, and returns a proposed atom/STI redistribution.

## End-to-end path

```text
MeTTa atoms in the attentional focus
        |
        | extractStiPairs: (atom, getSti(atom))
        v
Python atom/STI pairs --------------------------+
        |                                       |
        | keep atoms found in graph             | atoms absent from graph
        v                                       | pass through unchanged
MeTTa link file -> edge tuples -> adjacency     |
        |                                       |
        v                                       |
magnetic-Laplacian coordinates -> grid cells    |
        |                                       |
        v                                       |
Gaussian STI push -> normalized density rho     |
        |                                       |
        v                                       |
goal/value field -> stream-function modes       |
        |              -> divergence-free flow  |
        v                                       |
upwind density transport                        |
        |                                       |
        v                                       |
local density around each atom                  |
        |                                       |
        v                                       |
rescale by original transported STI total ------+
        |
        v
MeTTa applyNewStis -> setSti(atom, new_sti)
```

## Reading order

1. [Atoms to graph and grid](01-atoms-to-graph.md) explains parsing, the
   weighted adjacency matrix, spectral embedding, and grid coordinates.
2. [STI to density](02-sti-to-density.md) explains the MeTTa/Python boundary
   and the Gaussian push that creates `rho`.
3. [Stream functions and non-divergence](03-stream-functions-and-non-divergence.md)
   explains how velocity modes are created, combined, and verified.
4. [Applying flow to density](04-applying-flow-to-density.md) explains goals,
   the value/control field, CFL scaling, and the upwind update.
5. [Density back to STI](05-density-to-sti-and-metta.md) explains atom-level
   sampling, STI-total preservation, pass-through atoms, and `setSti`.

The older [connection flow reference](connection_flow.md) is a longer
single-file description. The files above are the focused guide to the current
implementation.

## Source map

| File | Responsibility |
| --- | --- |
| `fluid_integration.metta` | Read current AF/STI state, call Python, apply returned STI |
| `connection.py` | Public bridge and end-to-end orchestration |
| `graph.py` | Parse links, build adjacency, embed atoms, assign grid cells |
| `density.py` | Push STI into `rho`; pull `rho` back into STI |
| `goals.py` | Resolve goals and create distance, cost, value, and control fields |
| `transport.py` | Create incompressible modes, construct velocity, advect density |
| `cache.py` | Cache graph embedding and velocity modes |
| `params.py` | Numerical and control parameters |
| `render.py` | Optional animation only; not part of the state update |

## Core representations

| Stage | Python representation | Meaning |
| --- | --- | --- |
| Parsed link | `(source, target, mean, confidence)` | Directed weighted MeTTa relation |
| Graph weight | `mean * confidence` | Adjacency entry |
| Atom position | `{atom: (spectral_x, spectral_y)}` | Continuous graph-derived embedding |
| Grid position | `{atom: (grid_x, grid_y)}` | Cell used for density push/pull |
| Density | `rho[grid_y, grid_x]` | Normalized, nonnegative fluid mass |
| Velocity | `(u_x, u_y)` arrays | Divergence-free flow on the periodic grid |
| Returned state | `[[atom, sti], ...]` | Values that MeTTa applies with `setSti` |

## Important boundaries

- The graph embedding determines **where** atoms lie; it does not read or
  mutate STI.
- STI determines the initial density distribution; it does not alter the
  graph embedding.
- Goal atoms determine the desired direction of transport through a value
  field; they are not sinks that delete mass.
- Python returns values but does not directly own ECAN state. The actual write
  occurs in `applyNewStis` on the MeTTa side.
- The grid is periodic (toroidal): indexing, distances, derivatives, and
  transport wrap at every boundary.

