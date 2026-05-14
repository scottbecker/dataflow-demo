#!/bin/bash

# --- Configuration ---
PROJECT_ID="maps-346818"
REGION="us-central1"
# We use the bucket identified in the previous run
BUCKET="gcp_dataflow_test"
# ---------------------

# Get absolute paths
BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_DIR="$( dirname "$BIN_DIR" )"

# Check for virtual environment
if [ ! -d "$PROJECT_DIR/.venv" ]; then
    echo "Error: Virtual environment (.venv) not found in $PROJECT_DIR."
    echo "Please ensure you have run the local setup first."
    exit 1
fi

# Activate virtual environment
source "$PROJECT_DIR/.venv/bin/activate"

echo "Submitting WordCount job to Google Cloud Dataflow..."
echo "Project: $PROJECT_ID"
echo "Region:  $REGION"
echo "Runner:  DataflowRunner (Dataflow Prime enabled)"

# Run the pipeline
# --dataflow_service_options="enable_prime" switches the job to Dataflow Prime
python3 "$PROJECT_DIR/word_count.py" \
    --runner DataflowRunner \
    --project "$PROJECT_ID" \
    --region "$REGION" \
    --temp_location "gs://$BUCKET/temp/" \
    --staging_location "gs://$BUCKET/staging/" \
    --output "gs://$BUCKET/results/outputs" \
    --dataflow_service_options="enable_prime" \
    --machine_type e2-medium \
    --save_main_session

if [ $? -eq 0 ]; then
    echo "--------------------------------------------------------"
    echo "Job submitted successfully!"
    echo "Check the Dataflow console to monitor progress."
else
    echo "--------------------------------------------------------"
    echo "Error: Failed to submit Dataflow job."
    exit 1
fi
