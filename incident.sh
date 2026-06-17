#!/bin/bash
# Allow user to override Python command: PYTHON=python3.10 ./run.sh
PYTHON="${PYTHON:-python3}"

TARGET_DIR="experiments/scripts"
DATA_DIR="experiments/data"
#
# Create the directories if they don't exist                                                                 
mkdir -p "$TARGET_DIR"
mkdir -p "$DATA_DIR"                                                                                         
                                                                                                              
# Check if CSV file already exists
if [ -f "$DATA_DIR/conceptnet-assertions-5.7.0.csv" ]; then
    echo "CSV file already exists in $DATA_DIR, skipping download"
else
    # Download the file to data directory
    echo "Downloading ConceptNet assertions..."
    wget -O "$DATA_DIR/conceptnet-assertions-5.7.0.csv.gz" \
      "https://s3.amazonaws.com/conceptnet/downloads/2019/edges/conceptnet-assertions-5.7.0.csv.gz"
    
    # Extract the file in data directory
    echo "Extracting..."
    gunzip "$DATA_DIR/conceptnet-assertions-5.7.0.csv.gz"
fi

# # Copy to target directory if not already there
# if [ ! -f "$TARGET_DIR/conceptnet-assertions-5.7.0.csv" ]; then
#     echo "Copying CSV to $TARGET_DIR..."
#     cp "$DATA_DIR/conceptnet-assertions-5.7.0.csv" "$TARGET_DIR/conceptnet-assertions-5.7.0.csv"
# fi

# Change to scripts directory
cd "$TARGET_DIR" || exit

# Run Python scripts
echo "Running conceptnet_to_metta.py..."
$PYTHON conceptnet_to_metta.py

echo "Checking for nltk module... with $PYTHON"
if $PYTHON -c "import nltk" 2>/dev/null; then
    echo "nltk found, running wordnet.py..."
    $PYTHON wordnet_to_metta.py
else
    echo "Error: nltk module not found! to run wordnet.py"
    echo "Please install it with: pip3 install nltk"
    exit 1
fi

echo "Running add_stv_wordnet.py..."
$PYTHON add_stv_wordnet.py

echo "Running add_stv_conceptnet.py..."
$PYTHON add_stv_conceptnet.py

echo "Done! All tasks completed."                                                                            
