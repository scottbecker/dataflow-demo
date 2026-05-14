#!/bin/bash
# Start a dedicated Beam Job Server on the Dataproc Master node

PROJECT_ID="maps-346818"
REGION="us-central1"
CLUSTER_NAME="flink-mini-cluster"
BEAM_VERSION="2.73.0"
FLINK_VER="1.17"
JOB_PORT=8099

# Find Master Node
MASTER_NODE=$(gcloud dataproc clusters describe "$CLUSTER_NAME" --region="$REGION" --format='value(config.masterConfig.instanceNames[0])')
ZONE=$(gcloud compute instances list --filter="name:($MASTER_NODE)" --format='value(zone)')

echo "Starting dedicated Beam Job Server on $MASTER_NODE:$JOB_PORT..."

gcloud compute ssh "$MASTER_NODE" --zone="$ZONE" --project="$PROJECT_ID" --command "
    JAR_PATH=\$HOME/.apache_beam/cache/jars/beam-runners-flink-${FLINK_VER}-job-server-${BEAM_VERSION}.jar
    
    # Ensure JAR exists
    if [ ! -f \"\$JAR_PATH\" ]; then
        echo \"Downloading Beam Job Server JAR...\"
        mkdir -p \"\$HOME/.apache_beam/cache/jars\"
        curl -L \"https://repo.maven.apache.org/maven2/org/apache/beam/beam-runners-flink-${FLINK_VER}-job-server-${BEAM_VERSION}/beam-runners-flink-${FLINK_VER}-job-server-${BEAM_VERSION}.jar\" -o \"\$JAR_PATH\"
    fi

    # Kill existing if running
    if [ -f /tmp/beam_job_server.pid ]; then
        PID=\$(cat /tmp/beam_job_server.pid)
        if ps -p \$PID > /dev/null; then
            echo \"Stopping existing Job Server (PID: \$PID)...\"
            kill \$PID
            sleep 2
        fi
    fi

    echo \"Launching Job Server...\"
    nohup java -jar \"\$JAR_PATH\" \
        --flink-master http://\$(hostname):8081 \
        --job-port $JOB_PORT \
        --artifact-port 0 \
        --expansion-port 0 > /tmp/beam_job_server.log 2>&1 &
    
    echo \$! > /tmp/beam_job_server.pid
    echo \"Job Server started with PID: \$!\"
    echo \"Logs: /tmp/beam_job_server.log\"
"
