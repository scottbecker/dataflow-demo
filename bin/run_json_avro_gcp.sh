#!/bin/bash

# --- Configuration ---
PROJECT_ID="maps-346818"
REGION="us-central1"
ZONE="us-central1-a"
BUCKET="dataflow_demo_data"
# ---------------------

BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_DIR="$( dirname "$BIN_DIR" )"

source "$PROJECT_DIR/.venv/bin/activate"

INPUT="gs://$BUCKET/input/sample_logs_*.json"
OUTPUT="gs://$BUCKET/finished_files/results"

echo "Submitting JSON to Avro job to Dataflow..."

python3 "$PROJECT_DIR/json_to_avro.py" \
    --runner DataflowRunner \
    --project "$PROJECT_ID" \
    --region "$REGION" \
    --zone "$ZONE" \
    --temp_location "gs://$BUCKET/temp/" \
    --staging_location "gs://$BUCKET/staging/" \
    --input "$INPUT" \
    --output "$OUTPUT" \
    --setup_file "$PROJECT_DIR/setup.py" \
    --save_main_session

echo "Job submitted. Check Dataflow console."
