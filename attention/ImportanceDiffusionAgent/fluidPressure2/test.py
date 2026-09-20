import sys
from pathlib import Path

agent_dir = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(agent_dir))

from fluidPressure2.connection import fluid_from_ecan

metta_file = str(agent_dir.parents[1] / "experiments/data/adagram.metta")
# seed dtaa from experiment
sti_data = [
    ["abamectin", 80.0],
    ["aphid",     60.0],
    ["beetle",    45.0],
    ["spider",    30.0],
    ["ants",      25.0],
    ["armyworm",  15.0],
    ["moths",     10.0],
]
lti_data = [
    ["abamectin", 70.0],
    ["aphid",     50.0],
    ["beetle",    20.0],
    ["spider",    10.0],
    ["ants",      10.0],
    ["armyworm",   5.0],
    ["moths",      5.0],
]
#goal atom for the experimet
goal_atoms = ["aphid", "beetle"]
print(" fluidpressure experiment")
print(f"  Goals  : {goal_atoms}")
print(f"  Total STI before : {sum(v for _, v in sti_data):.1f}")
print()

new_sti_data = fluid_from_ecan(
    metta_path=metta_file,
    atom_sti_pairs=sti_data,
    atom_lti_pairs=lti_data,
    goal_seeds=goal_atoms,
    grid_size=64,
    steps=60,
    dt=0.05,
    nu=0.12,
    force_gain=2.0,
    sobolev_mu=0.5,
    goal_strength=1.0,
    use_global_potential=True,
    kernel_sigma=0.5, 
    diagnostics=True,
)

print(f"\n  Total STI after  : {sum(v for _, v in new_sti_data):.3f}")

new_sti_dict = {atom: val for atom, val in new_sti_data}

print("\n  --- STI Before -> After (tracked atoms) ---")
print(f"  {'Atom':<12} {'Before':>8} {'After':>8} {'Change':>8}  Role")
print(f"  {'─'*12} {'─'*8} {'─'*8} {'─'*8}")
for atom, before in sti_data:
    after  = new_sti_dict.get(atom, 0.0)
    delta  = after - before
    role   = "- GOAL" if atom in goal_atoms else ""
    print(f"  {atom:<12} {before:>8.2f} {after:>8.3f} {delta:>+8.3f}  {role}")

print("\n  --- Top 5 atoms across full graph after transport ---")
sorted_sti = sorted(new_sti_data, key=lambda x: x[1], reverse=True)
for atom, sti in sorted_sti[:5]:
    marker = " - GOAL" if atom in goal_atoms else ""
    print(f"  {atom:<16}: {sti:.4f}{marker}")
