#!/bin/zsh
cd  /home/blightg/Documents/Icog/metta-attention/ || exit
source .venv/bin/activate
python3.10 experiments/plot.py experiments/Metta/experiment2/output/output.csv
LATEST_PLOT=$(ls -t experiments/Metta/experiment2/output/plot_faceted_*.png | head -n 1)
wslview $LATEST_PLOT
cp "$LATEST_PLOT" ../ecan/png/

