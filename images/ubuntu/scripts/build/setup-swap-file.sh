#!/bin/bash -e

sudo dd if=/dev/zero of=/swapfile bs=1M count=11264
sudo chmod 600 /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
