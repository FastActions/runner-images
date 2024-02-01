#!/bin/bash

set -e
 
echo "DNS=8.8.8.8" >> /etc/systemd/resolved.conf
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf