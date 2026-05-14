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

# We need the Flink master URL. For Dataproc single-node, it's the master node's name or IP on port 8081.
# We'll try to get the master node name.
MASTER_NODE=$(gcloud dataproc clusters describe "$CLUSTER_NAME" --region="$REGION" --format='value(config.masterConfig.instanceNames[0])')

if [ -z "$MASTER_NODE" ]; then
    echo "Error: Could not find master node for cluster $CLUSTER_NAME."
    exit 1
fi

# Get the IP of the master node
MASTER_IP=$(gcloud compute instances describe "$MASTER_NODE" --zone="${REGION}-a" --format='value(networkInterfaces[0].networkIP)' 2>/dev/null)
# Note: Zone might vary, but for single-node in us-central1 it's likely us-central1-a or similar. 
# We'll try to detect the zone if possible or just use the name if internal DNS works.
# For simplicity, let's try the node name first.

INPUT="gs://$BUCKET/input/sample_logs_*.json"
OUTPUT="gs://$BUCKET/finished_files/results_dataproc"

echo "Submitting JSON to Avro job to Dataproc Flink cluster ($CLUSTER_NAME)..."

# To run on Flink, we use the FlinkRunner.
# We'll copy the project files to the master node and run it there.

echo "Staging files to master node..."
ZONE=$(gcloud compute instances list --filter="name:($MASTER_NODE)" --format='value(zone)')

gcloud compute scp "$PROJECT_DIR/json_to_avro.py" "$PROJECT_DIR/dataflow_utils.py" "$MASTER_NODE":~/ --zone="$ZONE" --project="$PROJECT_ID"

echo "Running job on master node..."
gcloud compute ssh "$MASTER_NODE" --zone="$ZONE" --command "
    # Ensure Flink is started
    if ! pgrep -f standalonesession > /dev/null; then
        echo 'Starting Flink standalone cluster...'
        sudo /usr/lib/flink/bin/start-cluster.sh
        sleep 10
    fi

    # Install dependencies
    pip install --user --break-system-packages apache-beam[gcp] fastavro
    
    # Run the pipeline using the Flink runner pointing to the master node name
    export PATH=\$PATH:\$HOME/.local/bin
    python3 json_to_avro.py \
        --runner FlinkRunner \
        --flink_master $MASTER_NODE:8081 \
        --input $INPUT \
        --output $OUTPUT \
        --save_main_session
" --project "$PROJECT_ID"

echo "Job submission attempt complete."
