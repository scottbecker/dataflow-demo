#!/bin/bash

# --- Configuration ---
PROJECT_ID="maps-346818"
REGION="us-central1"
CLUSTER_NAME="flink-mini-cluster"
# ---------------------

echo "Stopping Dataproc cluster: $CLUSTER_NAME..."

gcloud dataproc clusters stop "$CLUSTER_NAME" \
    --project="$PROJECT_ID" \
    --region="$REGION"

if [ $? -eq 0 ]; then
    echo "Cluster $CLUSTER_NAME stopped."
else
    echo "Failed to stop cluster $CLUSTER_NAME."
fi
