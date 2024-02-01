#!/bin/bash

set -e

# Function to get JIT Metadata
getJITMetadata() {
    mmdsIPv4Addr="169.254.169.254"
    putTokenOutput=$(curl -X PUT "http://${mmdsIPv4Addr}/latest/api/token" -H "X-metadata-token-ttl-seconds: 21600")
    token=${putTokenOutput}
    getJitOutput=$(curl -s "http://${mmdsIPv4Addr}/jit" -H "X-metadata-token: ${token}")
    echo ${getJitOutput}
}

# Function to run Actions Runner
runActionsRunner() {
    jit=$1
    RUNNER_ALLOW_RUNASROOT=1  ./root/runner/run.sh --jitconfig ${jit}
    if [ $? -ne 0 ]; then
        echo "Could not start actions runner"
        exit 1
    fi
}

# Retry parameters
max_attempts=5
attempt=0
sleep_time=3 # 15 seconds of retries

while [ $attempt -lt $max_attempts ]; do
    jit=$(getJITMetadata)
    if [ $? -eq 0 ] && [ ! -z "$jit" ]; then
        break
    else
        echo "Could not execute GET JIT from MMDS, attempt $attempt"
        attempt=$((attempt+1))
        sleep $sleep_time
    fi
done

if [ $attempt -eq $max_attempts ]; then
    echo "Failed to execute GET JIT from MMDS after $max_attempts attempts"
    exit 1
fi


export ACTIONS_RUNNER_HOOK_JOB_STARTED="/setup.sh"
export HOME=/root
export PATH=/root/.cargo/bin:/root/.cabal/bin:/root/.ghcup/bin:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/opt/maven/apache-maven-3.8.8/bin:/root/miniconda3/bin:/usr/share/swift/usr/bin:/root/.sdkman/candidates/kotlin/current/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/root/.local/bin:/root/.pulumi/bin:/root/.local/bin
runActionsRunner ${jit}
reboot
