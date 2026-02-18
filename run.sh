#!/bin/bash
# Allow user to override Python command: PYTHON=python3.10 ./run.sh
PYTHON="${PYTHON:-python3}"

TARGET_DIR="experiments/scripts"
DATA_DIR="experiments/data"
#
# Create the directories if they don't exist                                                                 
mkdir -p "$TARGET_DIR"
mkdir -p "$DATA_DIR"                                                                                         
                                                                                                              
# Download the file                                                                                          
echo "Downloading ConceptNet assertions..."                                                                  
wget -O conceptnet-assertions-5.7.0.csv.gz \
  "https://s3.amazonaws.com/conceptnet/downloads/2019/edges/conceptnet-assertions-5.7.0.csv.gz"              
                                                                                                             
# Extract the file
echo "Extracting..."                                                                                         
gunzip conceptnet-assertions-5.7.0.csv.gz                                                                    

# Move to target directory
echo "Moving to $TARGET_DIR..."
mv conceptnet-assertions-5.7.0.csv "$TARGET_DIR/conceptnet-assertions-5.7.0.csv"
#
# Change to scripts directory
cd "$TARGET_DIR" || exit

# Run Python scripts
echo "Running conceptnet_to_metta.py..."
$PYTHON conceptnet_to_metta.py

echo "Checking for nltk module... with $PYTHON"
if $PYTHON -c "import nltk" 2>/dev/null; then
    echo "nltk found, running wordnet.py..."
    $PYTHON wordnet.py
else
    echo "Error: nltk module not found! to run wordnet.py"
    echo "Please install it with: pip3 install nltk"
    exit 1
fi

echo "Running add_stv_wordnet.py..."
$PYTHON add_stv_wordnet.py

echo "Running add_stv_conceptnet.py..."
$PYTHON add_stv_conceptnet.py

# Move output files to data directory
echo "Moving output files to data directory... from $PWD"
mv conceptnet_stv_clean.metta ../../"$DATA_DIR/"
mv wordnet_stv_clean.metta ../../"$DATA_DIR/"

echo "Done! All tasks completed."                                                                            
