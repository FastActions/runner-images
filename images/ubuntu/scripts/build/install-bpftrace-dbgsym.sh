#!/bin/bash -e
################################################################################
##  File:  install-rust.sh
##  Desc:  Install Rust
################################################################################

echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse
deb http://ddebs.ubuntu.com $(lsb_release -cs)-updates main restricted universe multiverse
deb http://ddebs.ubuntu.com $(lsb_release -cs)-proposed main restricted universe multiverse" | \
	sudo tee -a /etc/apt/sources.list.d/ddebs.list
apt install -y ubuntu-dbgsym-keyring
apt update
apt install -y bpftrace-dbgsym
