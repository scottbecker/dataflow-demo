#!/bin/bash

# --- Configuration ---
PROJECT_ID="maps-346818"
REGION="us-central1"
CLUSTER_NAME="flink-mini-cluster"
BUCKET="dataflow-demo-central-maps"
# ---------------------

BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_DIR="$( dirname "$BIN_DIR" )"

# Activate virtual environment
source "$PROJECT_DIR/.venv/bin/activate"

# Find Master Node
MASTER_NODE=$(gcloud dataproc clusters describe "$CLUSTER_NAME" --region="$REGION" --format='value(config.masterConfig.instanceNames[0])')

if [ -z "$MASTER_NODE" ]; then
    echo "Error: Could not find master node for cluster $CLUSTER_NAME."
    exit 1
fi

ZONE=$(gcloud compute instances list --filter="name:($MASTER_NODE)" --format='value(zone)')

INPUT="gs://$BUCKET/input/sample_logs_*.json"
OUTPUT="gs://$BUCKET/finished_files/results_dataproc"

echo "Submitting JSON to Avro job to Dataproc Flink cluster ($CLUSTER_NAME)..."

# Stage all necessary files to the master node
echo "Staging files to master node..."
gcloud compute scp \
    "$PROJECT_DIR/json_to_avro.py" \
    "$PROJECT_DIR/dataflow_utils.py" \
    "$PROJECT_DIR/bin/remote_run_flink.sh" \
    "$MASTER_NODE":~/ \
    --zone="$ZONE" --project="$PROJECT_ID"

# Execute the remote helper script
echo "Executing remote runner..."
gcloud compute ssh "$MASTER_NODE" \
    --zone="$ZONE" \
    --project="$PROJECT_ID" \
    --command "bash ~/remote_run_flink.sh \"$INPUT\" \"$OUTPUT\""

echo "Job submission attempt complete."
