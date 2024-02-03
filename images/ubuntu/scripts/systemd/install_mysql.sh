#!/bin/bash

set -e

# Install mysql and stop the service. Installing mysql in Packer
# refuses to work so for now we do it in a service unit.
apt-get install -y mysql-server-8.0 && service mysql stop
sudo systemctl disable mysql
