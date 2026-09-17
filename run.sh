#!/bin/bash
# Downloads the ConceptNet knowledge base and builds the fluid-diffusion graph
# (kg_full_graph.metta) so experiments can run with no manual setup.

set -e
# Allow overriding the Python command: PYTHON=python3.10 ./run.sh
PYTHON="${PYTHON:-python3}"

DATA_DIR="experiments/data"

# 1. Download the ConceptNet knowledge base (kg.metta, ~264MB, git-ignored)
if [ -f "$DATA_DIR/kg.metta" ]; then
    echo "kg.metta already exists in $DATA_DIR, skipping download"
else
    echo "Downloading ConceptNet knowledge base (kg.metta)..."
    curl -L -o "$DATA_DIR/kg.metta" \
      "https://github.com/iCog-Labs-Dev/metta-attention/releases/download/0.1.1/kg.metta"
fi

# 2. Build the fluid-diffusion graph (kg_full_graph.metta) from kg.metta
if [ -f "$DATA_DIR/kg_full_graph.metta" ]; then
    echo "kg_full_graph.metta already exists in $DATA_DIR, skipping generation"
else
    echo "Generating fluid diffusion graph (kg_full_graph.metta)..."
    "$PYTHON" experiments/scripts/generate_test_graph.py \
      --input "$DATA_DIR/kg.metta" \
      -o "$DATA_DIR/kg_full_graph.metta" \
      --num-edges 4000000 \
      --weight-strategy random \
      --seed 42
fi

echo "Done! Data files are ready."
