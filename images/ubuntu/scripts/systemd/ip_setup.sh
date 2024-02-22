#!/bin/bash

IP_ADDRESS=$(awk -F'[:= ]+' '{for (i=1; i<=NF; i++) if ($i == "ip") print $(i+1)}' /proc/cmdline)
GATEWAY=$(echo $IP_ADDRESS | awk -F'.' '{print $1"."$2"."$3".1"}')

# Flush the existing ip address and default gateway
ip addr flush dev eth0
ip route flush dev eth0

ip addr add $IP_ADDRESS/24 dev eth0
ip link set eth0 up
ip link set lo up
ip route add default via $GATEWAY dev eth0
