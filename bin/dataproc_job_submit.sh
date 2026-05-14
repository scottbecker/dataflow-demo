#!/bin/bash
# Submit a job to the dedicated Beam Job Server on Dataproc

PROJECT_ID="maps-346818"
REGION="us-central1"
CLUSTER_NAME="flink-mini-cluster"
BUCKET="dataflow-demo-central-maps"
JOB_PORT=8099

BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_DIR="$( dirname "$BIN_DIR" )"

# Find Master Node
MASTER_NODE=$(gcloud dataproc clusters describe "$CLUSTER_NAME" --region="$REGION" --format='value(config.masterConfig.instanceNames[0])')
ZONE=$(gcloud compute instances list --filter="name:($MASTER_NODE)" --format='value(zone)')

INPUT="gs://$BUCKET/input/sample_logs_*.json"
OUTPUT="gs://$BUCKET/finished_files/results_dataproc"

echo "Submitting job to dedicated Job Server at $MASTER_NODE:$JOB_PORT..."

# Stage files
gcloud compute scp \
    "$PROJECT_DIR/json_to_avro.py" \
    "$PROJECT_DIR/dataflow_utils.py" \
    "$MASTER_NODE":~/ \
    --zone="$ZONE" --project="$PROJECT_ID"

# Execute submission on master
gcloud compute ssh "$MASTER_NODE" --zone="$ZONE" --project="$PROJECT_ID" --command "
    export PATH=\$PATH:\$HOME/.local/bin
    
    # Check if Job Server is alive
    if ! ps -p \$(cat /tmp/beam_job_server.pid 2>/dev/null) > /dev/null; then
        echo \"Error: Job Server is not running! Run dataproc_job_server_start.sh first.\"
        exit 1
    fi

    python3 json_to_avro.py \
        --runner=FlinkRunner \
        --job_endpoint=localhost:$JOB_PORT \
        --environment_type=LOOPBACK \
        --input \"$INPUT\" \
        --output \"$OUTPUT\" \
        --save_main_session
"
