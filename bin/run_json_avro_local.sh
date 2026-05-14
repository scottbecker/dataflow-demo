#!/bin/bash
BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_DIR="$( dirname "$BIN_DIR" )"

source "$PROJECT_DIR/.venv/bin/activate"

INPUT="$PROJECT_DIR/sample_logs_*.json"
OUTPUT="$PROJECT_DIR/processed/local_output"

echo "Running JSON to Avro conversion locally..."
python3 "$PROJECT_DIR/json_to_avro.py" \
    --input "$INPUT" \
    --output "$OUTPUT"

echo "Check $PROJECT_DIR for local_output_avro files."
