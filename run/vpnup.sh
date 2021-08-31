#!/bin/sh

# Message prefix
TIME=$(date +%T)
PREFIX="[${TIME} INFO]:"

echo "${PREFIX} VPN connection up."
touch /run/up.vpn