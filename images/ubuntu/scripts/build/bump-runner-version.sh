#!/bin/bash -e
source $HELPER_SCRIPTS/etc-environment.sh

# Download and place the actions-runner in the /runner directory so
# it is accessible to the `runner` user we created above.
RUNNER_VERSION=2.313.0
replace_etc_environment_variable "RUNNER_VERSION" "${RUNNER_VERSION}"
cd /home/runner
wget https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
./run.sh --version
