#!/bin/bash

# --- Configuration ---
PROJECT_ID="maps-346818"
REGION="us-central1"
CLUSTER_NAME="flink-mini-cluster"
# ---------------------

echo "Creating Dataproc cluster: $CLUSTER_NAME in $REGION..."

gcloud dataproc clusters create "$CLUSTER_NAME" \
    --project="$PROJECT_ID" \
    --region="$REGION" \
    --single-node \
    --master-machine-type=e2-standard-2 \
    --image-version=2.2-debian12 \
    --optional-components=FLINK \
    --enable-component-gateway \
    --idle-delete-ttl=1h

if [ $? -eq 0 ]; then
    echo "Cluster $CLUSTER_NAME created successfully."
else
    echo "Failed to create cluster $CLUSTER_NAME."
    exit 1
fi
