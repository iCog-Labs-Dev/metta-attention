# fluidPressure

Attention allocation implementation via **incompressible fluid dynamics** and **optimal control**.

Attention is treated as a conserved density ρ advected by a divergence-free velocity field u, where u is derived from a Hamilton–Jacobi–Bellman (HJB) equation on the group of volume-preserving diffeomorphisms SDiff(M).

---

## Core idea

Think of an attention like a fixed amount of water you can pour around a landscape of ideas. You want that water to flow to the most useful places without creating or destroying water.

- **ρ(t, x)** — attention density on a learned manifold M of the AtomSpace. Total ∫ρ dx is conserved (budget constraint).
- **u(t, x)** — divergence-free velocity field. Derived from the optimal policy U\* = −∇_SG W, where W solves HJB on SDiff(M).
- **p** — Leray pressure. Acts as a shadow price for attention congestion; prevents over-accumulation.
- **ν(x)** — spatially varying viscosity from LTI. High-LTI atoms get lower ν (stickier, habit channels); low-LTI atoms get higher ν (more exploratory).
- **f_V** — body force from the goal potential V. Steers flow toward Attentional Focus seeds.

The full pipeline :

```
STI  →  push to grid ρ
                │
        [Fluid transport]
         1. Build goal potential V     
         2. Backward HJB → W           
            Cole-Hopf: Φ_τ = νΔΦ + (V/2ν)Φ
            W = -2ν ln Φ,  U* = -∇_SG W
         3. LTI → viscosity ν(x)       
         4. NS time steps               
            ∂_t u + (u·∇)u = -∇p + ∇·(ν∇u) + f_V
            ∂_t ρ + ∇·(ρu) = 0
         5. Optional AF cap             
                │
        pull ρ back to atom STI
                │
             STI_new
```


## Key parameters

| Parameter | Default | Effect |
|---|---|---|
| `nu` | 0.12 | Viscosity ν₀. Lower → sharper credit lines. Higher → diffusive spread. |
| `force_gain` | 1.0 | Gain on HJB body force f_V. Higher → stronger goal steering. |
| `sobolev_mu` | 0.5 | Sobolev smoothing of U\*. 0 = plain gradient; higher = smoother policy. |
| `steps` | 100 | NS time steps per cycle. More steps → mass travels further toward goal. |
| `hjb_steps` | 35 | Cole-Hopf backward integration steps. More → W converges closer to true value. |
| `hjb_dt` | None | HJB sub-step (decoupled from NS dt). None → min(dt, 0.05). |
| `lti_viscosity_strength` | 0.65 | γ_lti: how strongly LTI suppresses ν. 0 = uniform ν; 1 = full habit channel. |
| `use_global_potential` | True | True = toroidal distance cone V; False = Gaussian blobs at goal cells. |
| `goal_strength` | 1.0 | Peak value of the reward field V. |
| `af_cap` | None | Per-cell density shape cap (water-filling, mass conserved). None = off. |
