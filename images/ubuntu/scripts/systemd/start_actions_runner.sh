#!/bin/bash

set -e

mmdsIPv4Addr="169.254.169.254"

getMetadata() {
    endpoint=$1
    putTokenOutput=$(curl -X PUT "http://${mmdsIPv4Addr}/latest/api/token" -H "X-metadata-token-ttl-seconds: 21600")
    token=${putTokenOutput}
    getOutput=$(curl -s "http://${mmdsIPv4Addr}/${endpoint}" -H "X-metadata-token: ${token}")
    echo ${getOutput}
}

runActionsRunner() {
    jit=$1
    RUNNER_ALLOW_RUNASROOT=1  ./run.sh --jitconfig ${jit}
    if [ $? -ne 0 ]; then
        echo "Could not start actions runner"
        exit 1
    fi
}

retryCommand() {
    local max_attempts=$1
    local sleep_time=$2
    local command=$3
    local attempt=0
    local result

    while [ $attempt -lt $max_attempts ]; do
        result=$(eval $command)
        local status=$?
        if [ $status -eq 0 ] && [ ! -z "$result" ]; then
            echo $result
            return 0
        else
            echo "Attempt $attempt failed, retrying in $sleep_time seconds..."
            attempt=$((attempt+1))
            sleep $sleep_time
        fi
    done

    echo "Failed to execute command after $max_attempts attempts"
    return 1
}

max_attempts=5
sleep_time=3 # seconds of retries

jit=$(retryCommand $max_attempts $sleep_time "getMetadata jit") || exit 1
cacheURL=$(retryCommand $max_attempts $sleep_time "getMetadata cacheURL") || exit 1
cacheToken=$(retryCommand $max_attempts $sleep_time "getMetadata cacheToken") || exit 1
repo=$(retryCommand $max_attempts $sleep_time "getMetadata repo") || exit 1

homeDir=$(grep '^runner:' /etc/passwd | cut -d: -f6)
export HOME=$homeDir
export "BLACKSMITH_CACHE_URL=${cacheURL}"
export "BLACKSMITH_CACHE_TOKEN=${cacheToken}"
export "GITHUB_REPO_NAME=${repo}"
export ACTIONS_RUNNER_HOOK_JOB_STARTED="/setup.sh"

runActionsRunner ${jit}

sudo reboot
