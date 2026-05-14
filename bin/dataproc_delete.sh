#!/bin/bash

# --- Configuration ---
PROJECT_ID="maps-346818"
REGION="us-central1"
CLUSTER_NAME="flink-mini-cluster"
# ---------------------

echo "Deleting Dataproc cluster: $CLUSTER_NAME..."

gcloud dataproc clusters delete "$CLUSTER_NAME" \
    --project="$PROJECT_ID" \
    --region="$REGION" \
    --quiet

if [ $? -eq 0 ]; then
    echo "Cluster $CLUSTER_NAME deleted."
else
    echo "Failed to delete cluster $CLUSTER_NAME or it doesn't exist."
fi
