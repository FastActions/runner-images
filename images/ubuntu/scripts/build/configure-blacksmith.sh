#!/bin/bash -e
source $HELPER_SCRIPTS/etc-environment.sh

apt-get install -y vim

apt-get update && \
apt-get install -y systemd && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

cp $SYSTEMD_SCRIPT_FOLDER/setup.service /etc/systemd/system/setup.service
systemctl enable setup.service

cp $SYSTEMD_SCRIPT_FOLDER/setup_and_run_github_actions.service /etc/systemd/system/setup_and_run_github_actions.service
systemctl enable setup_and_run_github_actions.service

cp $SYSTEMD_SCRIPT_FOLDER/setup_dns.service /etc/systemd/system/setup_dns.service
systemctl enable setup_dns.service

cp $SYSTEMD_SCRIPT_FOLDER/ip_setup.sh /ip_setup.sh
chmod +x /ip_setup.sh

cp $SYSTEMD_SCRIPT_FOLDER/hostname_setup.sh /hostname_setup.sh
chmod +x /hostname_setup.sh

cp $SYSTEMD_SCRIPT_FOLDER/setup_dns.sh /setup_dns.sh
chmod +x /setup_dns.sh

cp $SYSTEMD_SCRIPT_FOLDER/start_actions_runner.sh /start_actions_runner.sh
chmod +x /start_actions_runner.sh

# Create a runner user that will be used to run the
# github action workflow.
echo 'Create runner user'
adduser --disabled-password --gecos "" runner
echo 'runner:runner' | chpasswd
echo 'runner ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
usermod -aG sudo,docker,adm,systemd-journal runner

# Replace $HOME with the default user's home directory for environmental variables
# related to the default user home directory.
homeDir=$(grep '^runner:' /etc/passwd | cut -d: -f6)
sed -i "s|\$HOME|$homeDir|g" /etc/environment
echo "/etc/environment HOME has been sed to ${homeDir}"

# Set root password for debugging access
echo 'set root pass'
echo 'root:root' | chpasswd

# Remove executable permissions from systemd configuration files
find /lib/systemd/system -type f -executable -exec chmod -x {} \;

# Remove executable permissions from /etc files
find /etc -type f -executable -exec chmod -x {} \;

# Install socat so that the VM can interact with the host machine over vsock.
apt-get install -y socat;

# Copy pre-start github runner script to a well known location.
cp $SYSTEMD_SCRIPT_FOLDER/setup.sh /setup.sh
chmod +x /setup.sh

# Download and place the actions-runner in the /runner directory so
# it is accessible to the `runner` user we created above.
RUNNER_VERSION=2.311.0
set_etc_environment_variable "RUNNER_VERSION" "${RUNNER_VERSION}"
cd /home/runner
wget https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
