#!/bin/bash

# Get the directory where the script is located
BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_DIR="$( dirname "$BIN_DIR" )"

# Check if .venv exists
if [ ! -d "$PROJECT_DIR/.venv" ]; then
    echo "Error: Virtual environment (.venv) not found in $PROJECT_DIR."
    echo "Please ensure you have set up the environment first."
    exit 1
fi

# Activate virtual environment
source "$PROJECT_DIR/.venv/bin/activate"

# Default output if none provided
OUTPUT_FILE="${1:-outputs}"

echo "Running Dataflow 'Hello World' (WordCount) locally..."
python3 "$PROJECT_DIR/word_count.py" --output "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo "Success! Output written to ${OUTPUT_FILE}-00000-of-00001"
else
    echo "Error: Pipeline failed."
    exit 1
fi
