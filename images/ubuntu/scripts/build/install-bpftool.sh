#!/bin/bash -e
################################################################################
##  File:  install-bpftool.sh
##  Desc:  Install llvm and bpftool
################################################################################

# Install libelf.
sudo apt-get update -y
sudo apt-get install -y libelf-dev

# Install llvm.
sudo apt-get install -y llvm

rm /usr/sbin/bpftool

sudo apt update && sudo apt install -y git
cd / && sudo git clone --recurse-submodules https://github.com/libbpf/bpftool.git

cd bpftool/src
sudo make install

sudo ln -s /usr/local/sbin/bpftool /usr/sbin/bpftool
