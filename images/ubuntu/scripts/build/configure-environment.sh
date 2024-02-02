#!/bin/bash -e
################################################################################
##  File:  configure-environment.sh
##  Desc:  Configure system and environment
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/os.sh
source $HELPER_SCRIPTS/etc-environment.sh

# Set the ACCEPT_EULA variable to Y value to confirm your acceptance of the End-User Licensing Agreement
set_etc_environment_variable "ACCEPT_EULA" "Y"

# This directory is supposed to be created in $HOME and owned by user(https://github.com/actions/runner-images/issues/491)
mkdir -p /etc/skel/.config/configstore
set_etc_environment_variable "XDG_CONFIG_HOME" '$HOME/.config'

# Prepare directory and env variable for toolcache
AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache
mkdir $AGENT_TOOLSDIRECTORY
set_etc_environment_variable "AGENT_TOOLSDIRECTORY" "${AGENT_TOOLSDIRECTORY}"
chmod -R 777 $AGENT_TOOLSDIRECTORY

# Create symlink for tests running
chmod +x $HELPER_SCRIPTS/invoke-tests.sh
ln -s $HELPER_SCRIPTS/invoke-tests.sh /usr/local/bin/invoke_tests

# Disable to load providers
# https://github.com/microsoft/azure-pipelines-agent/issues/3834
if is_ubuntu22; then
    sed -i 's/openssl_conf = openssl_init/#openssl_conf = openssl_init/g' /etc/ssl/openssl.cnf
fi
