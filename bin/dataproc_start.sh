#!/bin/bash

# --- Configuration ---
PROJECT_ID="maps-346818"
REGION="us-central1"
CLUSTER_NAME="flink-mini-cluster"
# ---------------------

echo "Starting Dataproc cluster: $CLUSTER_NAME..."

gcloud dataproc clusters start "$CLUSTER_NAME" \
    --project="$PROJECT_ID" \
    --region="$REGION"

if [ $? -eq 0 ]; then
    echo "Cluster $CLUSTER_NAME started."
else
    echo "Failed to start cluster $CLUSTER_NAME."
fi
