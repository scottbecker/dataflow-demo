#!/bin/bash
# Stop the dedicated Beam Job Server on the Dataproc Master node

PROJECT_ID="maps-346818"
REGION="us-central1"
CLUSTER_NAME="flink-mini-cluster"

# Find Master Node
MASTER_NODE=$(gcloud dataproc clusters describe "$CLUSTER_NAME" --region="$REGION" --format='value(config.masterConfig.instanceNames[0])')
ZONE=$(gcloud compute instances list --filter="name:($MASTER_NODE)" --format='value(zone)')

echo "Stopping Beam Job Server on $MASTER_NODE..."

gcloud compute ssh "$MASTER_NODE" --zone="$ZONE" --project="$PROJECT_ID" --command "
    if [ -f /tmp/beam_job_server.pid ]; then
        PID=\$(cat /tmp/beam_job_server.pid)
        if ps -p \$PID > /dev/null; then
            echo \"Killing Job Server (PID: \$PID)...\"
            kill \$PID
            rm /tmp/beam_job_server.pid
        else
            echo \"Job Server not running (stale PID).\"
            rm /tmp/beam_job_server.pid
        fi
    else
        echo \"No Job Server PID file found.\"
        # Fallback to pgrep
        PID=\$(pgrep -f beam-runners-flink-.*-job-server)
        if [ ! -z \"\$PID\" ]; then
            echo \"Found Job Server via pgrep (PID: \$PID). Killing...\"
            kill \$PID
        fi
    fi
"
