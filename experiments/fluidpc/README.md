# FluidPC: Discriminative Fluid Predictive Coding on MNIST

`fluidPc.py` is a practical Fluid Predictive Coding Network (Fluid-PCN)
experiment for MNIST digit classification. The experiment treats the hidden
state as a conserved activation density on a `28 x 28` periodic grid and learns
to route that density into one of ten class-specific target regions.

The goal is not to solve the full Hamilton-Jacobi-Bellman equation exactly.
Instead, the code implements a finite-grid, task-driven approximation that
combines predictive coding, a learned value-like cost map, and incompressible
fluid transport.

## Experiment Idea

The model starts with a small amount of unit-mass hidden activation in the
center of the image grid. Each digit image is encoded into this central source
region, but the classifier cannot directly read the whole grid. It only reads
how much mass arrives in ten small target regions arranged around the center,
one region per digit class.

To solve the task, the model must learn how to move conserved mass from the
source region to the target region associated with the correct digit.

The main ingredients are:

- **Predictive coding reaction:** updates the hidden density using a local
  neighborhood predictor.
- **Conserved activation density:** every sample is normalized to unit mass.
- **Learned value map:** predicts a distance-to-goal style cost map for the
  current image and class target.
- **Stream-function fluid controller:** predicts a scalar stream function
  `psi`; velocity is computed as `u = (d psi / dy, -d psi / dx)`, which makes
  the flow divergence-free by construction.
- **Conservative upwind advection:** transports density while preserving mass.
- **CFL control:** rescales velocity to a target Courant number for stable
  transport.
- **Routing bottleneck:** classification uses only mass delivered to the ten
  class regions.

## Code Structure

The experiment lives in one script:

```text
experiments/fluidpc/
|-- fluidPc.py      # Fluid-PCN MNIST experiment
`-- README.md       # This file
```

Inside `fluidPc.py`:

- `Config`: all training, inference, fluid, and loss hyperparameters.
- Density utilities:
  - `normalize_density`
  - `ddx`, `ddy`, `laplacian`
  - `advect_upwind`
  - `transport_step`
- Fluid operators:
  - `velocity_from_stream`
  - `divergence`
  - `cfl_number`
  - `scale_velocity_to_cfl`
- Routing geometry:
  - `make_routing_geometry`
  - central source mask
  - ten target masks
  - class distance maps
- `FluidPCN`: the neural model, containing:
  - `source_encoder`
  - `pc_local`
  - `value_encoder`
  - `stream_controller`
  - `region_logits`
- Inference and training:
  - `infer_density`
  - `train_batch`
  - `evaluate`
  - `make_loader`
  - `make_optimizers`
- CLI entry point:
  - `parse_args`
  - `config_from_args`
  - `main`

## Setup

From the repository root:

```sh
cd /home/yeabsira/metta-attention
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirments.txt
pip install torch torchvision
```

`fluidPc.py` downloads MNIST automatically through `torchvision` into `./data`
relative to the directory where the command is run.

The script uses CUDA when available:

```python
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")
```

If the script fails with `ModuleNotFoundError: No module named 'torch'`, install
the PyTorch dependencies:

```sh
pip install torch torchvision
```

## How To Run

Run a quick smoke test:

```sh
python experiments/fluidpc/fluidPc.py --smoke_test
```

Run the default experiment:

```sh
python experiments/fluidpc/fluidPc.py
```

The default CLI configuration is:

```text
epochs=5
batch_size=128
train_subset=40000
test_subset=10000
infer_steps=20
hidden_lr=40.0
control_horizon=5
dt=0.5
target_cfl=0.35
diffusion_start=0.015
pc_lr=2e-3
value_lr=2e-3
flow_lr=2e-3
```

Run a smaller experiment:

```sh
python experiments/fluidpc/fluidPc.py \
  --epochs 1 \
  --train_subset 2000 \
  --test_subset 500
```

Run an ablation with fluid transport disabled:

```sh
python experiments/fluidpc/fluidPc.py \
  --epochs 1 \
  --train_subset 2000 \
  --test_subset 500 \
  --disable_flow
```

## Useful CLI Options

- `--epochs`: number of training epochs.
- `--batch_size`: batch size for training and testing.
- `--train_subset`: number of MNIST training samples to use.
- `--test_subset`: number of MNIST test samples to use.
- `--infer_steps`: number of predictive-coding and transport inference steps.
- `--hidden_lr`: hidden-state update rate during inference.
- `--control_horizon`: short rollout length used for flow training.
- `--target_cfl`: target Courant number for stable advection.
- `--diffusion_start`: initial diffusion strength before annealing.
- `--disable_flow`: disables learned fluid transport for ablation.
- `--smoke_test`: runs a fast correctness check.

## Log Field Meaning

Training lines have the form:

```text
epoch=5 batch=120 E=1.5916 pc=0.000001 V=0.0004 ce=0.8859 shape=0.3526 acc=100.0% mass_err=2.4e-07 div=3.0e-09 cfl=0.350
```

- `E`: total weighted free-energy style objective.
- `pc`: predictive coding reconstruction/reaction loss.
- `V`: learned value-map mean squared error.
- `ce`: cross-entropy classification loss from target-region mass.
- `shape`: distance-to-goal shaping objective.
- `acc`: batch classification accuracy.
- `mass_err`: maximum mass conservation error during inference.
- `div`: RMS divergence of the velocity field.
- `cfl`: mean Courant number after velocity scaling.

## Reported Results

The run below reached a best test accuracy of **98.84%** after 5 epochs.

```text
epoch=4 test_acc=98.70% best=98.70% mass_err=2.19e-07 div=3.00e-09 cfl=0.350
epoch=5 test_acc=98.84% best=98.84% mass_err=2.22e-07 div=2.95e-09 cfl=0.350
```

Observed behavior from the provided training log:

- Batch accuracy in epochs 4 and 5 is usually between `98.4%` and `100.0%`.
- Test accuracy improves from `98.70%` at epoch 4 to `98.84%` at epoch 5.
- Mass conservation remains very tight, around `1e-7` to `2e-7`.
- Flow divergence remains near zero, around `3e-9`, confirming that the
  stream-function construction keeps the velocity effectively incompressible.
- The CFL value stays locked at the configured stability target, `0.350`.
- The total energy and cross-entropy trend downward through epoch 5, showing
  continued learning.

These results suggest that the learned incompressible flow can route conserved
hidden mass to the correct class regions while maintaining numerical stability.
