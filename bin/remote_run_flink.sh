#!/bin/bash
# Helper script to be run on the Dataproc Master node

BEAM_VERSION="2.73.0"
FLINK_VER="1.17"
JAR_PATH="$HOME/.apache_beam/cache/jars/beam-runners-flink-${FLINK_VER}-job-server-${BEAM_VERSION}.jar"
LIB_DIR="/usr/lib/flink/lib"
NEEDS_RESTART=false

# 1. Ensure Beam JAR is in Flink lib for metrics
if [ ! -f "$JAR_PATH" ]; then
    echo "Downloading Beam Flink Runner JAR..."
    mkdir -p "$HOME/.apache_beam/cache/jars"
    curl -L "https://repo.maven.apache.org/maven2/org/apache/beam/beam-runners-flink-${FLINK_VER}-job-server-${BEAM_VERSION}/beam-runners-flink-${FLINK_VER}-job-server-${BEAM_VERSION}.jar" -o "$JAR_PATH"
fi

if [ ! -f "$LIB_DIR/beam-runners-flink.jar" ]; then
    echo "Installing Beam JAR to Flink lib directory..."
    sudo cp "$JAR_PATH" "$LIB_DIR/beam-runners-flink.jar"
    NEEDS_RESTART=true
fi

# 2. Configure Flink to listen on all interfaces
if ! grep -q "rest.bind-address: 0.0.0.0" /usr/lib/flink/conf/flink-conf.yaml; then
    echo "Updating Flink configuration..."
    sudo sed -i "s/rest.bind-address: localhost/rest.bind-address: 0.0.0.0/" /usr/lib/flink/conf/flink-conf.yaml
    sudo sed -i "s/jobmanager.bind-host: localhost/jobmanager.bind-host: 0.0.0.0/" /usr/lib/flink/conf/flink-conf.yaml 2>/dev/null || echo "jobmanager.bind-host: 0.0.0.0" | sudo tee -a /usr/lib/flink/conf/flink-conf.yaml
    sudo sed -i "s/taskmanager.bind-host: localhost/taskmanager.bind-host: 0.0.0.0/" /usr/lib/flink/conf/flink-conf.yaml 2>/dev/null || echo "taskmanager.bind-host: 0.0.0.0" | sudo tee -a /usr/lib/flink/conf/flink-conf.yaml
    NEEDS_RESTART=true
fi

# 3. Ensure Flink is started
if ! pgrep -f standalonesession > /dev/null; then
    echo "Starting Flink standalone cluster..."
    sudo /usr/lib/flink/bin/start-cluster.sh
    sleep 10
elif [ "$NEEDS_RESTART" = true ]; then
    echo "Restarting Flink standalone cluster to apply changes..."
    sudo /usr/lib/flink/bin/stop-cluster.sh
    sudo /usr/lib/flink/bin/start-cluster.sh
    sleep 10
else
    echo "Flink cluster is already running with correct config."
fi

# 4. Install dependencies
if ! python3 -c "import apache_beam, fastavro" 2>/dev/null; then
    echo "Installing missing dependencies..."
    pip install --user --break-system-packages apache-beam[gcp] fastavro
else
    echo "Dependencies already satisfied."
fi

# 5. Run the pipeline
export PATH=$PATH:$HOME/.local/bin
python3 json_to_avro.py \
    --runner FlinkRunner \
    --flink_master $(hostname):8081 \
    --flink_version ${FLINK_VER} \
    --environment_type LOOPBACK \
    --input "$1" \
    --output "$2" \
    --save_main_session
