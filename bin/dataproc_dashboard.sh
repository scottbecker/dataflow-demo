#!/bin/bash
# Script to open Dataproc Flink and YARN dashboards via SSH tunnel.

PROJECT_ID="maps-346818"
ZONE="us-central1-a"
MASTER_NODE="flink-mini-cluster-m"
PROXY_PORT=1080

echo "Starting SSH SOCKS tunnel on port $PROXY_PORT for $MASTER_NODE..."

# Start the tunnel in the background
gcloud compute ssh "$MASTER_NODE" \
  --project="$PROJECT_ID" \
  --zone="$ZONE" \
  -- -D $PROXY_PORT -N &
TUNNEL_PID=$!

# Ensure the tunnel is killed when the script exits
trap "echo 'Shutting down tunnel...'; kill $TUNNEL_PID 2>/dev/null" EXIT

echo "Waiting 3 seconds for tunnel to establish..."
sleep 3

echo "Opening Google Chrome..."
# Using a separate user-data-dir to allow the proxy settings to work 
# without interfering with other open Chrome windows.
google-chrome \
  --proxy-server="socks5://localhost:$PROXY_PORT" \
  --user-data-dir="/tmp/flink-mini-cluster-m" \
  "http://$MASTER_NODE:8081" \
  "http://$MASTER_NODE:8088"

# Keep script running as long as the tunnel is alive (if chrome finishes immediately)
# or wait for user to Ctrl+C.
wait $TUNNEL_PID
