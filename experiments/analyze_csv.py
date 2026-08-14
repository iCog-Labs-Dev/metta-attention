import csv
import json
import os
import glob
from pathlib import Path

# Directories
dirs = {
    'random-1': '/home/abel/Desktop/icog_labs/ECAN/metta-attention/experiments/output/random-goal-expt-v1/',
    'random-2': '/home/abel/Desktop/icog_labs/ECAN/metta-attention/experiments/output/random-goal-expt-v2/',
    'seq-1': '/home/abel/Desktop/icog_labs/ECAN/metta-attention/experiments/output/2-goal-mettaclaw-expt-v1/',
    'seq-2': '/home/abel/Desktop/icog_labs/ECAN/metta-attention/experiments/output/2-goal-mettaclaw-expt-v2/',
    'seq-3': '/home/abel/Desktop/icog_labs/ECAN/metta-attention/experiments/output/2-goal-mettaclaw-expt-v3/',
    'concur-1': '/home/abel/Desktop/icog_labs/ECAN/metta-attention/experiments/output/2-goal-concur-mettaclaw-expt-v1/',
    'concur-2': '/home/abel/Desktop/icog_labs/ECAN/metta-attention/experiments/output/2-goal-concur-mettaclaw-expt-v2/',
    'concur-3': '/home/abel/Desktop/icog_labs/ECAN/metta-attention/experiments/output/2-goal-concur-mettaclaw-expt-v3/'
}

metrics_list = ['af_resource', 'context_retention', 'cognitive_synergy', 'modulation', 
                'coordination', 'link_density', 'connection_ratio', 'triangle_count', 
                'betti0', 'betti1', 'effectiveness', 'cognitive_maintenance']

results = {}

out_md = []
out_md.append("# Experiment Comparison Analysis\n\n")

for name, d in dirs.items():
    res = {'name': name, 'type': 'random' if 'random' in name else ('seq' if 'seq' in name else 'concur')}
    
    # settings
    try:
        with open(os.path.join(d, 'settings.json')) as f:
            res['settings'] = json.load(f)
    except Exception as e:
        res['settings'] = {}
        
    # output.csv
    goals = []
    try:
        with open(os.path.join(d, 'output.csv')) as f:
            reader = csv.DictReader(f)
            # Find goal column if it exists
            goal_col = None
            if reader.fieldnames:
                if 'goal' in reader.fieldnames: goal_col = 'goal'
                elif 'goals' in reader.fieldnames: goal_col = 'goals'
            
            if goal_col:
                for row in reader:
                    if row.get(goal_col):
                        goals.append(row[goal_col])
    except Exception as e:
        pass
    res['goals'] = goals
        
    # metrics.csv
    try:
        metrics_data = {m: [] for m in metrics_list}
        cycles = 0
        with open(os.path.join(d, 'metrics.csv')) as f:
            reader = csv.DictReader(f)
            # Clean headers
            headers = {h.strip(): h for h in reader.fieldnames}
            for row in reader:
                cycles += 1
                for m in metrics_list:
                    orig_h = headers.get(m)
                    if orig_h and orig_h in row and row[orig_h]:
                        try:
                            val = float(row[orig_h])
                            metrics_data[m].append(val)
                        except ValueError:
                            pass
        
        res['cycles'] = cycles
        metrics_stats = {}
        for m in metrics_list:
            data = metrics_data[m]
            if data:
                mean_val = sum(data) / len(data)
                min_val = min(data)
                max_val = max(data)
                final_val = data[-1]
                if len(data) > 1:
                    if final_val > data[0]:
                        trend = 'increasing'
                    elif final_val < data[0]:
                        trend = 'decreasing'
                    else:
                        trend = 'flat'
                else:
                    trend = 'flat'
                
                metrics_stats[m] = {
                    'mean': mean_val,
                    'min': min_val,
                    'max': max_val,
                    'final': final_val,
                    'trend': trend
                }
        res['metrics'] = metrics_stats
    except Exception as e:
        res['cycles'] = 0
        res['metrics'] = {}
        
    results[name] = res

# Detailed per experiment
out_md.append("## Per-Experiment Details\n\n")
for name, res in results.items():
    out_md.append(f"### {name}\n")
    out_md.append(f"- **Total Cycles**: {res['cycles']}\n")
    if res['goals']:
        out_md.append(f"- **Goals Picked**: {res['goals']}\n")
        unique_goals = set(res['goals'])
        out_md.append(f"- **Unique Goals**: {list(unique_goals)}\n")
        out_md.append(f"- **Repeated Goals**: {'Yes' if len(res['goals']) > len(unique_goals) else 'No'}\n")
    else:
        out_md.append(f"- **Goals Picked**: None/Not applicable\n")
        
    if res['settings']:
        out_md.append(f"- **Settings Highlights**: {res['settings']}\n")
        
    out_md.append("- **Metrics**:\n")
    for m in metrics_list:
        if m in res['metrics']:
            stat = res['metrics'][m]
            out_md.append(f"  - `{m}`: Mean: {stat['mean']:.4f}, Min: {stat['min']:.4f}, Max: {stat['max']:.4f}, Final: {stat['final']:.4f}, Trend: {stat['trend']}\n")
    out_md.append("\n")

# Cross-experiment comparisons
out_md.append("## Cross-Experiment Comparison\n\n")

def get_avg(res_dict, mtype, metric, stat):
    vals = [r['metrics'][metric][stat] for r in res_dict.values() if r['type'] == mtype and metric in r['metrics']]
    return sum(vals)/len(vals) if vals else 0

out_md.append("### Cognitive Synergy (Best Average)\n")
for t in ['random', 'seq', 'concur']:
    val = get_avg(results, t, 'cognitive_synergy', 'mean')
    out_md.append(f"- **{t}**: {val:.4f}\n")

out_md.append("\n### Context Retention (Stability)\n")
for t in ['random', 'seq', 'concur']:
    val = get_avg(results, t, 'context_retention', 'mean')
    out_md.append(f"- **{t}**: {val:.4f}\n")

out_md.append("\n### Link Density Growth (Fastest Growing / Final Value)\n")
for t in ['random', 'seq', 'concur']:
    val = get_avg(results, t, 'link_density', 'final')
    out_md.append(f"- **{t} final avg**: {val:.4f}\n")

out_md.append("\n### Modulation & Coordination\n")
for t in ['random', 'seq', 'concur']:
    m_val = get_avg(results, t, 'modulation', 'mean')
    c_val = get_avg(results, t, 'coordination', 'mean')
    out_md.append(f"- **{t}**: Modulation={m_val:.4f}, Coordination={c_val:.4f}\n")

# Mettaclaw vs Random
out_md.append("\n### Mettaclaw vs Random Summary\n")
out_md.append("- **Did Mettaclaw outperform random?**: Look at cognitive synergy, modulation, coordination.\n")
# We let the LLM or user interpret the numbers for the final analysis
synergy_random = get_avg(results, 'random', 'cognitive_synergy', 'mean')
synergy_seq = get_avg(results, 'seq', 'cognitive_synergy', 'mean')
synergy_concur = get_avg(results, 'concur', 'cognitive_synergy', 'mean')

mod_random = get_avg(results, 'random', 'modulation', 'mean')
mod_seq = get_avg(results, 'seq', 'modulation', 'mean')
mod_concur = get_avg(results, 'concur', 'modulation', 'mean')

out_md.append(f"  - Synergy: Random ({synergy_random:.4f}) vs Seq ({synergy_seq:.4f}) vs Concur ({synergy_concur:.4f})\n")
out_md.append(f"  - Modulation: Random ({mod_random:.4f}) vs Seq ({mod_seq:.4f}) vs Concur ({mod_concur:.4f})\n")

out_md.append("\n### Concurrent vs Sequential Summary\n")
out_md.append("- **Did concurrent outperform sequential?**\n")
out_md.append(f"  - Synergy: Seq ({synergy_seq:.4f}) vs Concur ({synergy_concur:.4f})\n")
out_md.append(f"  - Modulation: Seq ({mod_seq:.4f}) vs Concur ({mod_concur:.4f})\n")


# Write to file
target_file = '/home/abel/.gemini/antigravity-cli/brain/0789e2e0-c0c4-4c07-b18e-ba6fd42dd1aa/experiment_comparison.md'
os.makedirs(os.path.dirname(target_file), exist_ok=True)
with open(target_file, 'w') as f:
    f.write(''.join(out_md))

print(f"Artifact written to {target_file}")
