#!/bin/bash
# Run the Beam pipeline locally using DirectRunner

BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_DIR="$( dirname "$BIN_DIR" )"
OUTPUT_DIR="$PROJECT_DIR/output"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "Running JSON to Avro pipeline locally..."
echo "Input: $PROJECT_DIR/sample_logs_*.json"
echo "Output: $OUTPUT_DIR/results"

python3 "$PROJECT_DIR/json_to_avro.py" \
    --runner=DirectRunner \
    --input "$PROJECT_DIR/sample_logs_*.json" \
    --output "$OUTPUT_DIR/results"

echo ""
echo "Files in output directory:"
ls -lh "$OUTPUT_DIR"
