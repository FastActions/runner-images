#!/bin/bash -e
################################################################################
##  File:  install-libssl.sh
##  Desc:  Install libssl1.1 for backward compatibility with tools that
##         link against OpenSSL 1.1 (e.g. MongoDB 4.x)
################################################################################

source $HELPER_SCRIPTS/os.sh

if is_ubuntu22; then
    echo "Installing libssl1.1 compatibility package..."
    focal_list=/etc/apt/sources.list.d/focal-security.list
    echo "deb http://security.ubuntu.com/ubuntu focal-security main" | tee "${focal_list}"
    apt-get update --quiet
    apt-get install --no-install-recommends --yes libssl1.1
    rm "${focal_list}"
    apt-get update --quiet
fi
