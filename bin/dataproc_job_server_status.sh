#!/bin/bash
# Check the status of the dedicated Beam Job Server on the Dataproc Master node

PROJECT_ID="maps-346818"
REGION="us-central1"
CLUSTER_NAME="flink-mini-cluster"
JOB_PORT=8099

# Find Master Node
MASTER_NODE=$(gcloud dataproc clusters describe "$CLUSTER_NAME" --region="$REGION" --format='value(config.masterConfig.instanceNames[0])')
ZONE=$(gcloud compute instances list --filter="name:($MASTER_NODE)" --format='value(zone)')

echo "Checking Beam Job Server status on $MASTER_NODE..."

gcloud compute ssh "$MASTER_NODE" --zone="$ZONE" --project="$PROJECT_ID" --command "
    PID_FILE=\"/tmp/beam_job_server.pid\"
    LOG_FILE=\"/tmp/beam_job_server.log\"
    
    RUNNING=false
    PID=\"\"

    if [ -f \"\$PID_FILE\" ]; then
        PID=\$(cat \"\$PID_FILE\")
        if ps -p \$PID > /dev/null; then
            RUNNING=true
        fi
    fi

    # Fallback to pgrep if PID file is missing or stale
    if [ \"\$RUNNING\" = false ]; then
        PID=\$(pgrep -f beam-runners-flink-.*-job-server)
        if [ ! -z \"\$PID\" ]; then
            RUNNING=true
        fi
    fi

    if [ \"\$RUNNING\" = true ]; then
        echo \"STATUS: RUNNING\"
        echo \"PID: \$PID\"
        echo \"Endpoint: localhost:$JOB_PORT\"
        echo \"--- Last 10 lines of log ---\"
        tail -n 10 \"\$LOG_FILE\" 2>/dev/null || echo \"(Log file not found)\"
    else
        echo \"STATUS: NOT RUNNING\"
    fi
"
