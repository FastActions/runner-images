#!/bin/bash

set -e

# Define the MMDS IP address
MMDS_IP="169.254.169.254"


# Function to get JIT Metadata
getVsockPort() {
    putTokenOutput=$(curl -X PUT "http://${MMDS_IP}/latest/api/token" -H "X-metadata-token-ttl-seconds: 21600")
    token=${putTokenOutput}
    port=$(curl -s "http://${MMDS_IP}/port" -H "X-metadata-token: ${token}")
    echo ${port}
}

# Retry parameters
max_attempts=5
attempt=0
sleep_time=3 # 15 seconds of retries

while [ $attempt -lt $max_attempts ]; do
    port=$(getVsockPort)
    if [ $? -eq 0 ] && [ ! -z "$port" ]; then
        break
    else
        echo "Could not execute GET port from MMDS, attempt $attempt"
        attempt=$((attempt+1))
        sleep $sleep_time
    fi
done

if [ $attempt -eq $max_attempts ]; then
    echo "Failed to execute GET port from MMDS after $max_attempts attempts"
    exit 1
fi

# Send a signal using socat to the vsock port and CID 2, with a timeout of 15 seconds
echo "Sending signal to port ${port}"
socat -t=15 OPEN:/dev/null VSOCK-CONNECT:2:${port}
